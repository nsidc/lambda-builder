#!/bin/bash
set -e

USAGE="usage: build.sh PROJECT_DIR [LAMBDA_NAME]"

# ensure right number of args
if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
    echo "$USAGE"
    exit 1
fi

# ensure right kind of arg
PROJECT_DIR=$1
if [[ "${PROJECT_DIR}" != /* ]]; then
    PROJECT_DIR=$(realpath "${PWD}/${PROJECT_DIR}")
fi

if [[ ! -d "${PROJECT_DIR}" ]]; then
    echo "$USAGE"
    echo -e "\nERROR: PROJECT_DIR must be a path to an existing directory."
    exit 1
fi

LAMBDA_NAME=$2
if [ -z "${LAMBDA_NAME}" ]; then
    LAMBDA_NAME='lambda'
fi

# make this script work no matter where it was called from
BUILDER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# build docker image
DOCKER_IMAGE_TAG=lambda-builder
if [ -z "${DOCKERFILE}" ]; then
    DOCKERFILE="${BUILDER_DIR}/Dockerfile"
else
    DOCKERFILE="${BUILDER_DIR}/${DOCKERFILE}"
fi
docker build -t ${DOCKER_IMAGE_TAG} "${BUILDER_DIR}" -f "${DOCKERFILE}"

# run the build script on the docker container
docker run \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v "${PROJECT_DIR}":"${PROJECT_DIR}" \
       -e PROJECT_DIR="${PROJECT_DIR}" \
       ${DOCKER_IMAGE_TAG}

# move the build artifact to current directory
mv "${PROJECT_DIR}"/lambda.zip "${LAMBDA_NAME}".zip

echo "Created ${LAMBDA_NAME}.zip"
