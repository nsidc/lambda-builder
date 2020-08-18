#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# BRANCH_TO_DEPLOY=${bamboo.BRANCH_TO_DEPLOY}
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# only update status if this is a branch we're deploying
branch=$(cd ${REPO} && git rev-parse --abbrev-ref HEAD)
if [ "${BRANCH_TO_DEPLOY}" = "${branch}" ]; then
    if [ "${branch}" != "main" ] && [ "${branch}" != "release" ]; then
        ${SCRIPT_DIR}/../set-status.sh
    fi
fi
