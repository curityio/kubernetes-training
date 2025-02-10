# Final Curity Identity Server

The final tutorial demonstrates a couple of behaviors to aim for in real deployments for the the Curity Identity Server.
It makes use of some advances behaviors. Make sure your license supports the following feature:

* DevOps Dashboard

You can find out about your options in the [license plans of the Curity products](https://curity.io/product/plans/).

## Run Base Scripts

Delete the existing cluster if it exists and then create a new cluster with the scripts from this tutorial's folder.\
The [Ingress tutorial](/2-ingress-tutorial/README.md) explains the behavior of these scripts and the URLs you can connect to.

```bash
./1-create-cluster.sh
./2-run-load-balancer.sh
./3-create-external-certificate-issuer.sh
./4-deploy-api-gateway.sh
```

## Deploy the Curity Identity Server

Then run a more advanced Curity Identity Server deployment that includes a [JDBC data source](https://curity.io/docs/idsvr/latest/system-admin-guide/data-sources/index.html).\
This example deployment uses PostgreSQL, though you could adapt the deployment to support a different provider:

```bash
./5-deploy-curity.sh
```

Make sure your local computer's `/etc/hosts` file with the API gateway's external IP address and the Curity Identity Server domain names:

```text
172.20.0.5 admin.testcluster.example login.testcluster.example
```

The Helm deployment substitutes environment variables for placeholders like `#{PARAMETER}` in XML configuration files.\
The deployment also supplies sensitive values like keys as cryptographically protected environment variables.\
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

The demo deployment uses a PostgreSQL database and simulates durable storage on a development computer.\
In Kubernetes, the [local-path-provisioner](https://github.com/rancher/local-path-provisioner) storage class and a persistent volume enable this.\
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
