#!/bin/bash
set -e

# Called in Bamboo "DeployToSandbox" job, "Final task" like this:
#
# ./lambda-builder/bamboo/task_final_deploy.sh

echo ${BASH_SOURCE[0]}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source .bamboo_env_vars || true

# if status was never updated to success, it failed
if [ "${STATUS}" = "pending" ]; then
    export STATUS=failure
    export DESCRIPTION="Deployment failed"

    ${SCRIPT_DIR}/add-to-env-file.sh \
        STATUS \
        DESCRIPTION
fi

# only update status if we're deploying
if [ "${DEPLOYING}" = "true" ]; then
    ${SCRIPT_DIR}/set-github-status.sh
fi

# clean up env vars file
rm -v .bamboo_env_vars
