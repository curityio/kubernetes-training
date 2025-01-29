#!/bin/bash

################################################################################################
# Prepare configuration and secrets for a token handler pipeline deployment that uses parameters
################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create a configuration encryption key for the deployment
#
CONFIG_ENCRYPTION_KEY=$(openssl rand 32 | xxd -p -c 64)

#
# Configure Admin UI details
#
ADMIN_BASE_URL='https://admin.demoapp.example'
ADMIN_PASSWORD_RAW='Password1'
ADMIN_PASSWORD=$(openssl passwd -5 $ADMIN_PASSWORD_RAW)

#
# Configure base URLS
#
AUTHORIZATION_SERVER_BASE_URL='https://login.testcluster.example'
SPA_BASE_URL='https://www.demoapp.example'

#
# Configure the web client secret
#
SPA_CLIENT_SECRET_RAW='Password1'
SPA_CLIENT_SECRET=$(openssl passwd -5 $SPA_CLIENT_SECRET_RAW)

#
# Set details related to the OAuth proxy
#
OAUTH_PROXY_TYPE='kong'
TH_COOKIE_CERT="$(openssl base64 -in ../../../api-gateway/cookie-keys/public.crt | tr -d '\n')"
if [ $? -ne 0 ]; then
  echo '*** Unable to load the token handler public key'
  exit 1
fi

#
# Create a configmap containing unprotected environment variables
#
kubectl -n applications create configmap idsvr-parameters \
  --from-literal="ADMIN_BASE_URL=$ADMIN_BASE_URL" \
  --from-literal="AUTHORIZATION_SERVER_BASE_URL=$AUTHORIZATION_SERVER_BASE_URL" \
  --from-literal="SPA_BASE_URL=$SPA_BASE_URL" \
  --from-literal="OAUTH_PROXY_TYPE=$OAUTH_PROXY_TYPE"
if [ $? -ne 0 ]; then
  echo "Problem encountered creating the Kubernetes configmap containing unprotected environment variables"
  exit 1
fi

#
# Create a secret containing protected environment variables
#
kubectl -n applications create secret generic idsvr-protected-parameters \
  --from-literal="ADMIN_PASSWORD=$ADMIN_PASSWORD" \
  --from-literal="SPA_CLIENT_SECRET=$SPA_CLIENT_SECRET" \
  --from-literal="TH_COOKIE_CERT=$TH_COOKIE_CERT" \
  --from-literal="LICENSE_KEY=$LICENSE_KEY" \
  --from-literal="CONFIG_ENCRYPTION_KEY=$CONFIG_ENCRYPTION_KEY"
if [ $? -ne 0 ]; then
  echo "Problem encountered creating the Kubernetes secret containing protected environment variables"
  exit 1
fi
