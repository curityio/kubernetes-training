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

At this point both the Curity Identity Server and Curity Token Handler are running:

```text
applications         tokenhandler-admin-867f687558-5mk2n           1/1     Running   0                2m7s
applications         tokenhandler-runtime-7f4cd6dfbd-m9427         1/1     Running   0                2m7s
applications         tokenhandler-runtime-7f4cd6dfbd-vbx5r         1/1     Running   0                2m7s
cert-manager         cert-manager-7774cff9f9-qphn4                 1/1     Running   5 (4h50m ago)    2d5h
cert-manager         cert-manager-cainjector-5594979f8b-j5v89      1/1     Running   2 (2d3h ago)     5d17h
cert-manager         cert-manager-webhook-5645b4cfd5-8x4bc         1/1     Running   1 (2d3h ago)     2d5h
curity               curity-idsvr-admin-56db87bbc6-h8rmf           1/1     Running   0                21m
curity               curity-idsvr-runtime-569b47875b-fjpc2         1/1     Running   0                21m
curity               curity-idsvr-runtime-569b47875b-pn9tf         1/1     Running   0                21m
curity               postgres-0                                    1/1     Running   0                21m
```

### Pipeline Ready Deployment

The Helm deployment subsitutes environment variables for placeholders like `#{PARAMETER}` in XML configuration files.\
The deployment also supplies sensitive values like keys as cryptographically protected environment variables.\
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
