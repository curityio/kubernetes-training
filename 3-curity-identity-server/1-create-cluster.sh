#!/bin/bash

###############################################
# A script to create a development KIND cluster
###############################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/cluster/create.sh
if [ $? -ne 0 ]; then
  exit 1
fi

