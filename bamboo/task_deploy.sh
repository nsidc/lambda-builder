#!/bin/bash
set -e

# Called in Bamboo "DeployToSandbox" job like this:
#
# ./lambda-builder/bamboo/task_deploy.sh \
#	${bamboo.GITHUB_ORG} \
#	${bamboo.REPO} \
#	${bamboo.LAMBDA_FUNCTION_NAME} \
# 	${bamboo.AWS_DEFAULT_REGION} \
# 	${bamboo.AWS_PROFILE} \
# 	${bamboo.AWS_SECRET_ACCESS_KEY} \
# 	${bamboo.AWS_SECRET_ACCESS_KEY_ID} \
# 	${bamboo.BRANCH_TO_DEPLOY} \
# 	${bamboo.GITHUB_TOKEN_SECRET} \
# 	${bamboo.resultsUrl}

echo ${BASH_SOURCE[0]}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# args from bamboo
export ORG=$1
export REPO=$2
export LAMBDA_FUNCTION_NAME=$3
export AWS_DEFAULT_REGION=$4
export AWS_PROFILE=$5
export AWS_SECRET_ACCESS_KEY=$6
export AWS_SECRET_ACCESS_KEY_ID=$7
export BRANCH_TO_DEPLOY=$8
export GITHUB_TOKEN_SECRET=$9
export RESULTS_URL=$10

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
echo docker run \
    -v $(pwd):$(pwd) \
    -v $(pwd)/aws:/home/linuxbrew/.aws \
    -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    -e AWS_PROFILE=${AWS_PROFILE} \
    lambda-builder aws lambda update-function-code \
    --function-name ${LAMBDA_FUNCTION_NAME} \
    --zip-file fileb://$(pwd)/lambda.zip
docker run \
    -v $(pwd):$(pwd) \
    -v $(pwd)/aws:/home/linuxbrew/.aws \
    -e AWS_SHARED_CREDENTIALS_FILE=/home/linuxbrew/.aws/credentials \
    -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    -e AWS_PROFILE=${AWS_PROFILE} \
    lambda-builder aws lambda update-function-code \
    --function-name ${LAMBDA_FUNCTION_NAME} \
    --zip-file fileb://$(pwd)/lambda.zip

# update env vars for successful deploy (github API will be reached in the
# "final" task)
export STATUS=success
export DESCRIPTION="Deployed to Sandbox"
${SCRIPT_DIR}/add-to-env-file.sh STATUS DESCRIPTION
