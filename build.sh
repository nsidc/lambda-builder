#!/bin/bash
set -e

USAGE="usage: host_script.sh PROJECT_DIR"

# ensure right number of args
if [ "$#" -ne 1 ]; then
    echo $USAGE
    exit 1
fi

# ensure right kind of arg
PROJECT_DIR=$1
if [[ "${PROJECT_DIR}" != /* ]] || [[ ! -d "${PROJECT_DIR}" ]]; then
    echo $USAGE
    echo -e "\nERROR: PROJECT_DIR must be an absolute path to an existing directory."
    exit 1
fi

# make this script work no matter where it was called from
BUILDER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# build docker image
DOCKER_IMAGE_TAG=lambda-builder
docker build -t ${DOCKER_IMAGE_TAG} ${BUILDER_DIR}

# run the build script on the docker container
docker run \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v ${PROJECT_DIR}:${PROJECT_DIR} \
       -e PROJECT_DIR="${PROJECT_DIR}" \
       ${DOCKER_IMAGE_TAG}

# move the build artifact to current directory
mv ${PROJECT_DIR}/lambda.zip lambda.zip

echo "Created lambda.zip"
