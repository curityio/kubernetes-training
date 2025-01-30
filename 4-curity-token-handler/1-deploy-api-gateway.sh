#!/bin/bash

###################################################################################
# A script to run NGINX or Kong API gateways in Kubernetes while also using plugins
###################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
cd ../resources/api-gateway

#
# Validate input
#
if [ "$GATEWAY_TYPE" != 'nginx' ] && [ "$GATEWAY_TYPE" != 'kong' ]; then
  echo '*** Please provide a GATEWAY_TYPE environment variable'
  exit 1
fi

#
# Then redeploy the main gateway and set an advanced option to use plugins
#
export USE_PLUGINS='true'
if [ "$GATEWAY_TYPE" == 'kong' ]; then
  ./kong/install.sh
else
  ./nginx/install.sh
fi
if [ $? -ne 0 ]; then
  exit 1
fi
