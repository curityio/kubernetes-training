#!/bin/bash

########################################################################
# A script to run cloud provider KIND to spin up external load balancers
########################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/cloudprovider/run.sh
if [ $? -ne 0 ]; then
  exit 1
fi
