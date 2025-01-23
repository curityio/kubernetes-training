# Kubernetes Getting Started

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

Starter resources for developers to run the Curity product in Kubernetes:

- Deployments use similar concepts to real environments on a local computer.
- Enables local execution of OAuth flows and planning of deployments.

The resources work the same for both of these scenarios unless otherwise stated:

- The full Curity Identity Server that provides a complete OAuth authorization server.
- The Curity Token Handler, which processes cookies sent by Single Page Applications.

## Fast Deployment

If you just want to spin up a working local Kubernetes deployment you can:

- Follow the [README instructions](./final/README.md) to run a series of scripts.

To learn more about the details, follow the instructional lessons in sequence.

## Lessons

### 1 - Deployment, Configuration and Upgrades

Follow the [README instructions](./lesson-1/README.md) to learn how to:

- Run the Helm chart with a values file to control the deployment.
- Access the admin UI and download the initial generated configuration.
- Run zero downtime upgrades and include the latest configuration.

### 2 - API Gateway Integration and External URLs

Follow the [README instructions](./lesson-2/README.md) to learn how to:

- Run a load balancer and get an external IP address.
- Run the Curity Identity Server behind an API gateway.
- Expose the admin UI and runtime endpoints using domain based URLs.

### 3 - HTTPS External URLs with Certificate Auto Renewal

Follow the [README instructions](./lesson-3/README.md) to learn how to:

- Update the domain based URLs to use HTTPS.
- Automate external certificate issuance using cert-manager.
- Automate certificate renewal and reloading of the external certificate by the API gateway.

### 4 - API Gateway Plugin Integration (for Curity Token Handler)

Follow the [README instructions](./lesson-4/README.md) to learn how to:

- Deploy plugins with the API gateway to perform token translation tasks.
- Use the Phantom Token plugin to handle introspection of opaque access tokens.
- Use the OAuth Proxy plugin to process cookies from Single Page Applications.

### 5 - SQL Database Storage (for Curity Identity Server)

Follow the [README instructions](./lesson-5/README.md) to learn how to:

- Redeploy the Curity Idemtity Server using SQL database storage for identity data.
- Query the database to view stored identity data including user accounts.
- Use external storage to avoid data loss if you recreate Kubernetes pods, nodes or the entire cluster.

### 6 - Deployment Pipeline

Follow the [README instructions](./lesson-5/README.md) to learn how to:

- Parameterize Curity Identity Server configuration to reduce duplication for a deployment pipeline.
- Split the configuration into multiple files and ship them in a custom Docker image.
- Protect secure values in the configuration.

## Free Resources

You can remove the test cluster and free resources when you have finished testing:

```bash
./delete-cluster.sh
```

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
