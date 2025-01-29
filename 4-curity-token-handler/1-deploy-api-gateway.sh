#!/bin/bash

###################################################################################
# A script to run NGINX or Kong API gateways in Kubernetes while also using plugins
###################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create cookie encryption keys used by both the API gateway and the OAuth Proxy
#
../resources/api-gateway/cookie-keys/create.sh
if [ $? -ne 0 ]; then
  exit 1
fi
