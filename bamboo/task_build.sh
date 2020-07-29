#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# RESULTS_URL=${bamboo.resultsUrl}

echo ${BASH_SOURCE[0]}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export CONTEXT="Bamboo: Build"
export GITHUB_TOKEN_SECRET=$GITHUB_TOKEN_SECRET
export GIT_SHA=$(cd ${REPO} && git rev-parse HEAD)
export TARGET_URL=$RESULTS_URL
export STATUS=pending
export DESCRIPTION='Build started'

# write above vars to a file so they can also be used in the "Final" bamboo step
${SCRIPT_DIR}/add-to-env-file.sh \
    CONTEXT \
    GITHUB_TOKEN_SECRET \
    GIT_SHA \
    TARGET_URL \
    ORG \
    REPO \
    STATUS \
    DESCRIPTION

# set initial github status
${SCRIPT_DIR}/set-github-status.sh

# build
$(pwd)/lambda-builder/build.sh $(pwd)/${REPO}

# update env vars for successful deploy (github API will be reached in the
# "final" task)
export STATUS=success
export DESCRIPTION="Build succeeded."
${SCRIPT_DIR}/add-to-env-file.sh STATUS DESCRIPTION

${PWD}/${REPO}/test.sh
