# Final Curity Identity Server

The final tutorial demonstrates a couple of behaviors to aim for in real deployments for the the Curity Identity Server.

## Run Base Scripts

Delete the existing cluster if it exists and then create a new cluster with the scripts from this tutorial's folder.\
The behavior of these scripts is explained in the [Ingress tutorial](../2-ingress-tutorial).

```bash
./1-create-cluster.sh
./2-run-load-balancer.sh
./3-prepare-external-certificates.sh
./4-deploy-api-gateway.sh
```

## Deploy the Curity Identity Server

Then run a more advanced Curity Identity Server deployment that includes a [JDBC data source](https://curity.io/docs/idsvr/latest/system-admin-guide/data-sources/index.html).\
This example deployment uses PostgreSQL, though you could adapt the deployment to support a different provider:

```bash
./5-deploy-curity.sh
```

Update the local computer's `/etc/hosts` file with the API gateway's external IP address and the Curity Identity Server domain names:

```text
172.20.0.5 admin.testcluster.example login.testcluster.example
```

### Configuration Best Practices

The deployment uses a configuration file with placeholders like `#{PARAMETER}`, which get subsituted with environment variables.\
The deployment supplies sensitive values like keys as cryptographically protected environment variables.\
The [Configuration as Code](https://curity.io/resources/learn/gitops-configuration-management/) tutorial explains the techniques.

```xml
<config xmlns="http://tail-f.com/ns/config/1.0">
  <environments xmlns="https://curity.se/ns/conf/base">
    <environment>
      <base-url>#{RUNTIME_BASE_URL}</base-url>
      <admin-service>
        <http>
          <base-url>#{ADMIN_BASE_URL}</base-url>
          <web-ui>
          </web-ui>
          <restconf>
          </restconf>
        </http>
      </admin-service>
      <services>
        <zones>
          <default-zone>
            <symmetric-key>#{SYMMETRIC_KEY}</symmetric-key>
          </default-zone>
        </zones>
      </services>
    </environment>
  </environments>
</config>
```

### Resilient Database Storage

In real deployments, identity data is often stored on a volume outside the cluster, such as in a cloud platform.\
The demo deployment uses a SQL database and simulates external storage on a development computer using the [local-path-provisioner](https://github.com/rancher/local-path-provisioner) storage class.\
The database data is then stored on the local computer at `./resources/cluster/externalstorage`.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-idsvr-data
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: idsvr-pv-claim
    namespace: curity
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  volumeMode: Filesystem
  hostPath:
    path: /var/local-path-provisioner/host/idsvr
    type: DirectoryOrCreate
```

The database data survives replacement of pods, nodes or even the entire cluster.\
For real deployments you can use many possible ways to enable high availability database storage for identity data.

### Identity Data

To familiarize yourself with the database schema, first get a shell to the database container with the following command:

```bash
kubectl -n curity exec -it postgres-0 -- bash
```

Then connect to the PostgreSQL database:

```bash
export PGPASSWORD=Password1 && psql -p 5432 -d idsvr -U idsvr
```

As you run flows and use tokens you will see data get created:

```sql
select * from accounts;
select * from tokens;
```

