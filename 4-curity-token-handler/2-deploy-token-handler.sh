#!/bin/bash

###############################################################
# Run the final example deployment for the Curity Token Handler
###############################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/curity/tokenhandler-final/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi
