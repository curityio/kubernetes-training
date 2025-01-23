#!/bin/bash

####################################################################################
# The initial deployment of admin and runtime workloads with a config encryption key
####################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
cd ../resources/idsvr

#
# Get Helm resources
#
helm repo add curity https://curityio.github.io/idsvr-helm
helm repo update

# 
# Create the namespace and service accounts if required
#
kubectl create namespace curity
kubectl -n curity create serviceaccount curity-idsvr-admin
kubectl -n curity create serviceaccount curity-idsvr-runtime

#
# Create a new config encryption key
#
if [ ! -f encryption.key ]; then
  openssl rand 32 | xxd -p -c 64 > encryption.key
fi
CONFIG_ENCRYPTION_KEY=$(cat encryption.key)

#
# Run the Helm chart and generate a new configuration
#
helm upgrade --install curity curity/idsvr -f values-initial.yaml --namespace curity \
  --set curity.config.password='Password1' \
  --set curity.config.encryptionKey="$CONFIG_ENCRYPTION_KEY" \
  --wait
if [ $? -ne 0 ]; then
  exit 1
fi
