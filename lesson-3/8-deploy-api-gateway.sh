#!/bin/bash

####################################################################################################
# A script to spin up an NGINX or Kong API gateway and enable ingress for the Curity Identity Server
# This deployment extends lesson 2 to use HTTPS URLs whose issuance cert-manager initiates
####################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Apply Kubernetes Gateway API custom resource definitions
#
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml 2>/dev/null

#
# Then run the main gateway install
#
if [ "$PROVIDER_NAME" == 'kong' ]; then
  ./kong/install.sh
else
  ./nginx/install.sh
fi
if [ $? -ne 0 ]; then
  exit 1
fi
