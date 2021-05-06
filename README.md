## Overview

An end to end Kubernetes deployment of the Curity Identity Server, for demo purposes.\
For a walkthrough see the [Kubernetes Quick Start HOWTO Document](https://curity.io/resources/learn/kubernetes-quick-start).

## Prepare the Installation

First install prerequisites including [minikube](https://minikube.sigs.k8s.io/docs/start/).
Then add a license file to the backed up configuration.

## Install the System

Then run these scripts in sequence:

```bash
./create-cluster.sh
./deploy-postgres.sh
./deploy-idsvr.sh
```

## Use the System

Once complete you will have a fully working system including:

- [OAuth and OpenID Connect Endpoints](http://login.curity.local/oauth/v2/oauth-anonymous/.well-known/openid-configuration) used by applications
- A rich [Admin UI](http://admin.curity.local/admin) for configuring applications and their security behavior
- A SQL database from which users, tokens, sessions and audit information can be queried
- A [SCIM 2.0 API](http://login.curity.local/user-management/admin) for managing user accounts
- A working [End to End Code Sample](http://login.curity.local/demo-client.html)

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.