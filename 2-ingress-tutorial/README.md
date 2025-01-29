# API Gateways, Ingress and External URLs

Provides external OAuth HTTPS URLs for the admin and runtime workloads.

## Prerequisites

First ensure that you have completed the [basic tutorial](../1-basic-tutorial/README.md) so that expected resources are available on disk.

## Design External URLs

If you are running the full Curity Identity Server you might design the following base URLs for a test system:

- Admin UI Base URL: `http://admin.testcluster.example`
- OAuth Base URL: `http://login.testcluster.example`

If you are running just the Curity Token Handler, you might instead use the following base URLs for a test system.\
The token handler base URL has the same parent domain as a web app, which might run at `http://www.demoapp.example`.

- Admin UI Base URL: `http://admin.testcluster.example`
- Token Handler Base URL: `http://api.demoapp.example`

## 1. Create a Cluster

Delete the existing cluster if it exists and then create a new cluster with the scripts from this tutorial's folder:

```bash
./1-create-cluster.sh
```

## 2. Install the Load Balancer Provider

The [cloud-provider-kind](https://github.com/kubernetes-sigs/cloud-provider-kind) development component watches for Kubernetes services of type LoadBalancer.\
When one is installed, the provider creates an external IP address and spins up an `envoyproxy` Docker load balancer that uses it.\
This requires sudo access on macOS - if you use Windows Git bash you should run a local administrator shell:

```bash
./2-run-load-balancer.sh
```

## 3. Prepare SSL Certificates

In another terminal window install cert-manager and prepare it for certificate issuance:

```bash
./3-prepare-external-certificates.sh
```

To prevent browser SSL trust warnings for the deployed cluster, trust the root certificate for external URLs.\
For example, add this root certificate file to the system keychain on macOS:

```text
resources/api-gateway/external-certs/testcluster.ca.crt
```

## 4. Deploy the API Gateway

This tutorial supports either the Kong or NGINX API gateways or you could adapt the deployment to support a different gateway.\
Provide a `GATEWAY_TYPE` of either `nginx` or `kong`:

```bash
export GATEWAY_TYPE='nginx'
./4-deploy-api-gateway.sh
```

The ingress resources use the future proof versions of NGINX and Kong that use the newer [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/):

- [NGINX Gateway](https://docs.nginx.com/nginx-gateway-fabric/get-started/)
- [Kong Gateway](https://docs.konghq.com/gateway-operator/latest/get-started/kic/create-gateway/)

Study the scripts and YAML resources to understand the use of HTTP routes that expose OAuth endpoints.\
When the script completes you see output like this:

```text
The API gateway external IP address is 172.20.0.5
```

If you inspect Kubernetes services, notice that the load balancer IP address is assigned to the API gateway's service:

```bash
kong       kong-kong-proxy      LoadBalancer   10.96.200.210   172.20.0.5    80:32742/TCP,443:32181/TCP
```

## 5. Deploy the Curity Product

Run the following command and and set a `GATEWAY_TYPE` of either `nginx` or `kong` for the ingress:

```bash
export GATEWAY_TYPE='nginx'
./5-deploy-curity.sh
```

### Configure DNS for the Curity Identity Server

If you selected `All options` in the first configuration you can call external OAuth endpoints.\
To use domain based URLs correctly on a development computer, add entries like these to your `/etc/hosts` file:

```text
172.20.0.5 admin.testcluster.example login.testcluster.example
```

Reach external URLs at addresses such as these:

```bash
curl -i -k https://admin.testcluster.example/admin
curl -k https://login.testcluster.example/oauth/v2/oauth-anonymous/.well-known/openid-configuration | jq
```

### Configure DNS for the Curity Token Handler

If you selected `Token Handler only` in the first configuration you can call different external endpoints.\
To use domain based URLs correctly on a development computer, add entries like these to your `/etc/hosts` file:

```text
172.20.0.5 admin.testcluster.example api.demoapp.example
```

Reach external URLs at addresses such as these:

```bash
curl -i -k https://admin.testcluster.example/admin
curl -i -k -X POST https://api.demoapp.example/oauthagent/example/login/start \
    -H 'origin: https://www.demoapp.example' \
    -H 'token-handler-version: 1'
```
