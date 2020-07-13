#!/bin/bash
set -e

USAGE="usage: publish.sh LAMBDA_ZIP CUMULUS_PREFIX"

# ensure right number of args
if [ "$#" -ne 2 ]; then
    echo $USAGE
    exit 1
fi

# ensure right kind of arg
LAMBDA_ZIP=$1
if [ ! -f "${LAMBDA_ZIP}" ]; then
    echo $USAGE
    echo -e "\nERROR: LAMBDA_ZIP must be a zip file."
    exit 1
fi

CUMULUS_PREFIX=$2

LAMBDA_NAME=$(basename ${LAMBDA_ZIP})
LAMBDA_NAME=${LAMBDA_NAME%.zip}

BUCKET="${CUMULUS_PREFIX}-internal"
KEY="${CUMULUS_PREFIX}/lambdas/${LAMBDA_NAME}.zip"

# upload to S3
aws s3 cp ${LAMBDA_ZIP} s3://${BUCKET}/${KEY}

# update lambda
aws lambda update-function-code \
    --function-name "${CUMULUS_PREFIX}-${LAMBDA_NAME}" \
    --s3-bucket "${BUCKET}" \
    --s3-key "${KEY}"
