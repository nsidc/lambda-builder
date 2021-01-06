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
# RELEASE_BRANCH=${bamboo.inject.RELEASE_BRANCH}
# RELEASE_TAG=${bamboo.inject.RELEASE_TAG}
# RELEASE_VERSION_NAME=${bamboo.inject.RELEASE_VERSION_NAME}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cat << EOF > "${PWD}"/build-status
export CONTEXT="Deploy to ${AWS_PROFILE}"
export STATUS=pending
export DESCRIPTION="${BUILD_NUMBER} started"
EOF
"${SCRIPT_DIR}"/../set-status.sh

if [ "${RELEASE_VERSION_NAME}" = "${RELEASE_TAG}" ]; then
    RELEASE_NAME=${RELEASE_TAG}
else
    RELEASE_NAME=${RELEASE_BRANCH}
fi

export AWS_CLI=${SCRIPT_DIR}/aws.sh
export AWS_ACCESS_KEY_ID=${AWS_SECRET_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
"${SCRIPT_DIR}"/../../publish.sh $(pwd)/lambda.zip "${DEPLOY_NAME}"-cumulus-"${MATURITY}" "${LAMBDA_FUNCTION_NAME}" "${RELEASE_NAME}"

# update env vars for successful deploy (github API will be reached in the
# "final" task)
cat << EOF > "${PWD}"/build-status
export CONTEXT="Deploy to ${AWS_PROFILE}"
export STATUS=success
export DESCRIPTION="${BUILD_NUMBER} succeeded"
EOF
