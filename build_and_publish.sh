#!/bin/bash
set -e

USAGE="usage: build_and_publish.sh PROJECT_DIR LAMBDA_NAME CUMULUS_PREFIX"

# ensure right number of args
if [ "$#" -ne 3 ]; then
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

LAMBDA_NAME=$2
CUMULUS_PREFIX=$3

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

${THIS_DIR}/build.sh ${PROJECT_DIR} ${LAMBDA_NAME}

${THIS_DIR}/publish.sh ${PROJECT_DIR}/${LAMBDA_NAME}.zip ${CUMULUS_PREFIX}
