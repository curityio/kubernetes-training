# API Gateways, Ingress and External URLs

This training example provides external OAuth HTTPS URLs for the admin and runtime workloads on a local computer to reflect a production-like deployment.

## Prerequisites

First ensure that you have deployed the [basic example](../1-basic-tutorial/README.md).\
Then continue with the following instructions.

## Design External URLs

This example deployment uses the following base URLs for the Curity Identity Server:

- Admin UI Base URL: `https://admin.testcluster.example`
- OAuth Base URL: `https://login.testcluster.example`

If you are running just the Curity Token Handler, the example uses the following base URLs.\
The token handler base URL has the same parent domain as a web app, which might run at `https://www.demoapp.example`.

- Admin UI Base URL: `https://admin.testcluster.example`
- Token Handler Base URL: `https://api.demoapp.example`

## 1. Install the Load Balancer Provider

The [cloud-provider-kind](https://github.com/kubernetes-sigs/cloud-provider-kind) development component watches for Kubernetes Services of type LoadBalancer.\
Upon creation of such a service, the provider creates an external IP address and spins up an `envoyproxy` Docker container to expose the service and to provide a load balancer on the local computer.\
This requires sudo access on macOS. If you use Windows Git bash, run the script from a local administrator shell:

```bash
./1-run-load-balancer.sh
```

## 2. Prepare API Gateway Certificate Issuance

In another terminal window install cert-manager and create a certificate issuer:

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

Inspect the Kubernetes services in the `apigateway` namespace.

```bash
kubectl -n apigateway get service
```

Notice that the local load balancer's IP address is assigned to the API gateway's service as its external IP.
Notice that the external IP address of the API gateway's LoadBalancer service is the same as IP address of the local load balancer.

```bash
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)
kong-kong-proxy      LoadBalancer   10.96.200.210   172.20.0.5    80:32742/TCP,443:32181/TCP
```

## 4. Expose Curity API Gateway Routes

Run the following command to deploy the Curity product with ingress routes:

```bash
./4-expose-curity.sh
```

### Use External URLs for the Curity Identity Server

If you selected `All options` in the first configuration you can call external OAuth endpoints.\
To use domain based URLs correctly on a development computer, add entries like these to your `/etc/hosts` file, where `172.20.0.5` is the IP address that the local load balancer listens to. It is also the external IP of the Kubernetes Service of type LoadBalancer.

```text
172.20.0.5 admin.testcluster.example login.testcluster.example
```

Reach external URLs at addresses such as these:

```bash
curl -i -k https://admin.testcluster.example/admin
curl -k https://login.testcluster.example/oauth/v2/oauth-anonymous/.well-known/openid-configuration
```

> [!TIP]
> The above command disables certificate verification because, by default, curl is not able to establish the trust chain for the custom certificate and certificate verification fails. If you add the CA certificate to the system's trust store (e.g. keychain), you can run `curl` with `--ca-native`. In this way, you can validate the certificate chain and confirm that the API gateway indeed uses a trusted certificate.
>
> ```bash
> curl -i --ca-native https://admin.testcluster.example/admin
> ```
>
> Alternatively, use the option `--cacert` and point to the CA certificate at `/resources/api-gateway/external-certs/testcluster.ca.crt` for certificate verification.
>
> ```bash
> curl -i --cacert ../resources/api-gateway/external-certs/testcluster.ca.crt https://admin.testcluster.example/admin
> ````
>

### Use External URLs for the Curity Token Handler

If you selected `Token Handler only` in the first configuration, you can call different external endpoints.\
To be able to use the domain-based URLs correctly on a development computer, add entries like these to your `/etc/hosts` file, where `172.20.0.5` is the IP address that the local load balancer listens to. It is also the external IP of the Kubernetes Service of type LoadBalancer.

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

## Next Steps

Congratulations, you're now able to access the endpoints of the services via external URLs. The tutorial in `3-curity-identity-server` demonstrates a final setup of the Curity Identity Server that includes a load balancer, API gateway, external certificates and database.