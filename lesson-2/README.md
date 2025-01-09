# Enable External OAuth Endpoints

Provides external base URLs for the admin and runtime workloads at these URLs:

- Admin UI Base URL: `http://admin.testcluster.example`
- OAuth Base URL: `http://login.testcluster.example`

## Install the Cloud Provider KIND

The [cloud-provider-kind](https://github.com/kubernetes-sigs/cloud-provider-kind) development component watches for Kubernetes services of type LoadBalancer.\
When one is installed, the provider creates an external IP address and spins up an `envoyproxy` Docker load balancer that uses it.\
This requires sudo access on macOS - if you use Windows Git bash you should run a local administrator shell:

```bash
./4-run-load-balancer.sh
```

## Install the API Gateway

In another terminal window install either the NGINX API gateway:

```bash
export PROVIDER_NAME='nginx'
./5-deploy-api-gateway.sh
```

Or the Kong NGINX API gateway:

```bash
export PROVIDER_NAME='kong'
./5-deploy-api-gateway.sh
```

The ingress resources use the future proof versions of NGINX and Kong that use the newer [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/):

- [NGINX Gateway](https://docs.nginx.com/nginx-gateway-fabric/get-started/)
- [Kong Gateway](https://docs.konghq.com/gateway-operator/latest/get-started/kic/create-gateway/)

Study the scripts and YAML resources to understand the use of HTTP routes that expose OAuth endpoints.\
When the script completes you see output like this:

```text
The API gateway external IP address is 172.20.0.8
```

If you inspect Kubernetes services, notice that the load balancer IP address is assigned to the API gateway's service:

```bash
kong          kong-kong-proxy                LoadBalancer   10.96.200.210   172.20.0.8    80:32742/TCP,443:32181/TCP
```

## Call External OAuth Endpoints

The API gateway service routes requests to one of the API gateway pods and from there to the Curity Identity Server.\
The API gateway uses hostname based routing and identifies the HTTP route to use from the incoming host header.\
Call the external admin endpoint with the following command:

```bash
curl -i http://172.20.0.8/admin -H "Host: http://admin.testcluster.example"
```

Similarly, you can reach external OAuth endpoints with commands of this form:

```bash
curl -i http://172.20.0.8/oauth/v2/oauth-anonymous/.well-known/openid-configuration -H "Host: http://login.testcluster.example"
```

To use the domain based URLs correctly on a development computer, add entries like this to your `/etc/hosts` file:

```text
172.20.0.8 admin.testcluster.example login.testcluster.example
```

You can then access these URLs in a browser:

- `http://admin.testcluster.example`
- `http://login.testcluster.example/oauth/v2/oauth-anonymous/.well-known/openid-configuration`
