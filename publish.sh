#!/bin/bash
set -e

if [ -z $AWS_SECRET_ACCESS_KEY ] || [ -z $AWS_SECRET_ACCESS_KEY_ID ]; then
    echo "ERROR: AWS_SECRET_ACCESS_KEY or AWS_SECRET_ACCESS_KEY_ID is empty"
    exit 1
fi


USAGE="usage: publish.sh LAMBDA_ZIP CUMULUS_PREFIX [LAMBDA_NAME]"

LAMBDA_ZIP=$1
CUMULUS_PREFIX=$2
LAMBDA_NAME=$3

# ensure right number of args
if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
    echo $USAGE
    exit 1
fi

# ensure right kind of arg
if [ ! -f "${LAMBDA_ZIP}" ]; then
    echo $USAGE
    echo -e "\nERROR: LAMBDA_ZIP must be a zip file."
    exit 1
fi

if [ -z ${LAMBDA_NAME} ]; then
    LAMBDA_NAME=$(basename ${LAMBDA_ZIP})
    LAMBDA_NAME=${LAMBDA_NAME%.zip}
fi

BUCKET="${CUMULUS_PREFIX}-internal"
KEY="${CUMULUS_PREFIX}/lambdas/${LAMBDA_NAME}.zip"

echo "Publishing ${LAMBDA_ZIP} to s3://${BUCKET}/${KEY} and lambda ${CUMULUS_PREFIX}-${LAMBDA_NAME}"

# upload to S3
aws s3 cp ${LAMBDA_ZIP} s3://${BUCKET}/${KEY}

# create or update lambda
function_name="${CUMULUS_PREFIX}-${LAMBDA_NAME}"
(aws lambda get-function --function-name "${function_name}" &&
     aws lambda update-function-code \
         --function-name "${function_name}" \
         --s3-bucket "${BUCKET}" \
         --s3-key "${KEY}") ||
    aws lambda create-function \
        --function-name "${function_name}" \
        --code="S3Bucket=${BUCKET},S3Key=${KEY}"
        --handler "${LAMBDA_NAME}.lambda_handler"
