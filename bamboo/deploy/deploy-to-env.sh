#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# AWS_DEFAULT_REGION=${bamboo.AWS_DEFAULT_REGION}
# AWS_PROFILE=${bamboo.AWS_PROFILE}
# AWS_SECRET_ACCESS_KEY=${bamboo.AWS_SECRET_ACCESS_KEY}
# AWS_SECRET_ACCESS_KEY_ID=${bamboo.AWS_SECRET_ACCESS_KEY_ID}
# BUILD_NUMBER=${bamboo.buildResultKey}
# DEPLOY_NAME=${bamboo.DEPLOY_NAME}
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# LAMBDA_FUNCTION_NAME=${bamboo.LAMBDA_FUNCTION_NAME}
# MATURITY=${bamboo.MATURITY}
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cat << EOF > ${PWD}/build-status
export CONTEXT="Deploy to ${AWS_PROFILE}"
export STATUS=pending
export DESCRIPTION="${BUILD_NUMBER} started"
EOF
${SCRIPT_DIR}/../set-status.sh

mkdir aws
cat << EOF > ${PWD}/aws/credentials
[${AWS_PROFILE}]
aws_access_key_id = ${AWS_SECRET_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOCKER_IMAGE_TAG=lambda-builder
docker build -t ${DOCKER_IMAGE_TAG} ../../${SCRIPT_DIR}

# deploy
docker run \
    --volume $(pwd):$(pwd) \
    --volume $(pwd)/aws:/home/linuxbrew/.aws \
    --env AWS_SHARED_CREDENTIALS_FILE=$(pwd)/aws/credentials \
    --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    --env AWS_PROFILE=${AWS_PROFILE} \
    --workdir $(pwd) \
    ${DOCKER_IMAGE_TAG} \
        bash -c "${SCRIPT_DIR}/../../publish.sh $(pwd)/lambda.zip ${DEPLOY_NAME}-cumulus-${MATURITY} ${LAMBDA_FUNCTION_NAME}"

# update env vars for successful deploy (github API will be reached in the
# "final" task)
cat << EOF > ${PWD}/build-status
export CONTEXT="Deploy to ${AWS_PROFILE}"
export STATUS=success
export DESCRIPTION="${BUILD_NUMBER} succeeded"
EOF
