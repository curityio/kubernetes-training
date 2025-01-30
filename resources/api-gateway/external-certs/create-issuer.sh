#!/bin/bash

###################################################################################
# A script to spin up cert-manager ready to issue external API gateway certificates
###################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# As a basic way to enable retries of failed deployments, delete existing resources
#
kubectl delete namespace cert-manager 2>/dev/null

#
# Install cert-manager
#
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set crds.enabled=true \
    --wait
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create a root CA if required
#
./create-root-ca.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create a Kubernetes secret from the root CA files
#
kubectl -n cert-manager create secret tls external-rootca-secret \
  --cert='testcluster.ca.crt' \
  --key='testcluster.ca.key'
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the external root CA secret'
  exit 1
fi

#
# Create the certificate issuer for API gateway certificates
#
kubectl -n cert-manager apply -f api-gateway-issuer.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the external certificate issuer'
  exit 1
fi
