#!/bin/bash
set -e

echo ${BASH_SOURCE[0]}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# if status was never updated to success, it failed
if [ "${STATUS}" = "pending" ]; then
    cat << EOF >> .bamboo_env_vars
export STATUS=failure
export DESCRIPTION="job failed"
EOF
fi

source .bamboo_env_vars || true

URL="https://api.github.com/repos/${ORG}/${REPO}/statuses/${GIT_SHA}"
echo "POSTing status to ${URL}"

curl \
    -H "Authorization: token ${GITHUB_TOKEN_SECRET}" \
    -H "Content-Type: application/json" \
    -d "{\"state\":\"${STATUS}\", \"target_url\": \"${TARGET_URL}\", \"description\": \"${DESCRIPTION}\", \"context\": \"${CONTEXT}\"}"\
    -X POST\
    ${URL}

# clean up env vars file
rm -v .bamboo_env_vars
