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

#
# Set cookie encryption and OAuth proxy details
#
SYMMETRIC_KEY_RAW=$(openssl rand 32 | xxd -p -c 64)
TH_COOKIE_CERT_RAW="$(openssl base64 -in ../cookie-keys/public.crt | tr -d '\n')"
if [ $? -ne 0 ]; then
  echo '*** Unable to load the token handler public key'
  exit 1
fi

#
# Run a temporary instance of the Curity Identity Server docker container to perform encryption related tasks
#
docker rm -f curity 1>/dev/null 2>&1
docker run -d -p 6749:6749 -e PASSWORD=Password1 --user root --name curity curity.azurecr.io/curity/idsvr:latest 1>/dev/null
if [ $? -ne 0 ]; then
  echo '*** Problem encountered running the utility docker image'
  exit 1
fi
trap 'docker rm -f curity 1>/dev/null 2>&1' EXIT

#
# Wait for its admin endpoint to become available
#
echo 'Waiting for the temporary idsvr docker container, which will perform encryption tasks ...'
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "https://localhost:6749/admin/login/login.html")" != '200' ]; do
  sleep 2
done

#
# Copy the encryption script to the container
#
echo 'Protecting secure environment variables ...'
docker cp ../../utils/encrypt-util.sh curity:/tmp/
docker exec -i curity bash -c 'chmod +x /tmp/encrypt-util.sh'

#
# Use the encryption script to get the protected client secret
#
SPA_CLIENT_SECRET=$(docker exec -i curity bash -c "TYPE=plaintext PLAINTEXT='$SPA_CLIENT_SECRET_RAW' ENCRYPTIONKEY='$CONFIG_ENCRYPTION_KEY' /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "*** Problem encountered encrypting the SPA client secret: $SPA_CLIENT_SECRET"
  exit 1
fi

#
# Use the encryption script to get the encrypted symmetric key
#
SYMMETRIC_KEY=$(docker exec -i curity bash -c "TYPE=plaintext PLAINTEXT='$SYMMETRIC_KEY_RAW' ENCRYPTIONKEY='$CONFIG_ENCRYPTION_KEY' /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "*** Problem encountered encrypting the symmetric key: $SYMMETRIC_KEY"
  exit 1
fi

#
# Use the encryption script to get the encrypted cookie certificate
#
TH_COOKIE_CERT=$(docker exec -i curity bash -c "TYPE=base64keystore PLAINTEXT='$TH_COOKIE_CERT_RAW' ENCRYPTIONKEY='$CONFIG_ENCRYPTION_KEY' /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "*** Problem encountered encrypting the token signing key: $TH_COOKIE_CERT"
  exit 1
fi

#
# Create a configmap containing unprotected environment variables
#
kubectl -n applications create configmap idsvr-parameters \
  --from-literal="ADMIN_BASE_URL=$ADMIN_BASE_URL" \
  --from-literal="AUTHORIZATION_SERVER_BASE_URL=$AUTHORIZATION_SERVER_BASE_URL" \
  --from-literal="SPA_BASE_URL=$SPA_BASE_URL" \
  --from-literal="OAUTH_PROXY_TYPE=$GATEWAY_TYPE"
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
  --from-literal="SYMMETRIC_KEY=$SYMMETRIC_KEY" \
  --from-literal="LICENSE_KEY=$LICENSE_KEY" \
  --from-literal="CONFIG_ENCRYPTION_KEY=$CONFIG_ENCRYPTION_KEY"
if [ $? -ne 0 ]; then
  echo "Problem encountered creating the Kubernetes secret containing protected environment variables"
  exit 1
fi
