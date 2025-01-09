#!/bin/bash

####################################################################################################
# A script to spin up an NGINX or Kong API gateway and enable ingress for the Curity Identity Server
####################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "$PROVIDER_NAME" != 'kong' ]; then
  PROVIDER_NAME='kong'
fi

if [ "$PROVIDER_NAME" == 'nginx' ]; then

  #
  # Apply custom resource definitions
  #
  kubectl apply -f "https://github.com/nginxinc/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v1.5.1"
  if [ $? -ne 0 ]; then
    exit 1
  fi
  
  #
  # Deploy the API gateway
  #
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm install ngf oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
    --namespace nginx-gateway \
    --create-namespace \
    --set service.create=false \
    --set replicaCount=2
  if [ $? -ne 0 ]; then
    exit 1
  fi

  #
  # Wait for it to come up
  #
  kubectl wait --namespace nginx-gateway \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s

  #
  # Get the service's external IP address from the cloud provider
  #
  EXTERNAL_IP=$(kubectl get svc -n nginx-gateway ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  echo "The load balancer external IP address is $EXTERNAL_IP"

  #
  # Deploy base gateway resources
  #
  kubectl -n nginx-gateway apply -f nginx-gateway.yaml
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
  # Apply custom resource definitions
  #
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
  if [ $? -ne 0 ]; then
    exit 1
  fi
  
  #
  # Deploy the API gateway
  #
  helm repo add kong https://charts.konghq.com
  helm repo update
  helm upgrade --install kong kong/kong \
    --namespace kong \
    --create-namespace \
    --set replicaCount=2
  if [ $? -ne 0 ]; then
    exit 1
  fi

  #
  # Wait for it to come up
  #
  kubectl wait --namespace kong \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=app \
    --timeout=90s

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
  # Expose HTTP routes for the admin and runtime workloads
  #
  kubectl -n curity apply -f kong-curity-ingress.yaml
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
