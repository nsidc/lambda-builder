#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# ORG=${bamboo.GITHUB_ORG}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# shellcheck source=/dev/null
source "${PWD}"/build-status || true

# if status was never updated to success, it failed
if [ "${STATUS}" = "pending" ]; then
    cat << EOF >> "${PWD}"/build-status
export CONTEXT="Build"
export STATUS=failure
export DESCRIPTION="job failed"
EOF
fi

"${SCRIPT_DIR}"/../set-status.sh

# clean up build-status file
rm -v "${PWD}"/build-status
