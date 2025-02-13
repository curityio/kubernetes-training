#!/bin/bash

#########################################################################################
# Deploy the admin and runtime workloads with ingress routes and the latest configuration
#########################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Redeploy with an updated values.yaml file that updates the network policy to expose the Admin UI
#
# TODO: update once Helm chart updated
#helm upgrade --install curity curity/idsvr -f values.yaml --namespace curity
helm upgrade --install curity ../../../../idsvr-helm/idsvr -f values.yaml --namespace curity
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Apply routes to expose OAuth endpoints
#
kubectl -n curity apply -f gateway-routes.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
