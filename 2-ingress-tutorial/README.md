# API Gateways, Ingress and External URLs

Provides external OAuth HTTPS URLs for the admin and runtime workloads.

## Prerequisites

First ensure that you have completed the [basic tutorial](../1-basic-tutorial/README.md).\
Then switch to the `2-ingress-tutorial` folder and use the following instructions.

## Design External URLs

The example deployment uses the following base URLs for the Curity Identity Server:

- Admin UI Base URL: `https://admin.testcluster.example`
- OAuth Base URL: `https://login.testcluster.example`

If you are running just the Curity Token Handler, the example uses the following base URLs.\
The token handler base URL has the same parent domain as a web app, which might run at `https://www.demoapp.example`.

- Admin UI Base URL: `https://admin.testcluster.example`
- Token Handler Base URL: `https://api.demoapp.example`

## 1. Install the Load Balancer Provider

The [cloud-provider-kind](https://github.com/kubernetes-sigs/cloud-provider-kind) development component watches for Kubernetes services of type LoadBalancer.\
Upon creation of such a service, the provider creates an external IP address and spins up an `envoyproxy` Docker load balancer that uses it.\
This requires sudo access on macOS, or if you use Windows Git bash you should run a local administrator shell:

```bash
./1-run-load-balancer.sh
```

## 2. Prepare API Gateway Certificate Issuance

In another terminal window install cert-manager and create a certifificate issuer:

```bash
./2-create-external-certificate-issuer.sh
```

To prevent browser SSL trust warnings for the deployed cluster, trust the root certificate for external URLs.\
For example, add this root certificate file to the system keychain on macOS:

```text
resources/api-gateway/external-certs/testcluster.ca.crt
```

## 3. Deploy the API Gateway

This tutorial uses the Kong API gateway but you may be able to adapt the deployment for other API gateways.\
The ingress resources use the newer [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/):

```bash
./3-deploy-api-gateway.sh
```

Study the scripts and YAML resources to understand the use of HTTP routes that expose OAuth endpoints.\
When the script completes you see output like this:

```text
The API gateway external IP address is 172.20.0.5
```

If you inspect Kubernetes services, notice that the load balancer IP address is assigned to the API gateway's service:

```bash
kong       kong-kong-proxy      LoadBalancer   10.96.200.210   172.20.0.5    80:32742/TCP,443:32181/TCP
```

## 4. Expose Curity API Gateway Routes

Run the following command to deploy the Curity product with ingress routes:

```bash
./4-expose-curity.sh
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
curl -k https://login.testcluster.example/oauth/v2/oauth-anonymous/.well-known/openid-configuration
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
