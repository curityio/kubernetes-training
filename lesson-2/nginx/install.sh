#!/bin/bash

#####################################################
# Deploy the NGINX API gateway and Curity HTTP routes
#####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# As a basic way to enable retries of failed deployments, delete existing resources
#
kubectl delete namespace kong 2>/dev/null

#
# Deploy the API gateway
#
helm install nginx oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
  --namespace nginx \
  --create-namespace \
  --set nginxGateway.replicaCount=2 \
  --wait
if [ $? -ne 0 ]; then
  exit 1
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
# Expose HTTP routes for the admin and runtime workloads
#
kubectl -n curity apply -f ../../resources/idsvr/nginx-gateway-routes.yaml
if [ $? -ne 0 ]; then
  exit 1
fi