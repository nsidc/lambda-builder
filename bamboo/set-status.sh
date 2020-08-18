#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}

STATUS=${1}
DESCRIPTION=${2}


if [ -z ${STATUS} ] || [ -z ${DESCRIPTION} ]; then
    source ${PWD}/build-status || exit 1
fi

GIT_SHA=$(cd ${REPO} && git rev-parse HEAD)

URL="https://api.github.com/repos/${ORG}/${REPO}/statuses/${GIT_SHA}"
echo "POSTing status to ${URL}"

curl \
    -H "Authorization: token ${GITHUB_TOKEN_SECRET}" \
    -H "Content-Type: application/json" \
    -d "{\"state\":\"${STATUS}\", \"target_url\": \"${TARGET_URL}\", \"description\": \"${DESCRIPTION}\", \"context\": \"${CONTEXT}\"}"\
    -X POST\
    ${URL}
