#!/bin/bash
set -e

if [ -z $AWS_SECRET_ACCESS_KEY ] || [ -z $AWS_SECRET_ACCESS_KEY_ID ]; then
    echo "ERROR: AWS_SECRET_ACCESS_KEY or AWS_SECRET_ACCESS_KEY_ID is empty"
    exit 1
fi


USAGE="usage: publish.sh LAMBDA_ZIP CUMULUS_PREFIX [LAMBDA_NAME] [RELEASE_NAME]"

LAMBDA_ZIP=$1
CUMULUS_PREFIX=$2
LAMBDA_NAME=$3
RELEASE_NAME=$4

# ensure right number of args
if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
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

BUCKET="${CUMULUS_PREFIX}-artifacts"
KEY="lambdas/${LAMBDA_NAME}"
if [ ! -z "${RELEASE_NAME}" ]; then
    KEY="${KEY}-${RELEASE_NAME}"
fi
KEY="${KEY}.zip"

echo "Publishing ${LAMBDA_ZIP} to s3://${BUCKET}/${KEY} and lambda ${CUMULUS_PREFIX}-${LAMBDA_NAME}"

# upload to S3
aws s3 cp ${LAMBDA_ZIP} s3://${BUCKET}/${KEY}

AWS_ACCOUNT_ID=$(aws sts get-caller-identity| grep 'Account' | cut -d '"' -f 4)

# create or update lambda
function_name="${CUMULUS_PREFIX}-${LAMBDA_NAME}"
(aws lambda get-function --function-name "${function_name}" &&
     aws lambda update-function-code \
         --function-name "${function_name}" \
         --s3-bucket "${BUCKET}" \
         --s3-key "${KEY}") ||
    echo "lambda function '${function_name}' not found; lambda function must be created via terraform deployment"
