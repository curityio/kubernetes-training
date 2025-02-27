#!/bin/bash

######################################################################################
# A script to spin up an API gateway and enable ingress for the Curity Identity Server
######################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
cd ../resources/api-gateway

#
# Apply Kubernetes Gateway API custom resource definitions
#
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

#
# Then run the main API gateway install
#
./install.sh
if [ $? -ne 0 ]; then
  exit 1
fi
