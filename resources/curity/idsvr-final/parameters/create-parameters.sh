#!/bin/bash

##################################################################################
# Prepare configuration and secrets for a pipeline deployment that uses parameters
# This example generates new crypto keys for every deployment
##################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create a configuration encryption key for the deployment
#
CONFIG_ENCRYPTION_KEY=$(openssl rand 32 | xxd -p -c 64)

#
# Set system base URLs
#
RUNTIME_BASE_URL='https://login.testcluster.example'
ADMIN_BASE_URL='https://admin.testcluster.example'

#
# Create and hash the admin password
#
ADMIN_PASSWORD_RAW='Password1'
ADMIN_PASSWORD=$(openssl passwd -5 $ADMIN_PASSWORD_RAW)

#
# Create the plaintext database connection details
#
DB_NAME='idsvr'
DB_USER='idsvr'
DB_DRIVER='org.postgresql.Driver'
DB_PASSWORD_RAW='Password1'
DB_CONNECTION_RAW="jdbc:postgresql://postgres-svc/$DB_NAME"

#
# Create the symmetric key used to encrypt SSO cookies
#
SYMMETRIC_KEY_RAW=$(openssl rand 32 | xxd -p -c 64)

#
# Create the token signing private key and public key
#
openssl genrsa -out signing.key 2048
openssl req -new -nodes -key signing.key -out signing.csr -subj "/CN=curity.signing"
openssl x509 -req -in signing.csr -signkey signing.key -out signing.crt -sha256 -days 365
openssl pkcs12 -export -inkey signing.key -in signing.crt -name curity.signing -out signing.p12 -passout pass:Password1
rm signing.csr
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating token signing keys'
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
# Get the SQL init script from the running container, which the database deployment uses
#
docker cp curity:/opt/idsvr/etc/postgres-create_database.sql ../database/dbinit.sql
if [ $? -ne 0 ]; then
  echo "*** Problem encountered copying the database script"
  exit 1
fi

#
# Copy the encryption script to the container
#
echo 'Protecting secure environment variables ...'
docker cp ../../utils/encrypt-util.sh curity:/tmp/
docker exec -i curity bash -c 'chmod +x /tmp/encrypt-util.sh'

#
# Use the encryption script to get the encrypted DB password
#
DB_PASSWORD=$(docker exec -i curity bash -c "TYPE=plaintext PLAINTEXT='$DB_PASSWORD_RAW' ENCRYPTIONKEY='$CONFIG_ENCRYPTION_KEY' /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "*** Problem encountered encrypting the DB password: $DB_PASSWORD"
  exit 1
fi

#
# Use the encryption script to get the encrypted DB connection
#
DB_CONNECTION=$(docker exec -i curity bash -c "TYPE=plaintext PLAINTEXT='$DB_CONNECTION_RAW' ENCRYPTIONKEY='$CONFIG_ENCRYPTION_KEY' /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "*** Problem encountered encrypting the DB connection: $DB_CONNECTION"
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
# Convert the token signing key from a P12 to the Curity protected format
#
SIGNING_KEY_BASE64="$(openssl base64 -in signing.p12 | tr -d $LINE_SEPARATOR)"
SIGNING_KEY_RAW=$(docker exec -i curity bash -c "convertks --in-password Password1 --in-alias curity.signing --in-entry-password Password1 --in-keystore '$SIGNING_KEY_BASE64'")
if [ $? -ne 0 ]; then
  echo "*** Problem encountered converting the token signing key: $SIGNING_KEY_RAW"
  exit 1
fi

#
# Use the encryption script to get the encrypted token signing key
#
SIGNING_KEY=$(docker exec -i curity bash -c "TYPE=base64keystore PLAINTEXT='$SIGNING_KEY_RAW' ENCRYPTIONKEY='$CONFIG_ENCRYPTION_KEY' /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "*** Problem encountered encrypting the token signing key: $SIGNING_KEY"
  exit 1
fi

#
# Create a configmap containing unprotected environment variables
#
kubectl -n curity create configmap idsvr-parameters \
  --from-literal="RUNTIME_BASE_URL=$RUNTIME_BASE_URL" \
  --from-literal="ADMIN_BASE_URL=$ADMIN_BASE_URL" \
  --from-literal="DB_USER=$DB_USER" \
  --from-literal="DB_DRIVER=$DB_DRIVER"
if [ $? -ne 0 ]; then
  echo "Problem encountered creating the Kubernetes configmap containing unprotected environment variables"
  exit 1
fi

#
# Create a secret containing protected environment variables
#
kubectl -n curity create secret generic idsvr-protected-parameters \
  --from-literal="ADMIN_PASSWORD=$ADMIN_PASSWORD" \
  --from-literal="DB_PASSWORD=$DB_PASSWORD" \
  --from-literal="DB_CONNECTION=$DB_CONNECTION" \
  --from-literal="SYMMETRIC_KEY=$SYMMETRIC_KEY" \
  --from-literal="SIGNING_KEY=$SIGNING_KEY" \
  --from-literal="LICENSE_KEY=$LICENSE_KEY" \
  --from-literal="CONFIG_ENCRYPTION_KEY=$CONFIG_ENCRYPTION_KEY"
if [ $? -ne 0 ]; then
  echo "Problem encountered creating the Kubernetes secret containing protected environment variables"
  exit 1
fi
