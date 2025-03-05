#!/bin/bash

####################################################
# Deploy the Kong API gateway and Curity HTTP routes
####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# First apply Kubernetes Gateway API custom resource definitions
#
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

CHART_VERSION='2.47.0'
if [ "$USE_PLUGINS" != 'true' ]; then

  #
  # Do a basic deployment of the API gateway
  #
  helm repo add kong https://charts.konghq.com
  helm repo update
  helm upgrade --install kong kong/kong \
    --version "$CHART_VERSION" \
    --namespace apigateway \
    --create-namespace \
    --set replicaCount=2 \
    --wait
  if [ $? -ne 0 ]; then
    exit 1
  fi

else

  #
  # Unzip the token handler zip file 
  #
  rm -rf download 2>/dev/null
  unzip token-handler-proxy-kong*.zip -d download
  if [ $? -ne 0 ]; then
    exit 1
  fi

  #
  # Build a custom Docker image
  #
  docker build --no-cache -t custom-kong:1.0.0 .
  if [ $? -ne 0 ]; then
    exit 1
  fi

  kind load docker-image custom-kong:1.0.0 --name demo
  if [ $? -ne 0 ]; then
    exit 1
  fi

  #
  # Deploy using a Helm values file
  #
  helm repo add kong https://charts.konghq.com
  helm repo update
  helm upgrade --install kong kong/kong \
    --version "$CHART_VERSION" \
    --values values.yaml \
    --namespace apigateway \
    --create-namespace
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

#
# Deploy base gateway resources
#
kubectl -n apigateway apply -f gateway.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create the API gateway's SSL certificate
#
kubectl -n apigateway apply -f ./external-certs/api-gateway-certificate.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
