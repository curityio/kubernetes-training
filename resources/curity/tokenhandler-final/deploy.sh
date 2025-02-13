#!/bin/bash

##################################################################################################
# Deploy the admin and runtime workloads of the Curity Token Handler with the latest configuration
##################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Validate input
#
if [ "$LICENSE_FILE_PATH" == '' ]; then
  echo '*** Please provide a LICENSE_FILE_PATH environment variable for the Curity Identity Server'
  exit 1
fi
export LICENSE_KEY=$(cat $LICENSE_FILE_PATH | jq -r .License)
if [ "$LICENSE_KEY" == '' ]; then
  echo '*** An invalid license file was provided for the Curity Identity Server'
  exit 1
fi

# 
# Create the namespace and service accounts if required
#
kubectl create namespace applications                                     2>/dev/null
kubectl -n applications create serviceaccount curity-tokenhandler-admin   2>/dev/null
kubectl -n applications create serviceaccount curity-tokenhandler-runtime 2>/dev/null

#
# Create a Kubernetes configmap with the configuration
#
kubectl -n applications delete configmap tokenhandler-config 2>/dev/null
kubectl -n applications create configmap tokenhandler-config \
  --from-file='tokenhandler-config=tokenhandler-config.xml'
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create cookie encryption keys used by both the OAuth Agent and OAuth Proxy
#
./cookie-keys/create.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Protect parameters and do other preprocessing
#
./parameters/create-parameters.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use the Helm chart to run an install or upgrade
#
# TODO: update once Helm chart updated
#helm upgrade --install curity curity/idsvr -f values.yaml --namespace applications
helm upgrade --install curity ../../../../idsvr-helm/idsvr -f values.yaml --namespace applications
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use routes to expose admin and OAuth Agent runtime endpoints
#
kubectl -n applications apply -f gateway-routes.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
