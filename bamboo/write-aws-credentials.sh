#!/bin/bash
set -e

source .bamboo_env_vars || true

AWS_CREDENTIALS_FILE=$(pwd)/aws/credentials

mkdir -p aws
cat << EOF > ${AWS_CREDENTIALS_FILE}
[${AWS_PROFILE}]
aws_access_key_id = ${AWS_SECRET_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

echo "Wrote ${AWS_CREDENTIALS_FILE}"
