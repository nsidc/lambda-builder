#!/bin/bash
set -e

# Required environment variables in bamboo:
#
# BUILD_NUMBER=${bamboo.buildResultKey}
# GITHUB_TOKEN_SECRET=${bamboo.GITHUB_TOKEN_SECRET}
# LAMBDA_FUNCTION_NAME=${bamboo.LAMBDA_FUNCTION_NAME}
# ORG=${bamboo.GITHUB_ORG}
# RELEASE_VERSION_NAME=${bamboo.inject.RELEASE_VERSION_NAME}
# REPO=${bamboo.REPO}
# TARGET_URL=${bamboo.resultsUrl}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z ${RELEASE_VERSION_NAME} ]; then
    >&2 echo "No release version found."
    exit 1
elif [[ ! ${RELEASE_VERSION_NAME} =~ ^v[0-9] ]]; then
    >&2 echo "RELEASE_VERSION_NAME does not look like a version tag: ${RELEASE_VERSION_NAME}"
    exit 1
fi

cat << EOF > ${PWD}/build-status
export CONTEXT="Deploy to GitHub release"
export STATUS=pending
export DESCRIPTION="${BUILD_NUMBER} started"
EOF
${SCRIPT_DIR}/../set-status.sh


URL="https://api.github.com/repos/${ORG}/${REPO}/releases"

# check if release already exists
echo "Checking for existing release..."
RESPONSE=$(curl --silent --show-error \
                --header "Authorization: token ${GITHUB_TOKEN_SECRET}" \
                --header "Content-Type: application/json" \
                --request GET\
                ${URL}/tags/${RELEASE_VERSION_NAME})
UPLOAD_URL=$((echo ${RESPONSE} | jq -r '.upload_url') || true)

echo "RESPONSE: ${RESPONSE}"

echo "UPLOAD_URL=${UPLOAD_URL}"

# create release if it doesn't exist
if [ -z "${UPLOAD_URL}" ] || [ "${UPLOAD_URL}" = "null" ]; then
    echo "Creating new release..."
    BODY="See [CHANGELOG.md](https://github.com/nsidc/XMLTransformISO2CMRLambda/blob/main/CHANGELOG.md#${RELEASE_VERSION_NAME//./})"
    echo "posting to URL: ${URL}"
    echo posting data: "{\"tag_name\": \"${RELEASE_VERSION_NAME}\", \"name\": \"${RELEASE_VERSION_NAME}\", \"body\": \"${BODY}\"}"
    POST_RESPONSE=$(curl --silent --show-error \
                    --header "Authorization: token ${GITHUB_TOKEN_SECRET}" \
                    --header "Accept: application/vnd.github.v3+json" \
                    --data "{\"tag_name\": \"${RELEASE_VERSION_NAME}\", \"name\": \"${RELEASE_VERSION_NAME}\", \"body\": \"${BODY}\"}"\
                    --request POST\
                    ${URL})
    echo "RESPONSE: ${POST_RESPONSE}"
    UPLOAD_URL=$(echo ${POST_RESPONSE} | jq -r '.upload_url')
    echo "UPLOAD_URL=${UPLOAD_URL}"
fi

if [ -z ${UPLOAD_URL} ]; then
    >&2 echo "Upload URL not found."
    exit 1
fi


# substitute the correct file name
UPLOAD_URL=${UPLOAD_URL/\{?name,label\}/?name=${LAMBDA_FUNCTION_NAME}.zip}

echo "Uploading to ${UPLOAD_URL}..."

# upload lambda.zip
curl --silent --show-error \
     --header "Authorization: token ${GITHUB_TOKEN_SECRET}" \
     --header "Content-Type: application/zip" \
     --data-binary @lambda.zip \
     --request POST\
     ${UPLOAD_URL}

# update env vars for successful deploy (github API will be reached in the
# "final" task)
cat << EOF > ${PWD}/build-status
export CONTEXT="Deploy to GitHub release"
export STATUS=success
export DESCRIPTION="${BUILD_NUMBER} succeeded"
EOF
