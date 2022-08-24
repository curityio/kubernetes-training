#!/bin/bash

#########################################################################
# A script to clean up resources once finished with the demo installation
#########################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
minikube delete --profile curity
