#!/bin/bash

#########################################################################################
# Deploy the admin and runtime workloads with ingress routes and the latest configuration
#########################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

# 
# Create the namespace and service accounts if required
#
kubectl create namespace curity                              2>/dev/null
kubectl -n curity create serviceaccount curity-idsvr-admin   2>/dev/null
kubectl -n curity create serviceaccount curity-idsvr-runtime 2>/dev/null

#
# Use the existing config encryption key
#
CONFIG_ENCRYPTION_KEY=$(cat encryption.key)

#
# Create a Kubernetes configmap with the configuration
#
kubectl -n curity delete configmap idsvr-config 2>/dev/null
kubectl -n curity create configmap idsvr-config \
  --from-file='idsvr-config=curity-config.xml'
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create a Kubernetes secret with the config encryption key
#
kubectl -n curity delete secret generic idsvr-secrets 2>/dev/null
kubectl -n curity create secret generic idsvr-secrets \
  --from-literal="CONFIG_ENCRYPTION_KEY=$CONFIG_ENCRYPTION_KEY"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use the Helm chart to run a phased zero downtime upgrade that keeps existing endpoints available
#
helm upgrade --install curity curity/idsvr -f values.yaml --namespace curity
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use routes to expose OAuth endpoints
#
kubectl -n curity apply -f gateway-routes.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
