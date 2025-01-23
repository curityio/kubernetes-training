#!/bin/bash

#####################################################
# Run a redeployment that uses existing configuration
#####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Deploy the Curity product
#
../resources/idsvr/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use routes to expose OAuth endpoints
#
if [ "$GATEWAY_TYPE" == 'kong' ]; then
  kubectl -n curity apply -f ../resources/idsvr/kong-gateway-routes.yaml
else
  kubectl -n curity apply -f ../resources/idsvr/nginx-gateway-routes.yaml
fi
if [ $? -ne 0 ]; then
  exit 1
fi
