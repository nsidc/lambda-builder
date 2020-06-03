#!/bin/bash
set -e

source .bamboo_env_vars || true

URL="https://api.github.com/repos/${ORG}/${REPO}/statuses/${GIT_SHA}"
echo "POSTing status to ${URL}"

curl \
    -H "Authorization: token ${GITHUB_TOKEN_SECRET}" \
    -H "Content-Type: application/json" \
    -d "{\"state\":\"${STATUS}\", \"target_url\": \"${RESULTS_URL}\", \"description\": \"${DESCRIPTION}\", \"context\": \"${CONTEXT}\"}"\
    -X POST\
    ${URL}
