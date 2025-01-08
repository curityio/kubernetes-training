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
kubectl create namespace curity                              2>/dev/null
kubectl -n curity create serviceaccount curity-idsvr-admin   2>/dev/null
kubectl -n curity create serviceaccount curity-idsvr-runtime 2>/dev/null

if [ ! -f encryption.key ]; then

  #
  # Create a new config encryption key
  #
  openssl rand 32 | xxd -p -c 64 > encryption.key
  CONFIG_ENCRYPTION_KEY=$(cat encryption.key)

  #
  # Run the Helm chart and generate a new configuration
  #
  helm upgrade --install curity curity/idsvr --values=./values-initial.yaml --namespace curity \
    --set curity.config.password='Password1' \
    --set curity.config.encryptionKey="$CONFIG_ENCRYPTION_KEY"
  if [ $? -ne 0 ]; then
    exit 1
  fi

else

  #
  # Use the existing config encryption key
  #
  CONFIG_ENCRYPTION_KEY=$(cat encryption.key)

  #
  # Create a Kubernetes configmap with the configuration
  #
  kubectl -n curity create configmap idsvr-configbackup \
    --from-file='config-backup.xml'
  if [ $? -ne 0 ]; then
    exit 1
  fi

  #
  # Create a Kubernetes secret with the config encryption key
  #
  kubectl -n curity create secret generic idsvr-secrets \
    --from-literal="$CONFIG_ENCRYPTION_KEY"
  if [ $? -ne 0 ]; then
    exit 1
  fi
  
  #
  # Run the Helm chart with the existing configuration
  #
  helm upgrade --install curity curity/idsvr --values=./values-redeloy.yaml --namespace curity
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi
