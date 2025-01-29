# Final Curity Token Handler

This deployment provides a working SPA with a Kubernetes token handler that integrates with an authorization server:

- When you first run the deployment, follow the instructions and use the Curity Identity Server as the authorization server.
- Once you understand the deployment steps you can use a different authorization server if required.

## Run Base Scripts

First run the [Final Curity Identity Server](../3-curity-identity-server) tutorial to deploy an authorization server.\
The [Ingress tutorial](../2-ingress-tutorial) explains the URLs you can connect to.\
Then redeploy the API gateway with plugins, using the script from this tutorial's folder:

```bash
./1-deploy-api-gateway.sh
```

## Deploy the Curity Token Handler

Next, run a Curity Token Handler deployment that points to the authorization server's endpoints:

```bash
./2-deploy-token-handler.sh
```

### Configuration Best Practices

The Helm deployment subsitutes environment variables for placeholders like `#{PARAMETER}` in XML configuration files.\
The deployment supplies sensitive values like keys as cryptographically protected environment variables.\
The [Configuration as Code](https://curity.io/resources/learn/gitops-configuration-management/) tutorial explains the techniques.

## Configure the Authorization Server

Next, enable user management, create a user authentication method and register an SPA client in the authorization server:

```bash
./3-configure-authorization-server.sh
```

TODO: notes on user creation in the Admin UI

## Deploy an Example SPA and API

Then deploy an example SPA and API to enable an end-to-end solution.\
These application level components do not need to implement any cookie logic.

```bash
./6-deploy-spa-and-api.sh
```

TODO: notes on URLs to run the SPA and API
