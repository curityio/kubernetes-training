#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create crypto keys according to tutorials
#
TH_COOKIE_KEY_PASS='Password1'
openssl ecparam -name prime256v1 -genkey -noout -out private.key
openssl ec -in private.key -pubout -out public.crt
openssl pkcs8 -topk8 -in private.key -out private-key.pkcs8 -passout pass:"$TH_COOKIE_KEY_PASS"
rm private.key
if [ $? -ne 0 ]; then
  exit 1
fi
