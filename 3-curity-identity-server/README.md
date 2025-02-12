# Final Curity Identity Server

The final example demonstrates a couple of behaviors to aim for in production deployments for the the Curity Identity Server.
It makes use of some advances behaviors like parameterized configuration, protecting sensitive values and a custom docker image. \
As the example includes production-like configuration, make sure your license supports the following feature:

* DevOps Dashboard

You can find out about your options in the [license plans of the Curity products](https://curity.io/product/plans/) and download your license from [Curity's developer portal](https://developer.curity.io/).

## Run Base Scripts

Delete the existing demo cluster if it exists and then create a new cluster with the scripts from this tutorial's folder.\
The [Ingress tutorial](/2-ingress-tutorial/README.md) explains the behavior of these scripts and the URLs you can connect to.

```bash
./1-create-cluster.sh
./2-run-load-balancer.sh
./3-create-external-certificate-issuer.sh
./4-deploy-api-gateway.sh
```

## Deploy the Curity Identity Server

This example deployment of the Curity Identity Server uses a [JDBC data source](https://curity.io/docs/idsvr/latest/system-admin-guide/data-sources/index.html) with PostgreSQL, though you could adapt the deployment to support a different provider. \
Before you deploy the Curity Identity Server specify the location of your license file in the `LICENSE_FILE_PATH` environment variable. Then run the script to deploy the Curity Identity Server in a production-like manner. 


```bash
export LICENSE_FILE_PATH=license.json
./5-deploy-curity.sh
```

The script prepares the configuration parameters as well as the custom docker image for the Curity Identity Server that includes the parameterized configuration and log settings. Finally, the script deploys the Curity Identity Server including its database to Kubernetes. You can access the endpoints via domain-based URLs.

Make sure your local computer's `/etc/hosts` file contains the API gateway's external IP address and the Curity Identity Server domain names:

```text
172.20.0.5 admin.testcluster.example login.testcluster.example
```

The Curity Identity Server substitutes environment variables for placeholders like `#{PARAMETER}` in XML configuration files. The Helm chart can create those variables from `ConfigMaps` or `Secrets`. \
The deployment supplies sensitive values like keys as cryptographically protected environment variables.\
The [Configuration as Code](https://curity.io/resources/learn/gitops-configuration-management/) tutorial explains the techniques.

## Create a Test User Account

You can sign into the Admin UI for a full administration experience that an identity team might use:

```text
URL: https://admin.testcluster.example/admin
User: admin
Password: Password1
```

You can sign into the [DevOps Dashboard](https://curity.io/resources/learn/devops-dashboard/) for more limited administration privileges:

```text
URL: https://admin.testcluster.example/admin/dashboard
User: admin
```

Use the DevOps Dashboard to operate as a developer, tester or DevOps person and create a test user account.\
Also make sure you toggle on the active setting for the new user.

```text
First name: John
Last name: Doe
Username: johndoe
Password: Password1
Email: john.doe@testcluster.example
```

## Use SQL Identity Data

The example deployment uses a PostgreSQL database and simulates durable storage on a development computer.\
In Kubernetes the [local-path-provisioner](https://github.com/rancher/local-path-provisioner) storage class and a persistent volume enable this.\
Run the following command to see the related Kubernetes resources:

```bash
kubectl get storageclass,pv,pvc -A
```

Locate the database data files at `resources/cluster/externalstorage/idsvr`.\
Since the database data is external to the cluster it survives replacement of pods, nodes or even the entire cluster.\
To familiarize yourself with the database schema, first get a shell to the database container with the following command:

```bash
kubectl -n curity exec -it postgres-0 -- bash
```

Then connect to the PostgreSQL database:

```bash
export PGPASSWORD=Password1 && psql -p 5432 -d idsvr -U idsvr
```

You can then query the data for test user accounts created in the DevOps dashboard:

```sql
select * from accounts;
```

The Curity Identity Server comes with database init scripts. You can find the scripts for various database types in the `/opt/idsvr/etc/` folder of the Docker container in case you want to integrate with different solutions.
