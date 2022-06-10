#!/bin/bash

#####################################################################################
# Deploy a basic Postgres instance without any persistent volumes
# The Curity Identity Server will connect to it via this JDBC URL inside the cluster:
# - jdbc:postgresql://postgres-svc/idsvr?serverTimezone=Europe/Stockholm
#####################################################################################

#
# Point to our minikube profile
#
eval $(minikube docker-env --profile curity)
minikube profile curity
if [ $? -ne 0 ]; then
  echo "Minikube problem encountered - please ensure that the service is started"
  exit 1
fi

#
# Tear down the instance and lose all data, which will be reapplied from the backup
#
kubectl delete -f postgres/service.yaml 2>/dev/null

#
# Copy in the init script to restore data, which includes our test user account
#
kubectl delete configmap init-script-configmap 2>/dev/null
kubectl create configmap init-script-configmap --from-file='./postgres/idsvr-data-backup.sql'

#
# Deploy a postgres instance
#
kubectl apply -f postgres/service.yaml
if [ $? -ne 0 ]; then
  echo "Problem encountered deploying the PostgreSQL service"
  exit 1
fi

#
# Once the pod comes up we can connect to it as follows from the MacBook, if a PostgreSQL client is installed:
# - export PGPASSWORD=Password1 && psql -h $(minikube ip --profile curity) -p 30432 -d idsvr -U postgres
#
# From Curity containers inside the cluster we can connect via the following command:
# - export PGPASSWORD=Password1 && psql -p 5432 -d idsvr -U postgres
#
