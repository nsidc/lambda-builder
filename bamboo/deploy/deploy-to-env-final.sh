#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# AWS_PROFILE=${bamboo.AWS_PROFILE}
# BUILD_NUMBER=${bamboo.buildResultKey}
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "${PWD}"/build-status || true

# if status was never updated to success, it failed
if [ "${STATUS}" = "pending" ]; then
    cat << EOF >> "${PWD}"/build-status
export CONTEXT="Deploy to ${AWS_PROFILE}"
export STATUS=failure
export DESCRIPTION="${BUILD_NUMBER} failed"
EOF
fi

"${SCRIPT_DIR}"/../set-status.sh

# clean up build-status file
rm -v "${PWD}"/build-status
