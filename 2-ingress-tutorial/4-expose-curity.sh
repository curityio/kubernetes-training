#!/bin/bash

###################################################
# Run a redeployment that applies ingress behaviors
###################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
../resources/curity/ingress/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi
