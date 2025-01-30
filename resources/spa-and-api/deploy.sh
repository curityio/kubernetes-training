#!/bin/bash

######################################################################
# Deploy the SPA and API with their environment specific configuration
######################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create configmaps for the SPA and API
#
kubectl -n applications create configmap spa-config     --from-file='config.json=config/spa-config.json'
kubectl -n applications create configmap webhost-config --from-file='config.json=config/webhost-config.json'
kubectl -n applications create configmap demoapi-config --from-file='config.json=config/demoapi-config.json'
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the components 
#
kubectl -n applications apply -f webhost.yaml
kubectl -n applications apply -f demoapi.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Get the password protected cookie encryption key details
#
TH_COOKIE_KEY_PASS='Password1'
TH_COOKIE_KEY="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ../curity/tokenhandler-final/cookie-keys/private-key.pkcs8)"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Dynamically create the file for the OAuth Proxy plugin
#
cat << EOF > routes/oauth-proxy-plugin.yaml
kind: KongPlugin
apiVersion: configuration.konghq.com/v1
metadata:
  name: oauth-proxy
plugin: oauth-proxy
config:
  cookie_key: "$TH_COOKIE_KEY"
  cookie_key_pass: $TH_COOKIE_KEY_PASS
EOF

#
# Apply plugins and then routes for the applications namespace
#
kubectl -n applications apply -f routes/phantom-token-plugin.yaml
kubectl -n applications apply -f routes/cors-plugin.yaml
kubectl -n applications apply -f routes/oauth-proxy-plugin.yaml
kubectl -n applications apply -f routes/application-routes.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Add routes to expose endpoints from the cluster and to apply plugins
#
kubectl -n curity apply -f routes/cors-plugin.yaml
kubectl -n curity apply -f routes/oauth-proxy-plugin.yaml
kubectl -n curity apply -f routes/userinfo-route.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
