#!/bin/bash
set -e

for var in "$@"
do
    if [ -z "${!var}" ]; then
        echo "No value found for ${var}, skipping."
    else
        echo "Adding value of ${var} to .bamboo_env_vars"
        echo "export ${var}=\"${!var}\"" >> .bamboo_env_vars
    fi
done
