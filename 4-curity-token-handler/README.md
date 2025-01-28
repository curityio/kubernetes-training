# Final Curity Token Handler

This deployment provides a working SPA with a Kubernetes token handler.

## Run Base Scripts

First deploy the cluster from the `Final Curity Identity Server` tutorial, to use as the authorization server.\
Then redeploy the API gateway with the script from this tutorial's folder.\
The API gateway deployment then provides API gateway plugins used by the token handler pattern:

```bash
./4-deploy-api-gateway.sh
```

## Deploy the Curity Token Handler

Then run a Curity Token Handler deployment that uses parameterized configuration:

```bash
./5-deploy-curity.sh
```

## Deploy an Example SPA and API

Then deploy an example SPA and API to enable an end-to-end solution.\
These application level components contain straightforward code and do not require any cookie logic.

```bash
./6-deploy-spa-and-api.sh
```
