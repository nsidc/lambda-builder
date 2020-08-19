#!/bin/bash
set -e


# Required environment variables in bamboo:
#
# REPO=${bamboo.REPO}

tar -cvzf lambda-builder.tar.gz lambda-builder ${REPO}
