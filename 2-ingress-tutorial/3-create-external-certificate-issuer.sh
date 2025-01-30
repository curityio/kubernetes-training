#!/bin/bash

###################################################################################
# A script to spin up cert-manager ready to issue external API gateway certificates
###################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
../resources/api-gateway/external-certs/create-issuer.sh
