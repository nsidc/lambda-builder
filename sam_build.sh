#!/bin/bash
set -e

# run this on the docker container; works on host too if environment variables
# set and sam is installed

# env setup
RESOURCE_NAME=$(cat "${PROJECT_DIR}"/template.yaml | grep -A1 -E '^Resources:$' | tail -1 | cut -d ':' -f 1 | awk '{print $1}')
BUILD_DIR=${PROJECT_DIR}/build
OUT_FILE=${PROJECT_DIR}/lambda.zip

# env verification
echo PROJECT_DIR="${PROJECT_DIR}"
echo RESOURCE_NAME="${RESOURCE_NAME}"
echo BUILD_DIR="${BUILD_DIR}"
echo OUT_FILE="${OUT_FILE}"

# make sure all required env vars have a value
for VAR in PROJECT_DIR RESOURCE_NAME BUILD_DIR OUT_FILE; do
    if [ -z "${!VAR}" ]; then
        echo "ERROR: no value found for ${!VAR}"
        exit 1
    fi
done

# clean up lambda.zip
rm -vf "${OUT_FILE}"

# opt out of amazon data collection
export SAM_CLI_TELEMETRY=0

# build it
sam build \
    --use-container \
    --template-file "${PROJECT_DIR}"/template.yaml \
    --build-dir "${BUILD_DIR}"

# zip it
(cd "${BUILD_DIR}"/"${RESOURCE_NAME}" && zip "${OUT_FILE}" -X -r ./*)

# clean up
rm -rf "${BUILD_DIR}"
