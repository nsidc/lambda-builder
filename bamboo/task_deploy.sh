#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# LAMBDA_FUNCTION_NAME=${bamboo.LAMBDA_FUNCTION_NAME}
# AWS_DEFAULT_REGION=${bamboo.AWS_DEFAULT_REGION}
# AWS_PROFILE=${bamboo.AWS_PROFILE}
# AWS_SECRET_ACCESS_KEY=${bamboo.AWS_SECRET_ACCESS_KEY}
# AWS_SECRET_ACCESS_KEY_ID=${bamboo.AWS_SECRET_ACCESS_KEY_ID}
# BRANCH_TO_DEPLOY=${bamboo.BRANCH_TO_DEPLOY}
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# PREFIX=${bamboo.CUMULUS_PREFIX}
# RESULTS_URL=${bamboo.resultsUrl}

echo ${BASH_SOURCE[0]}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export STATUS=pending

export GIT_SHA=$(cd $REPO && git rev-parse HEAD)

export DESCRIPTION='Build started'
export CONTEXT="Bamboo: DeployToSandbox"

# deploy iff on correct branch
BRANCH=$(cd ./${REPO} && git rev-parse --abbrev-ref HEAD)
if [ "${BRANCH}" = "${BRANCH_TO_DEPLOY}" ]; then
    export DEPLOYING=true
else
    export DEPLOYING=false
fi

# write above vars to a file so they can also be used in the "Final" bamboo step
${SCRIPT_DIR}/add-to-env-file.sh \
    AWS_DEFAULT_REGION \
    AWS_PROFILE \
    AWS_SECRET_ACCESS_KEY \
    AWS_SECRET_ACCESS_KEY_ID \
    BRANCH_TO_DEPLOY \
    DEPLOYING \
    GITHUB_TOKEN_SECRET \
    RESULTS_URL \
    REPO \
    ORG \
    STATUS \
    GIT_SHA \
    RESULTS_URL \
    DESCRIPTION \
    CONTEXT

# only update status if this is a branch we're deploying
if [ "${DEPLOYING}" = "true" ]; then
    echo "On branch ${BRANCH}, proceeding with deployment."
    ${SCRIPT_DIR}/set-github-status.sh
else
    echo "On branch ${BRANCH}, but BRANCH_TO_DEPLOY is ${BRANCH_TO_DEPLOY}; not deploying."
    exit 0
fi

# write aws credentials
${SCRIPT_DIR}/write-aws-credentials.sh

# deploy
echo "docker run"
echo "    -v $(pwd):$(pwd)"
echo "    -v $(pwd)/aws:/home/linuxbrew/.aws"
echo "    -e AWS_SHARED_CREDENTIALS_FILE=$(pwd)/aws/credentials"
echo "    -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"
echo "    -e AWS_PROFILE=${AWS_PROFILE}"
echo "    -w $(pwd)"
echo "    lambda-builder"
echo "        bash -c \"source .bamboo_env_vars && ${SCRIPT_DIR}/../publish.sh $(pwd)/lambda.zip ${PREFIX} ${LAMBDA_FUNCTION_NAME}\""
docker run \
    -v $(pwd):$(pwd) \
    -v $(pwd)/aws:/home/linuxbrew/.aws \
    -e AWS_SHARED_CREDENTIALS_FILE=$(pwd)/aws/credentials \
    -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    -e AWS_PROFILE=${AWS_PROFILE} \
    -w $(pwd) \
    lambda-builder \
        bash -c "source .bamboo_env_vars && ${SCRIPT_DIR}/../publish.sh $(pwd)/lambda.zip ${PREFIX} ${LAMBDA_FUNCTION_NAME}"

# update env vars for successful deploy (github API will be reached in the
# "final" task)
export STATUS=success
export DESCRIPTION="Deployed to Sandbox"
${SCRIPT_DIR}/add-to-env-file.sh STATUS DESCRIPTION
