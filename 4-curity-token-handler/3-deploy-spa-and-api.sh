#!/bin/bash

##########################################
# Build and deploy the example SPA and API
##########################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/spa-and-api/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

../resources/spa-and-api/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi
