#!/bin/bash

######################################################################
# Deploy the SPA and API with their environment specific configuration
######################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

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
kubectl -n applications apply -f gateway-routes.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
