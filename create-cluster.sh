#!/bin/bash

###############################################################
# A script to create a Minikube cluster on a standalone machine
###############################################################

#
# Create or start the cluster
#
minikube start --cpus=2 --memory=8192 --disk-size=50g --profile curity
if [ $? -ne 0 ];
then
  echo "Minikube start problem encountered"
  exit 1
fi

#
# Ensure that components can be exposed from the cluster over port 443 to the developer machine
#
minikube addons enable ingress --profile curity
if [ $? -ne 0 ]
then
  echo "*** Problem encountered enabling the ingress addon for the cluster ***"
  exit 1
fi

#
# Create a secret for the SSL wildcard certificate for *.curitylocal.io
#
kubectl delete secret curitylocal-io-tls 2>/dev/null
kubectl create secret tls curitylocal-io-tls --cert=./certs/curitylocal.io.ssl.pem --key=./certs/curitylocal.io.ssl.key
if [ $? -ne 0 ]
then
  echo "*** Problem encountered creating the secret for the ingress SSL certificate ***"
  exit 1
fi

#
# Free memory by stopping the profile or delete the profile permanently if you prefer
# - minikube stop --profile curity
# - minikube delete --profile curity
#