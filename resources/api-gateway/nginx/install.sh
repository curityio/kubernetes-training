#!/bin/bash

#####################################################
# Deploy the NGINX API gateway and Curity HTTP routes
#####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "$USE_PLUGINS" != 'true' ]; then

  #
  # Do a basic deployment of the API gateway
  #
  helm install nginx oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
    --namespace nginx \
    --create-namespace \
    --set nginxGateway.replicaCount=2 \
    --wait
  if [ $? -ne 0 ]; then
    exit 1
  fi

else 

  #
  # Unzip the token handler zip file 
  #
  rm -rf download 2>/dev/null
  unzip token-handler-proxy-nginx*.zip -d download
  if [ $? -ne 0 ]; then
    exit 1
  fi

  echo 'look see'
  exit 1

  #
  # Build a custom Docker image
  #
  docker build --no-cache -t custom-nginx:1.0.0 .
  if [ $? -ne 0 ]; then
    exit 1
  fi

  kind load docker-image custom-nginx:1.0.0 --name demo
  if [ $? -ne 0 ]; then
    exit 1
  fi

  #
  # Deploy using a Helm values file
  #
  helm install nginx oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
    --namespace nginx \
    --create-namespace \
    --set nginxGateway.replicaCount=2 \
    --wait
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

#
# Get the service's external IP address from the cloud provider
#
EXTERNAL_IP=$(kubectl get svc -n nginx nginx-nginx-gateway-fabric -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "The load balancer external IP address is $EXTERNAL_IP"

#
# Deploy base gateway resources
#
kubectl -n nginx apply -f nginx-gateway.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create the API gateway's SSL certificate
#
kubectl -n nginx apply -f ../external-certs/api-gateway-certificate.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
