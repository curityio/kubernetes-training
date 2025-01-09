# Initial Deployment and Upgrade

Initial Kubernetes deployments of the admin workload, runtime workload and configuration.

## Prerequisites

Ensure that a Docker engine and [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/docs/user/quick-start/) are installed.\
Also ensure that the Docker engine is installed sufficient resources, including 8GB of RAM.\
Also download a license file for the Curity Identity Server from the [Curity developer portal](https://developer.curity.io/).

## First Deployment

Create the cluster:

```bash
./1-create-cluster.sh
```

Deploy the Curity Identity Server and wait for pods to come up.\
Study the script to understand the use of a config encryption key and a Helm chart values file:

```bash
./2-deploy-idsvr.sh
```

## Run the Initial Configuration

Expose the admin pod's HTTP endpoint using port forwarding:

```bash
ADMIN_POD="$(kubectl -n curity get pod -l 'role=curity-idsvr-admin' -o jsonpath='{.items[0].metadata.name}')"
kubectl -n curity port-forward "$ADMIN_POD" 6749
```

Then log in to the Admin UI with these details:

- URL: `http://localhost:6749/admin`
- Username: admin
- Password: Password1

Complete the [First Configuration](https://curity.io/resources/learn/first-config/) select `All options` and all defaults, to make OAuth endpoints are available.\
In the Admin UI, use **Changes / Download** to save the configuration to the current folder in a file named `curity-config.xml`.

## Call OAuth Endpoints

Expose the runtime pod's HTTP endpoint using port forwarding:

```bash
RUNTIME_POD="$(kubectl -n curity get pod -l 'role=curity-idsvr-runtime' -o jsonpath='{.items[0].metadata.name}' | tail -n 1)"
kubectl -n curity port-forward "$RUNTIME_POD" 8443
```

Call the OpenID Connect metadata endpoint that external clients often call.\
Once the JSON download succeds you have working OAuth endpoints.

```bash
curl http://localhost:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration
```

## Run Upgrades with the Latest Configuration

Run a zero downtime upgrade of the Curity Identity Server with the backed up configuration.\
During this time, OAuth endpoints remain available as the platform creates new pods in a phased manner.\
Study the script to understand how it supplies existing configuration values with a configmap and secret.

```bash
./3-upgrade-idsvr.sh
```
