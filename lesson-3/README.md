# Update External OAuth Endpoints to HTTPS

Provides HTTPS external base URLs for the admin and runtime workloads.

## Install the Cloud Provider KIND

Deploy the components that provides external load balancers in the same way as lesson 2:

```bash
./6-run-load-balancer.sh
```

## Install Cert Manager

Run a script that creates a root certificate authority and installs cert-manager ready to use it.\
If required, study the YAML resources and update them to match your deployment.

```bash
./7-prepare-external-certificates.sh
```

## Install the API Gateway

Next deploy the NGINX API gateway with routes to the admin and runtime workloads.\
If required, study the YAML resources and update them to match your deployment.

```bash
export PROVIDER_NAME='nginx'
./8-deploy-api-gateway.sh
```

If you prefer, use the Kong API gateway instead:

```bash
export PROVIDER_NAME='kong'
./8-deploy-api-gateway.sh
```

When the script completes you see output similar to this:

```text
The API gateway external IP address is 172.20.0.5
```

## Access External OAuth Endpoints

If you selected `All options` in the first configuration you can call external OAuth endpoints.\
To use domain based URLs correctly on a development computer, add entries like these to your `/etc/hosts` file:

```text
172.20.0.5 admin.testcluster.example login.testcluster.example
```

Reach external URLs at these addresses:

```bash
curl -i -k https://admin.testcluster.example/admin
curl -i -k https://login.testcluster.example/oauth/v2/oauth-anonymous/.well-known/openid-configuration
```

## Access External Token Handler Endpoints

If you selected `Token Handler only` in the first configuration you can call different external endpoints.\
To use domain based URLs correctly on a development computer, add entries like these to your `/etc/hosts` file:

```text
172.20.0.5 admin.testcluster.example api.demoapp.example
```

Reach external URLs at these addresses:

```bash
curl -i -k https://admin.testcluster.example/admin
curl -i -k -X POST https://api.demoapp.example/oauthagent/example/login/start \
    -H 'origin: https://www.demoapp.example' \
    -H 'token-handler-version: 1'
```
