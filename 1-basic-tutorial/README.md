# Basic Example

This example provides a basic deployment to showcase initial Kubernetes deployments and upgrades of the admin workload, runtime workload and configuration.

## Prerequisites

Ensure that a Docker engine and [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/docs/user/quick-start/) are installed.\
Also ensure that the Docker engine is configured with at least 8GB of RAM.\
Also download a license file for the Curity Identity Server from the [Curity developer portal](https://developer.curity.io/).

## 1. Create the Cluster

Navigate to the  `1-basic-tutorial` folder and run the following command:

```bash
./1-create-cluster.sh
```

## 2. Run the Initial Installation

Deploy the Curity product and wait for pods to come up.\
Study the script to understand the use of a config encryption key and a Helm chart values file:

```bash
./2-install-curity.sh
```

Expose the admin pod's HTTP endpoint using port forwarding:

```bash
ADMIN_POD="$(kubectl -n curity get pod -l 'role=curity-idsvr-admin' -o jsonpath='{.items[0].metadata.name}')"
kubectl -n curity port-forward "$ADMIN_POD" 6749
```

Then log in to the Admin UI with these details:

- URL: `http://localhost:6749/admin`
- Username: admin
- Password: Password1

Complete the first configuration to make HTTP endpoints available:

- [First Configuration for the Curity Identity Server](https://curity.io/resources/learn/first-config/)
- [First Configuration for the Curity Token Handler](https://curity.io/resources/learn/token-handler-first-configuration/)

In the Admin UI, use **Changes / Download** and save the configuration to a file named `curity-config.xml` in the `resources/curity/basic` folder.\
Expose the runtime pod's HTTP endpoint using port forwarding:

```bash
RUNTIME_POD="$(kubectl -n curity get pod -l 'role=curity-idsvr-runtime' -o jsonpath='{.items[0].metadata.name}' | tail -n 1)"
kubectl -n curity port-forward "$RUNTIME_POD" 8443
```

If you selected `All options` in the first configuration you can call OAuth endpoints:

```bash
curl -i http://localhost:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration
```

If you selected `Token Handler only` in the first configuration you can call an OAuth Agent endpoint at your configured path:

```bash
curl -i -X POST http://localhost:8443/oauthagent/example/login/start \
    -H 'origin: https://www.demoapp.example' \
    -H 'token-handler-version: 1'
```

## 3. Run Upgrades with the Latest Configuration

Run a zero downtime upgrade of the Curity product with the backed up configuration.\
Study the script to understand how it supplies existing configuration values with a configmap and secret.

```bash
./3-upgrade-curity.sh
```

During the upgrade, watch how the platform replaces pods in a phased manner:

```bash
kubectl -n curity get pod -n curity --watch
```

Old pods are not removed until new pods are ready, so that OAuth endpoints remain available.

```text
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
curity               curity-idsvr-admin-5bbb5fb5f7-d8d95          0/1     Running   0          11s
curity               curity-idsvr-admin-79d794588b-jqr8q          1/1     Running   0          18m
curity               curity-idsvr-runtime-675cbbc4c-qm76z         1/1     Running   0          18m
curity               curity-idsvr-runtime-675cbbc4c-zsks5         1/1     Running   0          18m
curity               curity-idsvr-runtime-77b5dbd5c7-c57xs        0/1     Running   0          11s
```

## Next Steps

Congratulations, you've deployed and updated your first cluster of the Curity Identity Server or Curity Token Handler with the Helm chart. In the [2-ingress-tutorial](/2-ingress-tutorial/README.md) you can learn how to enable external URLs for the cluster instead of relying on port forwarding to access the endpoints of the services.
