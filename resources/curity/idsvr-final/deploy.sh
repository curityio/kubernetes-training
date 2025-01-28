#!/bin/bash

######################################################################
# Deploy the admin and runtime workloads with the latest configuration
######################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# First check for a license key
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
kubectl create namespace curity                              2>/dev/null
kubectl -n curity create serviceaccount curity-idsvr-admin   2>/dev/null
kubectl -n curity create serviceaccount curity-idsvr-runtime 2>/dev/null

#
# Create a Kubernetes configmap with the configuration
#
kubectl -n curity delete configmap idsvr-config 2>/dev/null
kubectl -n curity create configmap idsvr-config \
  --from-file='idsvr-config=curity-config.xml'
if [ $? -ne 0 ]; then
  exit 1
fi

#
# The deployment uses parameterized and protected configuration
#
./crypto/create-parameters.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Use the Helm chart to run a phased zero downtime upgrade that keeps existing endpoints available
#
helm upgrade --install curity curity/idsvr -f values.yaml --namespace curity
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create a database configmap
#
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
