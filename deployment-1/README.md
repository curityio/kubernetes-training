# Initial Deployments

Initial deployments of the admin workload runtime workload and configuration.

## Prerequisites

Ensure that Docker and KIND are installed.

## First Deployment

Create the cluster:

```bash
./1-create-cluster.sh
```

Deploy the Curity Identity Server:

```bash
./2-deploy-idsvr.sh
```

## Run the Initial Configuration

Expose the admin pod's HTTP endpoint using port forwarding:

```bash
ADMIN_POD="$(kubectl -n curity get pod -l 'role=curity-idsvr-admin' -o jsonpath='{.items[0].metadata.name}')"
kubectl -n curity port-forward "$ADMIN_POD" 6749
```

Then complete the initial setup wizard and upload a license, after which OAuth endpoints are available.\
Back up the configuration to the current folder in a file named `curity-config.xml`

## Call OAuth Endpoints

Expose the runtime pod's HTTP endpoint using port forwarding:

```bash
RUNTIME_POD="$(kubectl -n curity get pod -l 'role=curity-idsvr-runtime' -o jsonpath='{.items[0].metadata.name}' | tail -n 1)"
kubectl -n curity port-forward "$RUNTIME_POD" 8443
```

Get OpenID Connect metadata:

```bash
curl http://localhost:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration
```

## Subsequent Deployments

Redeploy the Curity Identity Server with the backed up configuration and the same encryption key:

```bash
./2-deploy-idsvr.sh
```
