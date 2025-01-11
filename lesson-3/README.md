# Update External OAuth Endpoints to HTTPS

Provides HTTPS external base URLs for the admin and runtime workloads at these URLs:

- Admin UI Base URL: `https://admin.testcluster.example`
- OAuth Base URL: `https://login.testcluster.example`

## Install the Cloud Provider KIND

Deploy the components that provides external load balancers in the same way as lesson 2:

```bash
./6-run-load-balancer.sh
```

## Install Cert Manager

Run a script that creates a root certificate authority and installs cert-manager ready to use it:

```bash
./7-prepare-external-certificates.sh
```

## Install the API Gateway

Deploy the components that provides external load balancers in the same way as lesson 2:

```bash
export PROVIDER_NAME='nginx'
./8-deploy-api-gateway.sh
```

Or the Kong NGINX API gateway:

```bash
export PROVIDER_NAME='kong'
./8-deploy-api-gateway.sh
```

When the script completes you see output like this:

```text
The API gateway external IP address is 172.20.0.8
```

## Access External OAuth Endpoints

To use the domain based URLs correctly on a development computer, add entries like these to your `/etc/hosts` file:

```text
172.20.0.8 admin.testcluster.example login.testcluster.example
```

You can then access these URLs in a browser or using direct HTTP requests:

```bash
curl -i -k https://admin.testcluster.example/admin
curl -i -k https://login.testcluster.example/oauth/v2/oauth-anonymous/.well-known/openid-configuration
```

When HTTPS certificates expire cert-manager renews them automatically.\
The API gateway's Kubernetes controller should detect changes to Kubernetes secrets and reloads certificates.
