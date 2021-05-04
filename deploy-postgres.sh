#!/bin/bash

#####################################################################################
# Deploy a basic Postgres instance without any persistent volumes
# The Curity Identity Server will connect to it via this JDBC URL inside the cluster:
# - jdbc:postgres://postgres-svc/idsvr?serverTimezone=Europe/Stockholm
#####################################################################################

#
# Point to our minikube profile
#
eval $(minikube docker-env --profile curity)
minikube profile curity
if [ $? -ne 0 ];
then
  echo "Minikube problem encountered - please ensure that the service is started"
  exit 1
fi

#
# Tear down the instance and lose all data, which will be reapplied from the backup
#
kubectl delete -f postgres/service.yaml 2>/dev/null

#
# Build a custom docker image containing backed up data
#
docker build -f postgres/Dockerfile -t custom_postgres:13.2 .
if [ $? -ne 0 ];
then
  echo "Problem encountered building the custom PostgreSQL docker image"
  exit 1
fi

#
# Deploy the postgres instance
#
kubectl apply -f postgres/service.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered deploying the PostgreSQL service"
  exit 1
fi

#
# Once the pod comes up we can connect to it as follows from the MacBook, if a PostgreSql client is installed:
# - psql -h $(minikube ip --profile curity) -p 30432 -d idsvr -U root -pPassword1
#
# From Curity containers inside the cluster we can use the following command:
# - psql -h postgres-svc -p 5432 -d idsvr -U root -pPassword1
#