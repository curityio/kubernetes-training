#!/bin/bash

#####################################################
# Run a redeployment that uses existing configuration
#####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Run the final example deployment for the Curity Identity Server
#
../resources/curity/idsvr-final/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi
