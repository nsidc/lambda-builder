#!/bin/bash
set -e

# Called in Bamboo "Build" job like this:
#
# ./lambda-builder/bamboo/task_build.sh \
#     ${bamboo.GITHUB_ORG} \
#     ${bamboo.REPO} \
#     ${bamboo.GITHUB_TOKEN_SECRET} \
#     ${bamboo.resultsUrl}

echo ${BASH_SOURCE[0]}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# args from bamboo
export ORG=$1
export REPO=$2
export GITHUB_TOKEN_SECRET=$3
export RESULTS_URL=$4

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
