## Overview

An end to end Kubernetes deployment of the Curity Identity Server, for demo purposes.\
For a walkthrough see the [Kubernetes Quick Start HOWTO Document](https://curity.io/resources/learn/kubernetes-quick-start).

## Prepare the Installation

First install prerequisites including [minikube](https://minikube.sigs.k8s.io/docs/start/).
Then add a license file to the backed up configuration.

## Install the System

Then run these scripts in sequence:

```bash
./create-certs.sh
./create-cluster.sh
./deploy-postgres.sh
./deploy-idsvr.sh
```

## Use the System

Once complete you will have a fully working system including:

- [OAuth and OpenID Connect Endpoints](https://login.curity.local/oauth/v2/oauth-anonymous/.well-known/openid-configuration) used by applications
- A rich [Admin UI](https://admin.curity.local/admin) for configuring applications and their security behavior
- A SQL database with which to query users, tokens and audit information
- A SCIM 2.0 endpoint for managing user data
- A working [End to End Code Sample](https://login.curity.local/demo-client.html)

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.


