#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# AWS_DEFAULT_REGION=${bamboo.AWS_DEFAULT_REGION}
# AWS_PROFILE=${bamboo.AWS_PROFILE}
# AWS_SECRET_ACCESS_KEY=${bamboo.AWS_SECRET_ACCESS_KEY}
# AWS_SECRET_ACCESS_KEY_ID=${bamboo.AWS_SECRET_ACCESS_KEY_ID}
# BRANCH_TO_DEPLOY=${bamboo.BRANCH_TO_DEPLOY}
# BUILD_NUMBER=${bamboo.buildResultKey}
# DEPLOY_NAME=${bamboo.DEPLOY_NAME}
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# LAMBDA_FUNCTION_NAME=${bamboo.LAMBDA_FUNCTION_NAME}
# MATURITY=${bamboo.MATURITY}
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

branch=$(cd "${REPO}" && git rev-parse --abbrev-ref HEAD)

if [ "${BRANCH_TO_DEPLOY}" = "${branch}" ]; then
    if [ "${branch}" = "main" ] || [ "${branch}" = "release" ]; then
        echo "Deployment of branch \"${branch}\" is handled by Deployment project"
    else
        "${SCRIPT_DIR}"/../deploy/deploy-to-env.sh
    fi
else
    echo "Current branch is ${branch}, BRANCH_TO_DEPLOY is ${BRANCH_TO_DEPLOY}; not deploying."
fi
