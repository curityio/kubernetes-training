#!/bin/bash

################################################################
# Deploy the Curity Identity Server with encrypted configuration
################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

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
if [ ! -f ../resources/encryption.key ]; then
  openssl rand 32 | xxd -p -c 64 > ../resources/encryption.key
fi
CONFIG_ENCRYPTION_KEY=$(cat ../resources/encryption.key)

#
# Run the Helm chart and generate a new configuration
#
helm upgrade --install curity curity/idsvr -f values-initial.yaml --namespace curity \
  --set curity.config.password='Password1' \
  --set curity.config.encryptionKey="$CONFIG_ENCRYPTION_KEY"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Wait for pods to come up
#
kubectl wait --namespace curity \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=idsvr \
  --timeout=90s
