#!/bin/bash

##############################################################################################
# Run a zero downtime upgrade of the admin and runtime workloads with the latest configuration
##############################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/idsvr/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi