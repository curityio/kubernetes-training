#!/bin/bash

####################################################
# Deploy the Kong API gateway and Curity HTTP routes
####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# As a basic way to enable retries of failed deployments, delete existing resources
#
kubectl delete namespace kong 2>/dev/null

#
# Deploy the API gateway
#
helm repo add kong https://charts.konghq.com
helm repo update
helm upgrade --install kong kong/kong \
  --namespace kong \
  --create-namespace \
  --set replicaCount=2 \
  --set proxy.http.enabled=false \
  --wait
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Get the service's external IP address from the cloud provider
#
EXTERNAL_IP=$(kubectl -n kong get svc kong-kong-proxy -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "The load balancer external IP address is $EXTERNAL_IP"

#
# Deploy base gateway resources
#
kubectl -n kong apply -f kong-gateway.yaml
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
