#!/bin/bash

#####################################################
# Run a redeployment that uses existing configuration
#####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Deploy the Curity product
#
../resources/curity/basic/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi
