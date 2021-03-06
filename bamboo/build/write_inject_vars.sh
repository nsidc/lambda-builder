#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# REPO=${bamboo.REPO}

VAR_FILE=inject_vars.txt

cd "${REPO}"
branch=$(git rev-parse --abbrev-ref HEAD)
commit=$(git rev-parse --short HEAD)
version_tag=$( (git tag --points-at HEAD | grep -E '^v[0-9]') || echo '')

if [ "${branch}" = "release" ]; then
    if [ -z "${version_tag}" ]; then
        >&2 echo "Found no version tag."
        exit 1
    elif [ "$(echo "${version_tag}" | wc -l)" -gt 1 ]; then
        >&2 echo "Found multiple version tags: ${version_tag}"
        exit 1
    else
        VERSION=${version_tag}
    fi
else
    VERSION="${branch}-${commit}"
fi
cd -

{
echo ''
echo RELEASE_VERSION_NAME="${VERSION}" 
echo RELEASE_BRANCH="${branch}"  
echo RELEASE_TAG="${version_tag}"  
} >> ${VAR_FILE}
