#!/bin/bash

######################################################################################
# A script to spin up an API gateway and enable ingress for the Curity Identity Server
######################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/api-gateway/install.sh
if [ $? -ne 0 ]; then
  exit 1
fi
