#!/bin/bash

#######################################################
# A script to use OpenSSL to create an external root CA
#######################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

case "$(uname -s)" in

  # macOS
  Darwin)
    export OPENSSL_CONF='/System/Library/OpenSSL/openssl.cnf'
 	;;

  # Windows with Git Bash
  MINGW64*)
    export OPENSSL_CONF='C:/Program Files/Git/usr/ssl/openssl.cnf';
    export MSYS_NO_PATHCONV=1;
	;;

  # Linux
  Linux*)
    export OPENSSL_CONF='/usr/lib/ssl/openssl.cnf';
	;;
esac

#
# Require OpenSSL 3 so that up to date syntax can be used
#
OPENSSL_VERSION_3=$(openssl version | grep 'OpenSSL 3')
if [ "$OPENSSL_VERSION_3" == '' ]; then
  echo 'Please install openssl version 3 or higher before running this script'
fi

#
# Do nothing if the files already exist on disk, to avoid the need for host reconfiguration
#
if [ -f "testcluster.ca.key" ]; then
  exit 0
fi

#
# Create the root private key
#
echo 'Creating a development certificate authority to issue API gateway certificates ...'
openssl ecparam -name prime256v1 -genkey -noout -out testcluster.ca.key
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Root CA key'
  exit 1
fi

#
# Create the root certificate file with a 10 year lifetime
#
openssl req \
    -x509 \
    -new \
    -key testcluster.ca.key \
    -out testcluster.ca.crt \
    -subj "/CN=Development CA for testcluster.example" \
    -addext 'basicConstraints=critical,CA:TRUE' \
    -days 3650
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Root CA'
  exit 1
fi
