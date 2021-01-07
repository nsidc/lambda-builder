#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# BUILD_NUMBER=${bamboo.buildResultKey}
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cat << EOF > "${PWD}"/build-status
export CONTEXT="Build"
export STATUS=pending
export DESCRIPTION="${BUILD_NUMBER} started"
EOF
"${SCRIPT_DIR}"/../set-status.sh

# build
"$(pwd)"/lambda-builder/build.sh "$(pwd)"/"${REPO}"

"${PWD}"/"${REPO}"/test.sh

# update env vars for successful deploy (github API will be reached in the
# "final" task)
cat << EOF > "${PWD}"/build-status
export CONTEXT="Build"
export STATUS=success
export DESCRIPTION="${BUILD_NUMBER} succeeded."
EOF
