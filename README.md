# Kubernetes Getting Started

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

Starter resources for developers to run the Curity Identity Server in Kubernetes:
- Use similar concepts to deployed environments on a local computer.
- Enables local execution of OAuth flows and planning of deployments.

## Lesson 1 - Deployment, Configuration and Upgrades

Follow the [README instructions](./lesson-1/README.md) to learn how to:

- Run the Helm chart with a values file to control the deployment.
- Access the admin UI and download the initial generated configuration.
- Run zero downtime upgrades and include the latest configuration.

## Lesson 2 - Ingress and External URLs

Follow the [README instructions](./lesson-2/README.md) to learn how to:

- Run a load balancer and get an external IP address.
- Run the Curity Identity Server behind an API gateway.
- Expose the admin UI and OAuth endpoints using domain based URLs.

## Lesson 3 - HTTPS External URLs with Certificate Auto Renewal

Follow the [README instructions](./lesson-3/README.md) to learn how to:

- Update the domain based URLs to use HTTPS.
- Automate external certificate issuance using cert-manager.
- Automate certificate renewal and reloading of the external certificate by the API gateway.

## Lesson 4 - SQL Database Storage

Follow the [README instructions](./lesson-4/README.md) to learn how to:

- Redeploy the Curity Idemtity Server using SQL database storage for identity data.
- Query the database to view stored resources such as user accounts.
- Use external storage to avoid data loss if you recreate Kubernetes pods, nodes or the entire cluster.

## Lesson 5 - Deployment Pipeline

Follow the [README instructions](./lesson-5/README.md) to learn how to:

- Parameterize Curity Identity Server configuration to support multiple stages of a deployment pipeline.
- Split the configuration into multiple files.
- Deploy the configuration in a custom Docker image.
- Protect secure values in the configuration.

## Free Resources

You can remove the test cluster and free resources when you have finished testing:

```bash
./delete-cluster.sh
```

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
