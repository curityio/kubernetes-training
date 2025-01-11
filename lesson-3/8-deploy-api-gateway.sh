#!/bin/bash

####################################################################################################
# A script to spin up an NGINX or Kong API gateway and enable ingress for the Curity Identity Server
# This deployment extends lesson 2 to use HTTPS URLs whose issuance cert-manager initiates
####################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Default to NGINX but allow an environment variable to select Kong
#
if [ "$PROVIDER_NAME" != 'kong' ]; then
  PROVIDER_NAME='nginx'
fi

#
# Apply Kubernetes Gateway API custom resource definitions
#
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Then run the main gateway install
#
if [ "$PROVIDER_NAME" == 'nginx' ]; then
  ./nginx/install.sh
else
  ./kong/install.sh
fi
if [ $? -ne 0 ]; then
  exit 1
fi
