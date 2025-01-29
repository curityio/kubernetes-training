# Kubernetes Training

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

Training resources for developers to run the Curity product in Kubernetes:

- Deployments use similar concepts to real environments on a local computer.
- Enables local execution of OAuth flows and planning of real deployments.

## Deployments

The resources work for both the Curity Identity Server and the Curity Token Handler.\
You can run tutorials in sequence or just jump to the final tutorials for a working deployment.

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
- Use cert-manager to issue TLS certificates to enable HTTPS URLs.

### 3 - Final Curity Identity Server Tutorial

Follow the [README instructions](./3-curity-identity-server/README.md) to learn how to:

- Use a SQL database with persistent storage of identity data like user accounts.
- Use the DevOps Dashboard to create test user accounts for your OAuth applications.
- Use configuration best practices for a deployment pipeline.

### 4 - Final Curity Token Handler Tutorial

Follow the [README instructions](./4-curity-token-handler/README.md) to learn how to:

- Update the API gateway deployment to use plugins.
- Deploy the Curity Token Handler to Kubernetes using configuration best practices for a deployment pipeline.
- Run an end-to-end token handler flow that uses an example Single Page Application and REST API.
- Configure API gateway routes to APIs to use the OAuth Proxy and Phantom Token plugins.

### Free Resources

You can remove the test cluster and free resources when you have finished testing:

```bash
./delete-cluster.sh
```

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
