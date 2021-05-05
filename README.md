## Overview

A reference Kubernetes deployment of the Curity Identity Server, for demo purposes.\
For full details see the [Kubernetes Quick Start HOWTO Document](https://curity.io/resources/learn/kubernetes-quick-start).

## Install the System

First install prerequisites including [minikube](https://minikube.sigs.k8s.io/docs/start/), then run these scripts in sequence:

```bash
./create-cluster.sh
./deploy-mysql.sh
./deploy-idsvr.sh
```

## Use the System

Once complete you will have a fully working system including:

- [OAuth and OpenID Connect Endpoints](https://login.curity.local/oauth/v2/oauth-anonymous/.well-known/openid-configuration) used by applications
- A rich [Admin UI](https://admin.curity.local/admin) for configuring system behavior
- A SQL database with which to query users, tokens and audit data
- A SCIM 2.0 endpoint for managing user data
- A working [End to End Code Sample](https://login.curity.local/demo-client.html)

## Technical Walkthrough

See the [Kubernetes Quick Start HOWTO Article](https://curity.io/resources/learn/kubernetes-quick-start) for a walkthrough and how to use the system. 

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.


