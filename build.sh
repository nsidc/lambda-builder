#!/bin/bash
set -e

USAGE="usage: build.sh PROJECT_DIR [LAMBDA_NAME]"

# ensure right number of args
if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
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

LAMBDA_NAME=$(basename $PROJECT_DIR)
#LAMBDA_NAME=$2
if [ -z "${LAMBDA_NAME}" ]; then
    LAMBDA_NAME='lambda'
fi

curl -k -u $bamboo_maven_user:$bamboo_maven_password -v "https://maven.earthdata.nasa.gov/repository/nsidc/requirements-${LAMBDA_NAME}.txt.md5" -O

LAST_REQ_HASH=`cat requirements-${LAMBDA_NAME}.txt.md5 | sed - 's: ::g'`
CURR_REQ_HASH=`/usr/bin/md5sum ${PROJECT_DIR}/requirements.txt| sed - 's: ::g'`

echo "LAST HASH -${LAST_REQ_HASH}-"
echo "CURR HASH -${CURR_REQ_HASH}-"

# Compare Current and Previous Requriements.txt file md5 checksum hashes, and to save time rezip if requirements have not changed
if [ "${LAST_REQ_HASH}" = "${CURR_REQ_HASH}" ]
then
  echo "IN IF STATEMENT"
  curl -k -u $bamboo_maven_user:$bamboo_maven_password -v "https://maven.earthdata.nasa.gov/repository/nsidc/${LAMBDA_NAME}.zip" -o ./${LAMBDA_NAME}_OLD.zip
  unzip ${LAMBDA_NAME}_OLD.zip -d OLD/
  cp -r ${PROJECT_DIR}/src/* ./OLD/
  zip -X -r ${LAMBDA_NAME}.zip ./OLD/* 
else
  echo "IN ELSE STATMENT"
  # make this script work no matter where it was called from
  BUILDER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

  # build docker imagecurl -k -u $bamboo_maven_user:$bamboo_maven_password -v "https://maven.earthdata.nasa.gov/repository/nsidc/
  DOCKER_IMAGE_TAG=lambda-builder
  docker build -t ${DOCKER_IMAGE_TAG} ${BUILDER_DIR}

  # run the build script on the docker container
  docker run \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v ${PROJECT_DIR}:${PROJECT_DIR} \
       -e PROJECT_DIR="${PROJECT_DIR}" \
       ${DOCKER_IMAGE_TAG}

# move the build artifact to current directory
  mv ${PROJECT_DIR}/lambda.zip ${LAMBDA_NAME}.zip
fi

echo $CURR_REQ_HASH > requirements-${LAMBDA_NAME}.txt.md5

curl -k --upload-file ${LAMBDA_NAME}.zip -u $bamboo_maven_user:$bamboo_maven_password -v "https://maven.earthdata.nasa.gov/repository/nsidc/"
curl -k --upload-file requirements-${LAMBDA_NAME}.txt.md5 -u $bamboo_maven_user:$bamboo_maven_password -v "https://maven.earthdata.nasa.gov/repository/nsidc/"

echo "Created ${LAMBDA_NAME}.zip"
