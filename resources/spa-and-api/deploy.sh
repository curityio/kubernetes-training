#!/bin/bash

######################################################################
# Deploy the SPA and API with their environment specific configuration
######################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Validate input
#
if [ "$GATEWAY_TYPE" != 'nginx' ] && [ "$GATEWAY_TYPE" != 'kong' ]; then
  echo '*** Please provide a GATEWAY_TYPE environment variable'
  exit 1
fi

#
# Create configmaps for the SPA and API
#
kubectl -n applications create configmap spa-config     --from-file='config.json=config/spa-config.json'
kubectl -n applications create configmap webhost-config --from-file='config.json=config/webhost-config.json'
kubectl -n applications create configmap demoapi-config --from-file='config.json=config/demoapi-config.json'
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the components 
#
kubectl -n applications apply -f webhost.yaml
kubectl -n applications apply -f demoapi.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use routes to expose endpoints from the cluster
#
if [ "$GATEWAY_TYPE" == 'kong' ]; then
  kubectl -n applications apply -f kong-gateway-routes.yaml
else
  kubectl -n applications apply -f nginx-gateway-routes.yaml
fi
if [ $? -ne 0 ]; then
  exit 1
fi
