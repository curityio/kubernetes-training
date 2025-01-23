# Kubernetes Getting Started

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

Starter resources for developers to run the Curity product in Kubernetes:

- Deployments use similar concepts to real environments on a local computer.
- Enables local execution of OAuth flows and planning of deployments.

## Deployments

The resources work for both the Curity Identity Server and the Curity Token Handler.\
You can run a particular tutorial or just jump to the final tutorial for a complete deployment.

### 1 - Basic Tutorial

Follow the [README instructions](./1-basic-tutorial/README.md) to learn how to:

- Run the Helm chart with a values file to control the deployment.
- Access the admin UI and download the initial generated configuration.
- Run zero downtime upgrades and include the latest configuration.

### 2 - API Gateways, Ingress and External URLs

Follow the [README instructions](./2-ingress-tutorial/README.md) to learn how to:

- Use a development load balancer and get an external IP address.
- Run the Curity Identity Server behind an API gateway.
- Expose the admin UI and runtime endpoints using domain based URLs.
- Use cert-manager to update URLs to use HTTPS.

### 3 - Use Data Sources and Persistent Volumes

Follow the [README instructions](./3-persistent-volumes/README.md) to learn how to:

- Use persistent volumes to store configuration or data.
- Query the database to view stored identity data including user accounts.

### 4 - Final Tutorial

Follow the [README instructions](./4-/README.md) to learn how to:

- Parameterize and protect configuration data for a deployment pipeline.
- Customize the API gateway to include plugins for the phantom token and token handler.
- Deploy both the Curity Identity Server and Curity Token Handler as distinct Kubernetes services.

### Free Resources

You can remove the test cluster and free resources when you have finished testing:

```bash
./delete-cluster.sh
```

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
