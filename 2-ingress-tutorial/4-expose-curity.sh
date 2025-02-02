#!/bin/bash

#####################################################
# Run a redeployment that uses existing configuration
#####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
cd ../resources/curity/basic

#
# Use routes to expose OAuth endpoints
#
kubectl -n curity apply -f gateway-routes.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
