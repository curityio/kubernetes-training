#!/bin/bash

######################################################
# An advanced API gateway deployment that uses plugins
######################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

export USE_PLUGINS='true'
../resources/api-gateway/install.sh
if [ $? -ne 0 ]; then
  exit 1
fi
