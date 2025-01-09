#!/bin/bash

###############################################
# A script to create a development KIND cluster
###############################################

cd "$(dirname "${BASH_SOURCE[0]}")"

kind create cluster --name=demo --config=../resources/cluster.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
