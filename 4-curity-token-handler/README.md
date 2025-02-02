# Final Curity Token Handler

This deployment provides a working SPA with a Kubernetes token handler that integrates with an authorization server:

- When you first run the deployment, follow the instructions and use the Curity Identity Server as the authorization server.
- Once you understand the deployment steps you can use a different authorization server if required.

## Run Base Scripts

First run the [Final Curity Identity Server](../3-curity-identity-server) tutorial to deploy an authorization server.\
The [Ingress tutorial](../2-ingress-tutorial) explains the URLs that you can connect to once deployment completes.

## Redeploy the API Gateway

Download the token handler zip file for the Kong API gateway from the [Curity Developer Portal](https://developer.curity.io/releases/token-handler).\
Save the zip file to the `resources/api-gateway` folder and then redeploy the API gateway.\
This runs a more advanced deployment that uses plugins to process cookies sent from an SPA to APIs:

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
curity               curity-idsvr-admin-56db87bbc6-h8rmf           1/1     Running   0                21m
curity               curity-idsvr-runtime-569b47875b-fjpc2         1/1     Running   0                21m
curity               curity-idsvr-runtime-569b47875b-pn9tf         1/1     Running   0                21m
curity               postgres-0                                    1/1     Running   0                21m
```

The Helm deployment subsitutes environment variables for placeholders like `#{PARAMETER}` in XML configuration files.\
The deployment also supplies sensitive values like keys as cryptographically protected environment variables.\
The [Configuration as Code](https://curity.io/resources/learn/gitops-configuration-management/) tutorial explains the techniques.

## Deploy an Example SPA and API

Then deploy an example React App and Node.js API to complete an end-to-end solution.\
First, ensure that an up to date version of Node.js is installed, then run the following command:

```bash
./3-deploy-spa-and-api.sh
```

Next, update DNS for the deployment to map the external IP address of the API gateway to use all of these host names:

```text
172.20.0.5 admin.testcluster.example login.testcluster.example admin.demoapp.example www.demoapp.example api.demoapp.example
```

The application level components use straightforward code that does not require any cookie logic.\
Navigate to `https://www.demoapp.example` and enter the test account credentials to sign in:

```text
Username: johndoe
Password: Password1
```

Once integrated you can gradually refine and improve the application security behaviors:

- Take full control over access token data supplied to your APIs.
- Use advanced authentication workflows for user logins to the SPA.
