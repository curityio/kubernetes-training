# Final Curity Token Handler

This deployment provides a working SPA with a Kubernetes token handler.

## Run Base Scripts

First run the `Final Curity Identity Server` tutorial, to deploy authorization server endpoints.\
If you prefer, replace the Curity Identity Server with a different authorization server.\
Then redeploy the API gateway with plugins, using the script from this tutorial's folder:

```bash
./4-deploy-api-gateway.sh
```

## Deploy the Curity Token Handler

Then run a Curity Token Handler deployment that points to the authorization server's endpoints:

```bash
./5-deploy-curity.sh
```

### Configuration Best Practices

The deployment uses a configuration file with placeholders like `#{PARAMETER}`, which get subsituted with environment variables.\
The deployment supplies sensitive values like keys as cryptographically protected environment variables.\
The [Configuration as Code](https://curity.io/resources/learn/gitops-configuration-management/) tutorial explains the techniques.

## Deploy an Example SPA and API

Then deploy an example SPA and API to enable an end-to-end solution.\
These application level components do not need to implement any cookie logic.

```bash
./6-deploy-spa-and-api.sh
```
