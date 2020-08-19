#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# REPO=${bamboo.REPO}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

VAR_FILE=inject_vars.txt


cd ${REPO}
VERSION=$(git tag --points-at HEAD | grep -E '^v[0-9]' || git rev-parse  --short HEAD)
if [ $(echo "${VERSION}" | wc -l) -gt 1 ]; then
    >&2 echo "Found multiple version tags: ${VERSION}"
    exit 1
fi
cd -


echo '' > ${VAR_FILE}
echo RELEASE_VERSION_NAME=${VERSION} >> ${VAR_FILE}
