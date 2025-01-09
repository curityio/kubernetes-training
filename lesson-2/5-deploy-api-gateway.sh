#!/bin/bash

####################################################################################################
# A script to spin up an NGINX or Kong API gateway and enable ingress for the Curity Identity Server
####################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Default to NGINX but allow an environment variable to select Kong
#
if [ "$PROVIDER_NAME" != 'kong' ]; then
  PROVIDER_NAME='nginx'
fi

#
# Apply Kubernetes Gateway API custom resource definitions
#
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$PROVIDER_NAME" == 'nginx' ]; then
  
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
  kubectl -n curity apply -f nginx-curity-ingress.yaml
  if [ $? -ne 0 ]; then
    exit 1
  fi

else

  #
  # Deploy the API gateway
  #
  helm repo add kong https://charts.konghq.com
  helm repo update
  helm upgrade --install kong kong/kong \
    --namespace kong \
    --create-namespace \
    --set replicaCount=2 \
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
  # Enable HTTP routes for the admin and runtime workloads
  #
  kubectl -n curity apply -f kong-curity-ingress.yaml
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi
