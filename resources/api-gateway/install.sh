#!/bin/bash

####################################################
# Deploy the Kong API gateway and Curity HTTP routes
####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

CHART_VERSION='2.47.0'
if [ "$USE_PLUGINS" != 'true' ]; then

  #
  # Do a basic deployment of the API gateway
  #
  helm repo add kong https://charts.konghq.com
  helm repo update
  helm upgrade --install kong kong/kong \
    --version "$CHART_VERSION" \
    --namespace kong \
    --create-namespace \
    --set replicaCount=2 \
    --set proxy.http.enabled=false \
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
    --namespace kong \
    --create-namespace \
    --wait
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

#
# Get the service's external IP address from the cloud provider
#
EXTERNAL_IP=$(kubectl -n kong get svc kong-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "The load balancer external IP address is $EXTERNAL_IP"

#
# Deploy base gateway resources
#
kubectl -n kong apply -f gateway.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create the API gateway's SSL certificate
#
kubectl -n kong apply -f ./external-certs/api-gateway-certificate.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
