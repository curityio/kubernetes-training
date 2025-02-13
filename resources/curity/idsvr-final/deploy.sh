#!/bin/bash

#####################################################################################################
# Deploy the admin and runtime workloads for the Curity Identity Server with the latest configuration
#####################################################################################################

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
# Create a custom Dockerfile with shared resources for all stages of the deployment pipeline
#
docker build --no-cache -t custom_idsvr:1.0.0 .
if [ $? -ne 0 ]; then
  exit 1
fi

kind load docker-image custom_idsvr:1.0.0 --name demo
if [ $? -ne 0 ]; then
  exit 1
fi

# 
# Create the namespace and service accounts if required
#
kubectl create namespace curity                              2>/dev/null
kubectl -n curity create serviceaccount curity-idsvr-admin   2>/dev/null
kubectl -n curity create serviceaccount curity-idsvr-runtime 2>/dev/null

#
# Protect parameters and do other preprocessing
#
./parameters/create-parameters.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create a database script configmap
#
kubectl -n curity delete configmap sql-init-script 2>/dev/null
kubectl -n curity create configmap sql-init-script --from-file='database/dbinit.sql'
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the SQL database and use external storage for a development computer
#
kubectl -n curity apply -f database/postgres.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use the Helm chart to run an install or upgrade
#
# TODO: update once Helm chart updated
#helm upgrade --install curity curity/idsvr -f values.yaml --namespace curity
helm upgrade --install curity ../../../../idsvr-helm/idsvr -f values.yaml --namespace curity
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use routes to expose admin and OAuth endpoints
#
kubectl -n curity apply -f gateway-routes.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

