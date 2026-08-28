# hyperswitch-app

Hyperswitch is a community-led, open payments switch designed to empower digital businesses by providing fast, reliable, and affordable access to the best payments infrastructure.

![Version: 1.2.1](https://img.shields.io/badge/Version-1.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.126.0](https://img.shields.io/badge/AppVersion-v1.126.0-informational?style=flat-square)

# Deploy on Kubernetes using Helm

This section outlines cloud-provider agnostic deployment steps for easy installation of the Hyperswitch stack on your K8s cluster

## Installation

### Step 1 - Clone repo and Update Configurations

Clone the [hyperswitch-stack](https://github.com/juspay/hyperswitch-helm) repo and start updating the configs

```
git clone https://github.com/juspay/hyperswitch-helm.git
cd hyperswitch-helm/charts/incubator/hyperswitch-stack
```

### Step 2 - Install Hyperswitch

Before installing the service make sure you labels your kubernetes nodes and create a namespace `hyperswitch`
Note: minimum --memory 6000 --cpus 4 needed
```bash
kubectl create namespace hyperswitch
```
Use below command to install hyperswitch services with above configs

```bash
helm install hyperswitch-v1 . -n hyperswitch
```

That's it! Hyperswitch should be up and running on your AWS account  :tada: :tada:

## Post-Deployment Checklist

After deploying the Helm chart, you should verify that everything is working correctly

### App Server

* [ ] &#x20;Check that `hyperswitch_server/health` returns `health is good`

### Control Center

* [ ] &#x20;Verify if you are able to sign in or sign up
* [ ] &#x20;Verify if you are able to [create API key](https://opensource.hyperswitch.io/run-hyperswitch-locally/account-setup/using-hyperswitch-control-center#user-content-create-an-api-key)
* [ ] &#x20;Verify if you are able to [configure a new payment processor](https://opensource.hyperswitch.io/run-hyperswitch-locally/account-setup/using-hyperswitch-control-center#add-a-payment-processor)

## 💳 Test a payment

Hyperswitch Control center will mimic the behavior of your checkout page. Please follow below steps to test a payment with the deployed app

### 🔐 Step 1 - Deploy card vault

By default card vault and its dependencies are installed, however you need to create master key, custodian keys and unlock the locker to start saving cards.

<details>
  <summary>
    <b> Step 1: Generating the keys </b>
  </summary>
  <p>
  To generate the master key and the custodian keys use the following command after cloning the repository.
   
    # Generate master key
    git clone https://github.com/juspay/hyperswitch-card-vault.git
    cd hyperswitch-card-vault
    cargo run --bin utils -- master-key
    To generate the JWE and JWS keys run the following commands

    # Generating the private keys
    openssl genrsa -out locker-private-key.pem 2048
    openssl genrsa -out tenant-private-key.pem 2048

    # Generating the public keys
    openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem
    openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem 
</p>
</details>
<details>
  <summary>
    <b> Step 2: Update the keys in deployment </b>
  </summary>
  <p>

    # Update below values in hyperswitch-stack/values.yaml
    # The public key for the locker from locker-public-key.pem
    hyperswitch-app.server.secrets.kms_jwekey_vault_encryption_key: |
      -----BEGIN PUBLIC KEY-----
      ...
      -----END PUBLIC KEY-----
    # The private key for the tenant from tenant-private-key.pem
    hyperswitch-app.server.secrets.kms_jwekey_vault_private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      ...
      -----END RSA PRIVATE KEY-----
    # The private key for the locker from locker-private-key.pem
    hyperswitch-card-vault.server.secrets.locker_private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      ...
      -----END RSA PRIVATE KEY-----
    # The public key for the tenant from tenant-public-key.pem
    hyperswitch-card-vault.server.secrets.tenant_public_key: |
      -----BEGIN PUBLIC KEY-----
      ...
      -----END PUBLIC KEY-----

   </p>
</details>
<details>
  <summary> <b> Step 3: Unlock the locker </b> </summary>
  <p>
  Once the locker is up and running, use the 2 key custodian keys generated earlier securely to unlock the locker for use.
  Go to the respective locker Pod, open its shell and run below cURLs

  The following cURLs are to be used to provide keys

    # temporary turn of saving to history to run the following commands
    unset HISTFILE

    # Add key1, key2 and then decrypt
    curl -X POST -H "Content-Type: application/json" -d '{"key": "<key 1>"}' http://localhost:8080/custodian/key1
    curl -X POST -H "Content-Type: application/json" -d '{"key": "<key 2>"}' http://localhost:8080/custodian/key2
    curl -X POST http://localhost:8080/custodian/decrypt
   
  If the last cURL replies with `Decrypted Successfully`, we are ready to use the locker.
   </p>
</details>

### Step 2 - Make a payment using our Control Center

Use the Hyperswitch Control Center and [make a payment with test card](https://docs.hyperswitch.io/hyperswitch-open-source/account-setup/test-a-payment).

Refer our [postman collection](https://www.postman.com/hyperswitch/workspace/hyperswitch/folder/25176183-0103918c-6611-459b-9faf-354dee8e4437) to try out REST APIs

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | clickhouse | 6.3.3 |
| https://charts.bitnami.com/bitnami | kafka | 31.0.0 |
| https://charts.bitnami.com/bitnami | postgresql | 15.5.38 |
| https://charts.bitnami.com/bitnami | redis | 18.6.1 |
| https://codecentric.github.io/helm-charts | mailhog | 4.0.0 |
| https://helm.vector.dev | vector | 0.37.0 |
| https://juspay.github.io/hyperswitch-helm | hyperswitch-card-vault | 0.1.4 |
| oci://ghcr.io/juspay/helm-charts | superposition | 0.112.0 |

## Values
<h3>Router services</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L2243">baseRelease</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Name of the Helm release that owns this environment's shared infrastructure. Set it when this release is a *second* release of the chart running a single service (OLAP or payment method modular) against the datastores of a main release. The host and secret-name values are templated, so an overlay can refer to `{{ .Values.baseRelease }}-postgresql`, `{{ .Values.baseRelease }}-redis-master`, `{{ .Values.baseRelease }}-hyperswitch-router-role` and have them follow the base release. Ignored when left empty.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2356">olap.argoRollouts</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Argo Rollouts settings for this service, merged over the release-level `argoRollouts` block. Lists (canary steps, analysis metrics) replace rather than extend the inherited value. Omit to inherit the release's rollout behaviour as-is.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2313">olap.autoscaling.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable a HorizontalPodAutoscaler for this service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2289">olap.configs</a></div></td>
    <td><div><code>{
  "master_database": {
    "pool_size": "5"
  }
}</code></div></td>
    <td>Config overrides merged over `server.configs`, rendered as inline env</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2285">olap.database.masterHost</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Explicit host overrides. Templated, e.g. `{{ .Release.Name }}-postgresql`</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2282">olap.database.useReplicaForMaster</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Point the master (write) database handle at the read replica. A write attempted against this service then fails at the replica instead of reaching the writer. When the release has no read replica the primary is used instead, so the service still runs - `helm install` prints a warning in that case.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2259">olap.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable the OLAP router</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2262">olap.fullnameOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Override the generated name `<release>-hyperswitch-olap-server`</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2320">olap.ingress.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Publish this service through an Ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2333">olap.istio.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Render a VirtualService and DestinationRule for this service. Set `hosts` and `gateways` to the same values as `istio.virtualService` above so Istio merges the two into one route table for the host. Istio does not guarantee rule ordering across VirtualServices on the same host, so keep the main router's catch-all from shadowing the paths claimed here.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2271">olap.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas; ignored when this service's autoscaling is enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2295">olap.resources</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Workload settings; empty values fall back to `server.*` and then `global.*`</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2275">olap.serviceAccountName</a></div></td>
    <td><div><code>""</code></div></td>
    <td>ServiceAccount to run as. Empty reuses the release's router ServiceAccount, so this service inherits the same cloud identity instead of needing one of its own.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2265">olap.version</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Image tag, registry and repository. Empty values fall back to `services.router.*`</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2381">paymentMethodModular.configs</a></div></td>
    <td><div><code>{
  "micro_services": {
    "payment_methods_prefix": "v1"
  },
  "trace_header": {
    "header_name": "x-request-id",
    "id_reuse_strategy": "use_incoming"
  }
}</code></div></td>
    <td>Config overrides merged over `server.configs`, rendered as inline env</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2362">paymentMethodModular.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable the payment method modular router</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2367">paymentMethodModular.fullnameOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Override the generated name `<release>-hyperswitch-payment-method-modular-server`. Worth setting for release names longer than 21 characters, where the generated name is truncated at Kubernetes' 63 character limit.</td>
  </tr></tbody>
</table>
<h3>Dependencies configuration</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L1770">clickhouse.auth.password</a></div></td>
    <td><div><code>"jhdvfvsnbdj"</code></div></td>
    <td>Clickhouse password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1767">clickhouse.auth.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1777">clickhouse.config.TZ</a></div></td>
    <td><div><code>"Asia/Kolkata"</code></div></td>
    <td>Clickhouse timezone</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1759">clickhouse.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Clickhouse sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1763">clickhouse.fullnameOverride</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>Name of the Clickhouse sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1792">clickhouse.logLevel</a></div></td>
    <td><div><code>"error"</code></div></td>
    <td>Clickhouse log level</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1783">clickhouse.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse replica count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1780">clickhouse.shards</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse shard count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1789">clickhouse.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Zookerper replica count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1271">externalPostgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Postgres server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1294">externalPostgresql.primary.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1288">externalPostgresql.primary.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1291">externalPostgresql.primary.auth.plainpassword</a></div></td>
    <td><div><code>null</code></div></td>
    <td>master DB plainpassword</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1285">externalPostgresql.primary.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1275">externalPostgresql.primary.host</a></div></td>
    <td><div><code>"postgresql-ext"</code></div></td>
    <td>External postgres host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1317">externalPostgresql.readOnly.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1314">externalPostgresql.readOnly.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1311">externalPostgresql.readOnly.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1298">externalPostgresql.readOnly.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>External postgres read only host enabled or disabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1301">externalPostgresql.readOnly.host</a></div></td>
    <td><div><code>"postgres-service"</code></div></td>
    <td>External postgres read only host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1206">externalRedis.auth.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>auth enabled or disabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1212">externalRedis.auth.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1209">externalRedis.auth.username</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1199">externalRedis.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Redis server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1202">externalRedis.host</a></div></td>
    <td><div><code>"redis-ext-master"</code></div></td>
    <td>External redis host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1707">kafka.broker.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for broker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1702">kafka.controller.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for controller</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1695">kafka.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Kafka sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1698">kafka.fullnameOverride</a></div></td>
    <td><div><code>"kafka0"</code></div></td>
    <td>Name of the Kafka sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1726">kafka.listeners.client.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener client protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1738">kafka.listeners.controller.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener controller protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1734">kafka.listeners.external.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener external protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1730">kafka.listeners.interbroker.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener interbroker protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1742">kafka.provisioning.replicationFactor</a></div></td>
    <td><div><code>1</code></div></td>
    <td>kafka provisioning replicationFactor</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1721">kafka.service.ports.client</a></div></td>
    <td><div><code>29092</code></div></td>
    <td>Client port for Kafka</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1716">kafka.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for zookeeper</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1807">mailhog.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Mailhog sub-chart helm installation for email testing</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1810">mailhog.fullnameOverride</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Name of the Mailhog sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1242">postgresql.architecture</a></div></td>
    <td><div><code>"replication"</code></div></td>
    <td>Postgresql architecture: replication or standalone</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1224">postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>enable Bitnami postgresql sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1239">postgresql.global.postgresql.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql database</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1236">postgresql.global.postgresql.auth.password</a></div></td>
    <td><div><code>"ZGJwYXNzd29yZDEx"</code></div></td>
    <td>Postgresql password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1233">postgresql.global.postgresql.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1253">postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>postgres primary name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1258">postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"150m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1262">postgresql.readReplicas.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of read replicas</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1267">postgresql.readReplicas.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1249">postgresql.replication.numSynchronousReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of synchronous replicas</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1246">postgresql.replication.synchronousCommit</a></div></td>
    <td><div><code>"off"</code></div></td>
    <td>synchronous_commit parameter</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1192">redis.auth.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable redis auth</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1195">redis.auth.sentinel</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable sentinel</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1177">redis.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>- enable Bitnami redis sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1184">redis.master.count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for master</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1188">redis.replica.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of replicas to be used for replica</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1815">vector.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Vector sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1819">vector.env[0]</a></div></td>
    <td><div><code>{
  "name": "KAFKA_HOST",
  "value": "kafka0:29092"
}</code></div></td>
    <td>Vector environment variables</td>
  </tr></tbody>
</table>
<h3>Istio</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L1338">istio</a></div></td>
    <td><div><code>{
  "destinationRule": {
    "trafficPolicy": {}
  },
  "enabled": false,
  "virtualService": {
    "create": true,
    "gateways": [],
    "hosts": [],
    "http": [
      {
        "match": [],
        "name": "primary",
        "retries": {},
        "timeout": "50s",
        "weight": 100
      }
    ]
  }
}</code></div></td>
    <td>Istio configuration</td>
  </tr></tbody>
</table>
<h3>App Server Secrets</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L208">server.configs.analytics.clickhouse.database_name</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse database name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L211">server.configs.analytics.clickhouse.host</a></div></td>
    <td><div><code>"http://clickhouse:8123"</code></div></td>
    <td>Clickhouse host in http(s)://<URL>:<PORT> format</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L217">server.configs.analytics.clickhouse.password</a></div></td>
    <td><div><code>{
  "_secretRef": {
    "key": "admin-password",
    "name": "clickhouse"
  }
}</code></div></td>
    <td>Clickhouse password (optional)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L214">server.configs.analytics.clickhouse.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L855">server.configs.api_keys.hash_key</a></div></td>
    <td><div><code>{
  "_secret": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
}</code></div></td>
    <td>API key hashing key.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L272">server.configs.applepay_decrypt_keys.apple_pay_merchant_cert</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L276">server.configs.applepay_decrypt_keys.apple_pay_merchant_cert_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Private key generated by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L280">server.configs.applepay_decrypt_keys.apple_pay_ppc</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Payment Processing Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Payment Processing Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L284">server.configs.applepay_decrypt_keys.apple_pay_ppc_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Private key generated by Elliptic-curve prime256v1 curve. You can use `openssl ecparam -out private.key -name prime256v1 -genkey` to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L267">server.configs.applepay_merchant_configs.common_merchant_identifier</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Refer to config.example.toml to learn how you can generate this value</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L259">server.configs.applepay_merchant_configs.merchant_cert</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L263">server.configs.applepay_merchant_configs.merchant_cert_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Private key generate by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L371">server.configs.email.aws_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS region used by AWS SES</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L375">server.configs.email.aws_ses.email_role_arn</a></div></td>
    <td><div><code>"arn:aws:iam::123456789012:role/SendEmailRole"</code></div></td>
    <td>The amazon resource name ( arn ) of the role which has permission to send emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L378">server.configs.email.aws_ses.sts_role_session_name</a></div></td>
    <td><div><code>"SendEmailRole"</code></div></td>
    <td>An identifier for the assumed role session, used to uniquely identify a session.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L381">server.configs.email.prod_intent_recipient_email</a></div></td>
    <td><div><code>"business@example.com"</code></div></td>
    <td>Recipient email for prod intent email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L384">server.configs.email.recon_recipient_email</a></div></td>
    <td><div><code>"recon@example.com"</code></div></td>
    <td>Recipient email for recon request email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L387">server.configs.email.sender_email</a></div></td>
    <td><div><code>"example@example.com"</code></div></td>
    <td>Sender email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L393">server.configs.email.smtp.host</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Host of the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L449">server.configs.forex_api.api_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Api key for making request to foreign exchange Api, Follow https://github.com/juspay/hyperswitch/tree/main/crates/analytics#setting-up-forex-apis to get the forex api key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L453">server.configs.forex_api.fallback_api_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Forex Api key for the fallback service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L793">server.configs.jwekey.vault_encryption_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the locker from locker-public-key.pub, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L807">server.configs.jwekey.vault_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>The private key for the tenant from tenant-private-key.pem, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L865">server.configs.key_manager.ca</a></div></td>
    <td><div><code>{
  "_secret": "sample_ca"
}</code></div></td>
    <td>CA certificate for the keymanager service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L869">server.configs.key_manager.cert</a></div></td>
    <td><div><code>{
  "_secret": "sample_cert"
}</code></div></td>
    <td>Client certificate for the keymanager service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L786">server.configs.kms.key_id</a></div></td>
    <td><div><code>{
  "_secret": "kms_key_id"
}</code></div></td>
    <td>KMS key id for encryption and decryption</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L553">server.configs.locker.redis_temp_locker_encryption_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Encryption key for redis temp locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L635">server.configs.payment_method_auth.pm_auth_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td># Payment method auth key used for authorization</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L642">server.configs.paze_decrypt_keys.paze_private_key</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY"</code></div></td>
    <td>Base 64 Encoded Private Key File cakey.pem generated for Paze -> Command to create private key: openssl req -newkey rsa:2048 -x509 -keyout cakey.pem -out cacert.pem -days 365</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L645">server.configs.paze_decrypt_keys.paze_private_key_passphrase</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY_PASSPHRASE"</code></div></td>
    <td>PEM Passphrase used for generating Private Key File cakey.pem</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L880">server.configs.secrets.admin_api_key</a></div></td>
    <td><div><code>{
  "_secret": "test_admin"
}</code></div></td>
    <td>admin API key for admin authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L884">server.configs.secrets.jwt_secret</a></div></td>
    <td><div><code>{
  "_secret": "test_admin"
}</code></div></td>
    <td>JWT secret used for user authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L888">server.configs.secrets.master_enc_key</a></div></td>
    <td><div><code>{
  "_secret": "471f22516724347bcca9c20c5fa88d9821c4604e63a6aceffd24605809c9237c"
}</code></div></td>
    <td>Master Encryption key used to encrypt merchant wise encryption key. Should be 32-byte long.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L892">server.configs.secrets.recon_admin_api_key</a></div></td>
    <td><div><code>{
  "_secret": "test_admin"
}</code></div></td>
    <td>Recon Admin API key for recon admin authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L873">server.configs.user_auth_methods</a></div></td>
    <td><div><code>{
  "encryption_key": {
    "_secret": "A8EF32E029BC3342E54BF2E172A4D7AA43E8EF9D2C3A624A9F04E2EF79DC698F"
  }
}</code></div></td>
    <td>Encryption key used for user_auth_methods table</td>
  </tr></tbody>
</table>
<h3>Services</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L26">services.consumer.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-consumer"</code></div></td>
    <td>Consumer image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L23">services.consumer.imageRegistry</a></div></td>
    <td><div><code>"docker.juspay.io"</code></div></td>
    <td>Consumer image registry</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L20">services.consumer.version</a></div></td>
    <td><div><code>"v1.126.0"</code></div></td>
    <td>Consumer version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L48">services.drainer.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-drainer"</code></div></td>
    <td>Drainer image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L45">services.drainer.imageRegistry</a></div></td>
    <td><div><code>"docker.juspay.io"</code></div></td>
    <td>Drainer image registry</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L42">services.drainer.version</a></div></td>
    <td><div><code>"v1.126.0"</code></div></td>
    <td>Drainer version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L37">services.producer.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-producer"</code></div></td>
    <td>Producer image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L34">services.producer.imageRegistry</a></div></td>
    <td><div><code>"docker.juspay.io"</code></div></td>
    <td>Producer image registry</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L31">services.producer.version</a></div></td>
    <td><div><code>"v1.126.0"</code></div></td>
    <td>Producer version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L15">services.router.host</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td>Router host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L12">services.router.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-router"</code></div></td>
    <td>Router image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L9">services.router.imageRegistry</a></div></td>
    <td><div><code>"docker.juspay.io"</code></div></td>
    <td>Router image registry</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L6">services.router.version</a></div></td>
    <td><div><code>"v1.126.0"</code></div></td>
    <td>Router version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L52">services.sdk.host</a></div></td>
    <td><div><code>"http://localhost:9050"</code></div></td>
    <td>SDK host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L58">services.sdk.subversion</a></div></td>
    <td><div><code>"v1"</code></div></td>
    <td>SDK subversion</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L55">services.sdk.version</a></div></td>
    <td><div><code>"0.126.0"</code></div></td>
    <td>SDK version</td>
  </tr></tbody>
</table>
<h3>Other Values</h3>
<table>

<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>

<tbody><tr>
    <td><div><a href="./values.yaml#L91">_references</a></div></td>
    <td><div><code>{
  "configs": "{{ .Release.Name }}-hyperswitch-configs",
  "secrets": "{{ .Release.Name }}-hyperswitch-secrets"
}</code></div></td>
    <td>Common references for templated resource names</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L95">_references.configs</a></div></td>
    <td><div><code>"{{ .Release.Name }}-hyperswitch-configs"</code></div></td>
    <td>Hyperswitch configs reference with release name prefix</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L93">_references.secrets</a></div></td>
    <td><div><code>"{{ .Release.Name }}-hyperswitch-secrets"</code></div></td>
    <td>Hyperswitch secrets reference with release name prefix</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1443">argoRollouts.canary.analysis.args[0].name</a></div></td>
    <td><div><code>"canary-hash"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1445">argoRollouts.canary.analysis.args[0].valueFrom.podTemplateHashValue</a></div></td>
    <td><div><code>"Latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1446">argoRollouts.canary.analysis.args[1].name</a></div></td>
    <td><div><code>"stable-hash"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1448">argoRollouts.canary.analysis.args[1].valueFrom.podTemplateHashValue</a></div></td>
    <td><div><code>"Stable"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1433">argoRollouts.canary.analysis.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Render the AnalysisTemplate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1435">argoRollouts.canary.analysis.enforce</a></div></td>
    <td><div><code>false</code></div></td>
    <td>dryRun all metrics when false; hard-abort when true</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1439">argoRollouts.canary.analysis.interval</a></div></td>
    <td><div><code>"30s"</code></div></td>
    <td>Prometheus-compatible read API (vmselect serves /select/<tenant>/prometheus)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1451">argoRollouts.canary.analysis.metrics</a></div></td>
    <td><div><code>[
  {
    "count": 20,
    "failureLimit": 20,
    "inconclusiveLimit": 20,
    "interval": "30s",
    "name": "canary-min-traffic",
    "provider": {
      "prometheus": {
        "query": "sum(increase(REQUEST_TIME_count{pod=~\".*-{{args.canary-hash}}-.*\"}[5m]))\n"
      }
    },
    "successCondition": "len(result) \u003e 0 \u0026\u0026 result[0] \u003e= 100"
  },
  {
    "failureCondition": "len(result) \u003e 0 \u0026\u0026 result[0] \u003e 1.0",
    "failureLimit": 1,
    "name": "http-5xx-global",
    "provider": {
      "prometheus": {
        "query": "(100 * sum(rate(REQUEST_TIME_count{status_code=~\"5..\"}[5m]))\n    / clamp_min(sum(rate(REQUEST_TIME_count[5m])), 0.001)) or vector(0)\n"
      }
    }
  },
  {
    "count": 10,
    "failureCondition": "len(result) \u003e 0 \u0026\u0026 result[0] \u003e 1.0",
    "failureLimit": 3,
    "inconclusiveLimit": 5,
    "interval": "60s",
    "name": "canary-5xx-pct-delta",
    "provider": {
      "prometheus": {
        "query": "(\n  (100 * sum(rate(REQUEST_TIME_count{status_code=~\"5..\", pod=~\".*-{{args.canary-hash}}-.*\"}[5m]))\n      / clamp_min(sum(rate(REQUEST_TIME_count{pod=~\".*-{{args.canary-hash}}-.*\"}[5m])), 0.001)) or vector(0)\n)\n-\n(\n  (100 * sum(rate(REQUEST_TIME_count{status_code=~\"5..\", pod=~\".*-{{args.stable-hash}}-.*\"}[5m]))\n      / clamp_min(sum(rate(REQUEST_TIME_count{pod=~\".*-{{args.stable-hash}}-.*\"}[5m])), 0.001)) or vector(0)\n)\nand on() (sum(rate(REQUEST_TIME_count{pod=~\".*-{{args.canary-hash}}-.*\"}[5m])) \u003e 0.5)\n"
      }
    }
  },
  {
    "count": 10,
    "failureCondition": "len(result) \u003e 0 \u0026\u0026 result[0] \u003e 1.5",
    "failureLimit": 3,
    "inconclusiveLimit": 5,
    "interval": "60s",
    "name": "canary-p90-ratio",
    "provider": {
      "prometheus": {
        "query": "histogram_quantile(0.90, sum by (le)(rate(REQUEST_TIME_bucket{pod=~\".*-{{args.canary-hash}}-.*\"}[5m])))\n/\nclamp_min(\n  histogram_quantile(0.90, sum by (le)(rate(REQUEST_TIME_bucket{pod=~\".*-{{args.stable-hash}}-.*\"}[5m]))),\n  0.001\n)\nand on() (sum(rate(REQUEST_TIME_count{pod=~\".*-{{args.canary-hash}}-.*\"}[5m])) \u003e 0.5)\n"
      }
    }
  },
  {
    "count": 10,
    "failureCondition": "len(result) \u003e 0 \u0026\u0026 result[0] \u003e 5.0",
    "failureLimit": 3,
    "inconclusiveLimit": 5,
    "interval": "60s",
    "name": "canary-4xx-pct-delta",
    "provider": {
      "prometheus": {
        "query": "(\n  (100 * sum(rate(REQUEST_TIME_count{status_code=~\"4..\", pod=~\".*-{{args.canary-hash}}-.*\"}[5m]))\n      / clamp_min(sum(rate(REQUEST_TIME_count{pod=~\".*-{{args.canary-hash}}-.*\"}[5m])), 0.001)) or vector(0)\n)\n-\n(\n  (100 * sum(rate(REQUEST_TIME_count{status_code=~\"4..\", pod=~\".*-{{args.stable-hash}}-.*\"}[5m]))\n      / clamp_min(sum(rate(REQUEST_TIME_count{pod=~\".*-{{args.stable-hash}}-.*\"}[5m])), 0.001)) or vector(0)\n)\nand on() (sum(rate(REQUEST_TIME_count{pod=~\".*-{{args.canary-hash}}-.*\"}[5m])) \u003e 0.5)\n"
      }
    }
  }
]</code></div></td>
    <td>Metrics list; shared interval/address/timeout auto-injected via mergeOverwrite. Override per-metric (e.g. interval: 60s). Add/remove entries to customize.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1437">argoRollouts.canary.analysis.startingStep</a></div></td>
    <td><div><code>2</code></div></td>
    <td>Canary step index to start analysis at (used in Rollout spec, not here)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1441">argoRollouts.canary.analysis.timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>Per-query timeout (s)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1409">argoRollouts.canary.steps</a></div></td>
    <td><div><code>[
  {
    "setCanaryScale": {
      "replicas": 2
    }
  },
  {
    "setWeight": 0
  },
  {
    "pause": {}
  },
  {
    "setWeight": 50
  },
  {
    "pause": {
      "duration": "1m"
    }
  },
  {
    "setWeight": 75
  },
  {
    "pause": {
      "duration": "1m"
    }
  },
  {
    "setWeight": 100
  }
]</code></div></td>
    <td>Canary deployment steps with traffic percentage and pause duration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1541">argoRollouts.canary.trafficRouting.headerRouting.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable header-based canary routing</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1546">argoRollouts.canary.trafficRouting.headerRouting.match</a></div></td>
    <td><div><code>[
  {
    "headerName": "X-Canary-Test",
    "headerValue": {
      "exact": "true"
    }
  }
]</code></div></td>
    <td>Header matching rules</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1544">argoRollouts.canary.trafficRouting.headerRouting.routeName</a></div></td>
    <td><div><code>"header-canary-route"</code></div></td>
    <td>Route name for managed header routing This route will be auto added to the VirtualService when headerRouting is enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1527">argoRollouts.canary.trafficRouting.istio</a></div></td>
    <td><div><code>{
  "destinationRule": {
    "canarySubsetName": "canary",
    "stableSubsetName": "stable"
  },
  "enabled": true,
  "virtualService": {
    "routeNames": [
      "primary"
    ]
  }
}</code></div></td>
    <td>Enable Istio traffic management for canary deployments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1534">argoRollouts.canary.trafficRouting.istio.destinationRule</a></div></td>
    <td><div><code>{
  "canarySubsetName": "canary",
  "stableSubsetName": "stable"
}</code></div></td>
    <td>DestinationRule subset names</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1530">argoRollouts.canary.trafficRouting.istio.virtualService</a></div></td>
    <td><div><code>{
  "routeNames": [
    "primary"
  ]
}</code></div></td>
    <td>VirtualService route name to manage canary routing</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1405">argoRollouts.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable Argo Rollouts for canary deployments (uses Rollout resource instead of Deployment) When disabled, standard Kubernetes Deployment is used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1552">argoRollouts.revisionHistoryLimit</a></div></td>
    <td><div><code>3</code></div></td>
    <td>Revision history limit for rollouts</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1556">autoscaling.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1558">autoscaling.maxReplicas</a></div></td>
    <td><div><code>5</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1557">autoscaling.minReplicas</a></div></td>
    <td><div><code>3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1559">autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1756">clickhouse.host</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1772">clickhouse.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/clickhouse"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1773">clickhouse.image.tag</a></div></td>
    <td><div><code>24.3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1760">clickhouse.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1786">clickhouse.zookeeper.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/zookeeper"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1625">disableInternalSecrets</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1630">externalSecretsOperator.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable External Secrets Operator resources</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1666">externalSecretsOperator.externalSecrets.secrets</a></div></td>
    <td><div><code>[
  {
    "creationPolicy": "Owner",
    "dataFrom": [
      {
        "extract": {
          "key": "HyperswitchKmsDataSecret"
        }
      }
    ],
    "name": "hyperswitch-secrets",
    "refreshInterval": "1h",
    "targetName": "hyperswitch-secrets"
  }
]</code></div></td>
    <td>List of external secrets to create You can define multiple secrets here</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1673">externalSecretsOperator.externalSecrets.secrets[0].creationPolicy</a></div></td>
    <td><div><code>"Owner"</code></div></td>
    <td>Creation policy</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1675">externalSecretsOperator.externalSecrets.secrets[0].dataFrom</a></div></td>
    <td><div><code>[
  {
    "extract": {
      "key": "HyperswitchKmsDataSecret"
    }
  }
]</code></div></td>
    <td>Extract configuration (use dataFrom.extract for full secret)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1671">externalSecretsOperator.externalSecrets.secrets[0].refreshInterval</a></div></td>
    <td><div><code>"1h"</code></div></td>
    <td>Refresh interval</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1669">externalSecretsOperator.externalSecrets.secrets[0].targetName</a></div></td>
    <td><div><code>"hyperswitch-secrets"</code></div></td>
    <td>Target secret name in Kubernetes</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1644">externalSecretsOperator.secretStore.name</a></div></td>
    <td><div><code>"hyperswitch-secret-store"</code></div></td>
    <td>Name of the SecretStore</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1647">externalSecretsOperator.secretStore.provider</a></div></td>
    <td><div><code>{
  "aws": {
    "auth": {
      "jwt": {
        "serviceAccountRef": {
          "name": "hyperswitch-eso-sa"
        }
      }
    },
    "region": "us-west-2",
    "service": "SecretsManager"
  }
}</code></div></td>
    <td>Provider configuration (matches External Secrets Operator format) You can use any supported provider here see: https://external-secrets.io/latest/</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1636">externalSecretsOperator.serviceAccount.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Annotations for the service account (e.g., IRSA role)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1634">externalSecretsOperator.serviceAccount.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Create service account</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1638">externalSecretsOperator.serviceAccount.extraLabels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Extra labels for the service account</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1640">externalSecretsOperator.serviceAccount.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Name of the service account (default: hyperswitch-eso-sa)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1561">hyperswitch-card-vault.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1565">hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1564">hyperswitch-card-vault.initDB.checkPGisUp.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1752">initCH.checkCHisUp.image</a></div></td>
    <td><div><code>"bitnamilegacy/clickhouse:24.3"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1751">initCH.checkCHisUp.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1753">initCH.checkCHisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1322">initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1321">initDB.checkPGisUp.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1323">initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1319">initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1335">initDB.migration.dieselInstaller</a></div></td>
    <td><div><code>"https://github.com/diesel-rs/diesel/releases/latest/download/diesel_cli-installer.sh"</code></div></td>
    <td>Installer used to place diesel_cli in the migration Job. Pin a release tag instead of `latest` if you need the CLI version to be reproducible.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1332">initDB.migration.image</a></div></td>
    <td><div><code>"debian:trixie-slim"</code></div></td>
    <td>Base image for the migration Job. It needs `bash`, `apt-get` and network access: the Job installs diesel_cli into it, mirroring hyperswitch's own migration runner. The previous default (christophwurst/diesel-cli) pinned diesel 1.4.1, which ignores the `run_in_transaction = false` marker on the `CREATE INDEX CONCURRENTLY` migrations and so silently stopped part-way through the schema.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1326">initDB.migration.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1324">initDB.refs</a></div></td>
    <td><div><code>"tags"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1383">istio.destinationRule</a></div></td>
    <td><div><code>{
  "trafficPolicy": {}
}</code></div></td>
    <td>DestinationRule configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1385">istio.destinationRule.trafficPolicy</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Traffic policy configuration for router - rendered directly as YAML</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1340">istio.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable Istio resources</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1342">istio.virtualService</a></div></td>
    <td><div><code>{
  "create": true,
  "gateways": [],
  "hosts": [],
  "http": [
    {
      "match": [],
      "name": "primary",
      "retries": {},
      "timeout": "50s",
      "weight": 100
    }
  ]
}</code></div></td>
    <td>VirtualService configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1344">istio.virtualService.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Create VirtualService</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1348">istio.virtualService.gateways</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Gateways for the VirtualService</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1346">istio.virtualService.hosts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Hosts for the VirtualService</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1352">istio.virtualService.http</a></div></td>
    <td><div><code>[
  {
    "match": [],
    "name": "primary",
    "retries": {},
    "timeout": "50s",
    "weight": 100
  }
]</code></div></td>
    <td>HTTP routing rules (ordered list) Note: Rules are processed in the order they appear in this list. Ensure specific routes (like /api/) come before catch-all routes (like /).</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1708">kafka.broker.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1703">kafka.controller.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1746">kafka.extraConfig</a></div></td>
    <td><div><code>"offsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1692">kafka.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/kafka"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1713">kafka.zookeeper.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/zookeeper"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1554">loadBalancer.targetSecurityGroup</a></div></td>
    <td><div><code>"loadBalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2298">olap.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2300">olap.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2315">olap.autoscaling.maxReplicas</a></div></td>
    <td><div><code>4</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2314">olap.autoscaling.minReplicas</a></div></td>
    <td><div><code>2</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2316">olap.autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2286">olap.database.replicaHost</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2296">olap.env</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2307">olap.extraVolumeMounts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2306">olap.extraVolumes</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2267">olap.image</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2268">olap.imagePullPolicy</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2266">olap.imageRegistry</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2322">olap.ingress.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2321">olap.ingress.className</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2323">olap.ingress.hostname</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2324">olap.ingress.path</a></div></td>
    <td><div><code>"/olap"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2325">olap.ingress.pathType</a></div></td>
    <td><div><code>"Prefix"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2326">olap.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2351">olap.istio.destinationRule.trafficPolicy</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2335">olap.istio.virtualService.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2337">olap.istio.virtualService.gateways</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2336">olap.istio.virtualService.hosts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2344">olap.istio.virtualService.http[0].match[0].uri.prefix</a></div></td>
    <td><div><code>"/olap/"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2341">olap.istio.virtualService.http[0].name</a></div></td>
    <td><div><code>"primary"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2349">olap.istio.virtualService.http[0].retries</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2346">olap.istio.virtualService.http[0].rewrite.uri</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2348">olap.istio.virtualService.http[0].timeout</a></div></td>
    <td><div><code>"50s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2347">olap.istio.virtualService.http[0].weight</a></div></td>
    <td><div><code>100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2302">olap.labels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2303">olap.livenessProbe</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2299">olap.nodeSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2301">olap.podAnnotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2308">olap.progressDeadlineSeconds</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2304">olap.readinessProbe</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2305">olap.strategy</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2309">olap.terminationGracePeriodSeconds</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2297">olap.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2398">paymentMethodModular.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2400">paymentMethodModular.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2447">paymentMethodModular.argoRollouts</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2411">paymentMethodModular.autoscaling.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2413">paymentMethodModular.autoscaling.maxReplicas</a></div></td>
    <td><div><code>4</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2412">paymentMethodModular.autoscaling.minReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2414">paymentMethodModular.autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2377">paymentMethodModular.database.masterHost</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2378">paymentMethodModular.database.replicaHost</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2376">paymentMethodModular.database.useReplicaForMaster</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2396">paymentMethodModular.env</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2407">paymentMethodModular.extraVolumeMounts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2406">paymentMethodModular.extraVolumes</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2370">paymentMethodModular.image</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2371">paymentMethodModular.imagePullPolicy</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2369">paymentMethodModular.imageRegistry</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2418">paymentMethodModular.ingress.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2417">paymentMethodModular.ingress.className</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2416">paymentMethodModular.ingress.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2419">paymentMethodModular.ingress.hostname</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2420">paymentMethodModular.ingress.path</a></div></td>
    <td><div><code>"/v1/payment-methods"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2421">paymentMethodModular.ingress.pathType</a></div></td>
    <td><div><code>"Prefix"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2422">paymentMethodModular.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2446">paymentMethodModular.istio.destinationRule.trafficPolicy</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2424">paymentMethodModular.istio.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2426">paymentMethodModular.istio.virtualService.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2428">paymentMethodModular.istio.virtualService.gateways</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2427">paymentMethodModular.istio.virtualService.hosts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2435">paymentMethodModular.istio.virtualService.http[0].match[0].uri.prefix</a></div></td>
    <td><div><code>"/v1/payment-methods"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2437">paymentMethodModular.istio.virtualService.http[0].match[1].uri.prefix</a></div></td>
    <td><div><code>"/v1/payment-method-sessions"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2439">paymentMethodModular.istio.virtualService.http[0].match[2].uri.prefix</a></div></td>
    <td><div><code>"/v1/customers"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2441">paymentMethodModular.istio.virtualService.http[0].match[3].uri.prefix</a></div></td>
    <td><div><code>"/v1/proxy"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2432">paymentMethodModular.istio.virtualService.http[0].name</a></div></td>
    <td><div><code>"primary"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2444">paymentMethodModular.istio.virtualService.http[0].retries</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2443">paymentMethodModular.istio.virtualService.http[0].timeout</a></div></td>
    <td><div><code>"50s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2442">paymentMethodModular.istio.virtualService.http[0].weight</a></div></td>
    <td><div><code>100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2402">paymentMethodModular.labels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2403">paymentMethodModular.livenessProbe</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2399">paymentMethodModular.nodeSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2401">paymentMethodModular.podAnnotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2408">paymentMethodModular.progressDeadlineSeconds</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2404">paymentMethodModular.readinessProbe</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2372">paymentMethodModular.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2395">paymentMethodModular.resources</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2373">paymentMethodModular.serviceAccountName</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2405">paymentMethodModular.strategy</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2409">paymentMethodModular.terminationGracePeriodSeconds</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2397">paymentMethodModular.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2368">paymentMethodModular.version</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1226">postgresql.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1227">postgresql.image.tag</a></div></td>
    <td><div><code>"16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1179">redis.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/redis"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1180">redis.image.tag</a></div></td>
    <td><div><code>"7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1216">redisMiscConfig.checkRedisIsUp.initContainer.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1218">redisMiscConfig.checkRedisIsUp.initContainer.image</a></div></td>
    <td><div><code>"bitnamilegacy/redis:7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1217">redisMiscConfig.checkRedisIsUp.initContainer.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1219">redisMiscConfig.checkRedisIsUp.initContainer.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L163">server.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L185">server.binary</a></div></td>
    <td><div><code>"router"</code></div></td>
    <td>Binary to be used for the hyperswitch Router</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L253">server.configs.analytics.forex_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L222">server.configs.analytics.source</a></div></td>
    <td><div><code>"sqlx"</code></div></td>
    <td>The Analytics source/strategy to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L248">server.configs.analytics.sqlx.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L225">server.configs.analytics.sqlx.dbname</a></div></td>
    <td><div><code>{
  "_configRef": {
    "key": "ROUTER__MASTER_DATABASE__DBNAME",
    "name": "{{ .Release.Name }}-hyperswitch-configs"
  }
}</code></div></td>
    <td>Database name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L230">server.configs.analytics.sqlx.host</a></div></td>
    <td><div><code>{
  "_configRef": {
    "key": "ROUTER__MASTER_DATABASE__HOST",
    "name": "{{ .Release.Name }}-hyperswitch-configs"
  }
}</code></div></td>
    <td>Database host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L250">server.configs.analytics.sqlx.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L235">server.configs.analytics.sqlx.port</a></div></td>
    <td><div><code>{
  "_configRef": {
    "key": "ROUTER__MASTER_DATABASE__PORT",
    "name": "{{ .Release.Name }}-hyperswitch-configs"
  }
}</code></div></td>
    <td>Database port</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L252">server.configs.analytics.sqlx.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L240">server.configs.analytics.sqlx.username</a></div></td>
    <td><div><code>{
  "_configRef": {
    "key": "ROUTER__MASTER_DATABASE__USERNAME",
    "name": "{{ .Release.Name }}-hyperswitch-configs"
  }
}</code></div></td>
    <td>Database username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L256">server.configs.applepay_merchant_configs.applepay_endpoint</a></div></td>
    <td><div><code>"https://apple-pay-gateway.apple.com/paymentservices/registerMerchant"</code></div></td>
    <td>Apple pay gateway merchant endpoint</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L288">server.configs.cell_information.id</a></div></td>
    <td><div><code>"0a"</code></div></td>
    <td>Default CellID for Global Cell Information (max 2 characters)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L201">server.configs.chat.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L203">server.configs.chat.hyperswitch_ai_host</a></div></td>
    <td><div><code>"http://0.0.0.0:8000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L293">server.configs.clone_connector_allowlist.connector_names</a></div></td>
    <td><div><code>"stripe,adyen,paypal,checkout,braintree,cybersource,square,worldpay,klarna,noon,archipel"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L291">server.configs.clone_connector_allowlist.merchant_ids</a></div></td>
    <td><div><code>"merchant_ids"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L299">server.configs.connector_onboarding.paypal.client_id._secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L302">server.configs.connector_onboarding.paypal.client_secret._secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L296">server.configs.connector_onboarding.paypal.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L305">server.configs.connector_onboarding.paypal.partner_id._secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L308">server.configs.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id[0]</a></div></td>
    <td><div><code>"merchant_id_1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L308">server.configs.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id[1]</a></div></td>
    <td><div><code>"merchant_id_2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L321">server.configs.connectors.citigate</a></div></td>
    <td><div><code>{
  "base_url": "https://gw-test.cgate.tech"
}</code></div></td>
    <td>citigate and ilixium have no base_url in configs/router-*.toml on this tag either - the router hard-fails validation on any connector with an empty base_url.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L313">server.configs.connectors.hyperswitch_vault.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L324">server.configs.connectors.ilixium.base_url</a></div></td>
    <td><div><code>"https://prprocessing.ilixium.com/platform/ili"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L315">server.configs.connectors.unified_authentication_service</a></div></td>
    <td><div><code>{
  "base_url": "http://localhost:8080"
}</code></div></td>
    <td>Unified Authentication Service Configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L317">server.configs.connectors.unified_authentication_service.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td>base url to call unified authentication service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L350">server.configs.cors.allowed_methods</a></div></td>
    <td><div><code>"GET,POST,PUT,DELETE"</code></div></td>
    <td>List of methods that are allowed</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L353">server.configs.cors.max_age</a></div></td>
    <td><div><code>30</code></div></td>
    <td>Maximum time (in seconds) for which this CORS request may be cached.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L351">server.configs.cors.origin</a></div></td>
    <td><div><code>"https://hyperswti"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L355">server.configs.cors.wildcard_origin</a></div></td>
    <td><div><code>true</code></div></td>
    <td>If true, allows any origin to make requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L358">server.configs.crm.crm_manager</a></div></td>
    <td><div><code>"hubspot_proxy"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L361">server.configs.crm.hubspot_proxy.form_id</a></div></td>
    <td><div><code>"form_id"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L363">server.configs.crm.hubspot_proxy.request_url</a></div></td>
    <td><div><code>"request_url"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L366">server.configs.email.active_email_client</a></div></td>
    <td><div><code>"SMTP"</code></div></td>
    <td>The currently active email client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L368">server.configs.email.allowed_unverified_days</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of days the api calls ( with jwt token ) can be made without verifying the email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L390">server.configs.email.smtp.connection</a></div></td>
    <td><div><code>"plaintext"</code></div></td>
    <td>connection type to be used for the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L403">server.configs.email.smtp.port</a></div></td>
    <td><div><code>"1025"</code></div></td>
    <td>Port of the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L405">server.configs.email.smtp.timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>timeout for the smtp server connection</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L408">server.configs.encryption_management.encryption_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Encryption manager client to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L418">server.configs.events.kafka.api_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-api-log-events"</code></div></td>
    <td>Kafka topic to be used for incoming api events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L420">server.configs.events.kafka.attempt_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td>Kafka topic to be used for PaymentAttempt events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L422">server.configs.events.kafka.audit_events_topic</a></div></td>
    <td><div><code>"hyperswitch-audit-events"</code></div></td>
    <td>Kafka topic to be used for Payment Audit events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L424">server.configs.events.kafka.authentication_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-authentication-events"</code></div></td>
    <td>Kafka topic to be used for Authentication events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L425">server.configs.events.kafka.brokers[0]</a></div></td>
    <td><div><code>"kafka0:29092"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L427">server.configs.events.kafka.connector_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-connector-events"</code></div></td>
    <td>Kafka topic to be used for connector api events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L429">server.configs.events.kafka.consolidated_events_topic</a></div></td>
    <td><div><code>"hyperswitch-consolidated-events"</code></div></td>
    <td>Kafka topic to be used for Consolidated events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L431">server.configs.events.kafka.dispute_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td>Kafka topic to be used for Dispute events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L433">server.configs.events.kafka.fraud_check_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-fraud-check-events"</code></div></td>
    <td>Kafka topic to be used for Fraud Check events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L435">server.configs.events.kafka.intent_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td>Kafka topic to be used for PaymentIntent events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L437">server.configs.events.kafka.outgoing_webhook_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-webhook-events"</code></div></td>
    <td>Kafka topic to be used for outgoing webhook events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L439">server.configs.events.kafka.payout_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payout-events"</code></div></td>
    <td>Kafka topic to be used for Payouts and PayoutAttempt events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L441">server.configs.events.kafka.refund_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td>Kafka topic to be used for Refund events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L445">server.configs.events.kafka.revenue_recovery_topic</a></div></td>
    <td><div><code>"topic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L443">server.configs.events.kafka.routing_logs_topic</a></div></td>
    <td><div><code>"topic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L415">server.configs.events.source</a></div></td>
    <td><div><code>"kafka"</code></div></td>
    <td>The event sink to push events supports kafka or logs (stdout)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L778">server.configs.file_upload_config.bucket_name</a></div></td>
    <td><div><code>"bucket"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L779">server.configs.file_upload_config.region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L456">server.configs.forex_api.data_expiration_delay_in_seconds</a></div></td>
    <td><div><code>21600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L458">server.configs.forex_api.redis_lock_timeout_in_seconds</a></div></td>
    <td><div><code>100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L460">server.configs.forex_api.redis_ttl_in_seconds</a></div></td>
    <td><div><code>172800</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L472">server.configs.generic_link.payment_method_collect.enabled_payment_methods.bank_transfer</a></div></td>
    <td><div><code>"ach,bacs,sepa"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L471">server.configs.generic_link.payment_method_collect.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L473">server.configs.generic_link.payment_method_collect.enabled_payment_methods.wallet</a></div></td>
    <td><div><code>"paypal,pix,venmo"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L465">server.configs.generic_link.payment_method_collect.expiry</a></div></td>
    <td><div><code>"900"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L464">server.configs.generic_link.payment_method_collect.sdk_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Auto-generated from services.sdk. Override with custom URL if needed.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L467">server.configs.generic_link.payment_method_collect.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L468">server.configs.generic_link.payment_method_collect.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L469">server.configs.generic_link.payment_method_collect.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L479">server.configs.generic_link.payout_link.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L477">server.configs.generic_link.payout_link.expiry</a></div></td>
    <td><div><code>"900"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L476">server.configs.generic_link.payout_link.sdk_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Auto-generated from services.sdk. Override with custom URL if needed.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L481">server.configs.generic_link.payout_link.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L482">server.configs.generic_link.payout_link.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L483">server.configs.generic_link.payout_link.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L647">server.configs.google_pay_decrypt_keys.google_pay_root_signing_keys</a></div></td>
    <td><div><code>"GOOGLE_PAY_ROOT_SIGNING_KEYS"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L491">server.configs.grpc_client.dynamic_routing_client.host</a></div></td>
    <td><div><code>"localhost"</code></div></td>
    <td>Client Host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L493">server.configs.grpc_client.dynamic_routing_client.port</a></div></td>
    <td><div><code>7000</code></div></td>
    <td>Client Port</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L495">server.configs.grpc_client.dynamic_routing_client.service</a></div></td>
    <td><div><code>"dynamo"</code></div></td>
    <td>Client Service Name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L506">server.configs.grpc_client.recovery_decider_client.base_url</a></div></td>
    <td><div><code>"http://127.0.0.1:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L498">server.configs.grpc_client.unified_connector_service.base_url</a></div></td>
    <td><div><code>"http://localhost:8000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L500">server.configs.grpc_client.unified_connector_service.connection_timeout</a></div></td>
    <td><div><code>"10"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L502">server.configs.grpc_client.unified_connector_service.ucs_only_connectors</a></div></td>
    <td><div><code>"paytm, phonepe"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L198">server.configs.infra_values.version</a></div></td>
    <td><div><code>"IMAGE_VERSION_VALUE"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L842">server.configs.jwekey.rust_locker_encryption_key._secret</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsn4glmrihAG7Vppqd3Hm\nRXZiGmuZW0J+NQt72453oSnGc6Sw1Fk/vY0WhQIn6/Ip1Xt6dnMyorI3b9RtfQNP\nDFND3/g7n2I9uMqEr6aYxg0pKw9UW3uBlzR5JzvMVnzEjIRfdtuqSlphdpAVuZPE\nFEN9kE/VasBIeaKmbYFZxmz4AN2IBBvqWCaqIQZOrTRzfGNhVBlX/O+Sv59cy6n6\nQEoYJ/Ww3R7cUlSrueQNlSubkoa8ihBcm9VA7Bdklrps7B17yzMTAgqhZPkLMIQQ\nDBI1vFDlSKrWHNXfm4WyAXJ8MXOl+ThNJdAoDw2wNJmfOrgaPQFiMfPZYgKl/2Gu\nYQIDAQAB\n-----END PUBLIC KEY-----\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L839">server.configs.jwekey.tunnel_private_key._secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L858">server.configs.key_manager</a></div></td>
    <td><div><code>{
  "ca": {
    "_secret": "sample_ca"
  },
  "cert": {
    "_secret": "sample_cert"
  },
  "enabled": false,
  "url": ""
}</code></div></td>
    <td>Encryption key used for encrypting data in user_authentication_methods table</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L860">server.configs.key_manager.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable or disable keymanager</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L862">server.configs.key_manager.url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>KeyManager service URL</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L783">server.configs.kms.key_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS KMS region</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L529">server.configs.kv_config.soft_kill</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L528">server.configs.kv_config.ttl</a></div></td>
    <td><div><code>900</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L532">server.configs.lock_settings.delay_between_retries_in_milliseconds</a></div></td>
    <td><div><code>500</code></div></td>
    <td>Delay between retries in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L534">server.configs.lock_settings.redis_lock_expiry_seconds</a></div></td>
    <td><div><code>180</code></div></td>
    <td>Seconds before the redis lock expires</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L540">server.configs.locker.host</a></div></td>
    <td><div><code>"http://hyperswitch-vault"</code></div></td>
    <td>Locker host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L542">server.configs.locker.host_rs</a></div></td>
    <td><div><code>null</code></div></td>
    <td>Rust Locker host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L544">server.configs.locker.locker_enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Boolean to enable or disable saving cards in locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L546">server.configs.locker.locker_signing_key_id</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td>Key_id to sign basilisk hs locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L548">server.configs.locker.mock_locker</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Emulate a locker locally using Postgres</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L550">server.configs.locker.ttl_for_storage_in_secs</a></div></td>
    <td><div><code>220752000</code></div></td>
    <td>Time to live for storage entries in locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L557">server.configs.log.console.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L559">server.configs.log.console.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td>Log level for console logs, ERROR, WARN, INFO, DEBUG</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L560">server.configs.log.console.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L562">server.configs.log.file.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L563">server.configs.log.file.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L564">server.configs.log.file.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L568">server.configs.log.telemetry.bg_metrics_collection_interval_in_secs</a></div></td>
    <td><div><code>15</code></div></td>
    <td>Interval for collecting the metrics in background thread</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L570">server.configs.log.telemetry.ignore_errors</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether to ignore errors during traces or metrics pipeline setup</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L572">server.configs.log.telemetry.metrics_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether metrics are enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L577">server.configs.log.telemetry.otel_exporter_otlp_endpoint</a></div></td>
    <td><div><code>""</code></div></td>
    <td>URL for external OpenTelemetry Collector endpoint to send metrics and traces to. The OpenTelemetry Collector must have a gRPC OTLP receiver listening at this endpoint. If left empty, the endpoint will be auto-configured as: <release-name>-opentelemetry-collector.<namespace>.svc.cluster.local:4317 when using hyperswitch-stack with monitoring enabled. Leave empty for auto-configuration or specify custom endpoint.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L579">server.configs.log.telemetry.otel_exporter_otlp_timeout</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>timeout (in milliseconds) for sending metrics and traces</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L580">server.configs.log.telemetry.route_to_trace[0]</a></div></td>
    <td><div><code>"*/confirm"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L581">server.configs.log.telemetry.sampling_rate</a></div></td>
    <td><div><code>0.1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L583">server.configs.log.telemetry.traces_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether traces are enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L585">server.configs.log.telemetry.use_xray_generator</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Set this to true for AWS X-ray compatible traces</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L593">server.configs.master_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L595">server.configs.master_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L597">server.configs.master_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L589">server.configs.merchant_id_auth.merchant_id_auth_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L599">server.configs.multitenancy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L601">server.configs.multitenancy.global_tenant.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L602">server.configs.multitenancy.global_tenant.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L603">server.configs.multitenancy.global_tenant.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L604">server.configs.multitenancy.global_tenant.tenant_id</a></div></td>
    <td><div><code>"global"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L609">server.configs.multitenancy.tenants.public.accounts_schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L607">server.configs.multitenancy.tenants.public.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L611">server.configs.multitenancy.tenants.public.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L610">server.configs.multitenancy.tenants.public.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L608">server.configs.multitenancy.tenants.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L613">server.configs.multitenancy.tenants.public.user.control_center_url</a></div></td>
    <td><div><code>"http://localhost:9000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L341">server.configs.network_tokenization_service.check_token_status_url</a></div></td>
    <td><div><code>"https://example.com/status"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L343">server.configs.network_tokenization_service.check_tokenize_eligibility_url</a></div></td>
    <td><div><code>"https://example.com/cardbins"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L339">server.configs.network_tokenization_service.delete_token_url</a></div></td>
    <td><div><code>"https://example.com/delete"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L345">server.configs.network_tokenization_service.fetch_altid_url</a></div></td>
    <td><div><code>"https://example.com/altid"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L329">server.configs.network_tokenization_service.fetch_token_url</a></div></td>
    <td><div><code>"https://example.com/fetch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L327">server.configs.network_tokenization_service.generate_token_url</a></div></td>
    <td><div><code>"https://example.com/generate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L337">server.configs.network_tokenization_service.key_id</a></div></td>
    <td><div><code>"key_id"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L335">server.configs.network_tokenization_service.private_key</a></div></td>
    <td><div><code>"private_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L333">server.configs.network_tokenization_service.public_key</a></div></td>
    <td><div><code>"public_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L331">server.configs.network_tokenization_service.token_service_api_key</a></div></td>
    <td><div><code>"api_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L347">server.configs.network_tokenization_service.webhook_source_verification_key</a></div></td>
    <td><div><code>"placeholder_webhook_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L616">server.configs.opensearch.auth.auth</a></div></td>
    <td><div><code>"basic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L618">server.configs.opensearch.auth.password</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L619">server.configs.opensearch.auth.region</a></div></td>
    <td><div><code>"eu-central-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L617">server.configs.opensearch.auth.username</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L621">server.configs.opensearch.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L620">server.configs.opensearch.host</a></div></td>
    <td><div><code>"https://localhost:9200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L623">server.configs.opensearch.indexes.disputes</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L624">server.configs.opensearch.indexes.payment_attempts</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L625">server.configs.opensearch.indexes.payment_intents</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L631">server.configs.opensearch.indexes.payouts</a></div></td>
    <td><div><code>"hyperswitch-payout-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L626">server.configs.opensearch.indexes.refunds</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L627">server.configs.opensearch.indexes.sessionizer_disputes</a></div></td>
    <td><div><code>"sessionizer-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L628">server.configs.opensearch.indexes.sessionizer_payment_attempts</a></div></td>
    <td><div><code>"sessionizer-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L629">server.configs.opensearch.indexes.sessionizer_payment_intents</a></div></td>
    <td><div><code>"sessionizer-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L630">server.configs.opensearch.indexes.sessionizer_refunds</a></div></td>
    <td><div><code>"sessionizer-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L486">server.configs.payment_link.sdk_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Auto-generated from services.sdk. Override with custom URL if needed.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L638">server.configs.payment_method_auth.redis_expiry</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Redis expiry time in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L650">server.configs.proxy.bypass_proxy_hosts</a></div></td>
    <td><div><code>"localhost, cluster.local"</code></div></td>
    <td>A comma-separated list of domains or IP addresses that should not use the proxy. Whitespace between entries would be ignored.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L651">server.configs.proxy.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L653">server.configs.proxy.http_url</a></div></td>
    <td><div><code>"http://proxy_http_url"</code></div></td>
    <td>Outgoing proxy http URL to proxy the HTTP traffic</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L655">server.configs.proxy.https_url</a></div></td>
    <td><div><code>"https://proxy_https_url"</code></div></td>
    <td>Outgoing proxy https URL to proxy the HTTPS traffic</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L658">server.configs.proxy_status_mapping.proxy_connector_http_status_code</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L662">server.configs.redis.auto_pipeline</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Whether or not the client should automatically pipeline commands across tasks when possible.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L664">server.configs.redis.cluster_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L666">server.configs.redis.cluster_urls</a></div></td>
    <td><div><code>[
  "redis.cluster.uri-1:8080",
  "redis.cluster.uri-2:4115"
]</code></div></td>
    <td>List of redis cluster urls</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L668">server.configs.redis.default_command_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>An optional timeout to apply to all commands. In seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L670">server.configs.redis.default_hash_ttl</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Default TTL for hashes entries, in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L672">server.configs.redis.default_ttl</a></div></td>
    <td><div><code>300</code></div></td>
    <td>Default TTL for entries, in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L674">server.configs.redis.disable_auto_backpressure</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Whether or not to disable the automatic backpressure features when pipelining is enabled.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L676">server.configs.redis.max_feed_count</a></div></td>
    <td><div><code>200</code></div></td>
    <td>The maximum number of frames that will be fed to a socket before flushing.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L678">server.configs.redis.max_in_flight_commands</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>The maximum number of in-flight commands (per connection) before backpressure will be applied.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L680">server.configs.redis.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L682">server.configs.redis.reconnect_delay</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Delay between reconnection attempts, in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L684">server.configs.redis.reconnect_max_attempts</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Maximum number of reconnection attempts to make before failing. Set to 0 to retry forever.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L686">server.configs.redis.stream_read_count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Default number of entries to read from stream if not provided in stream read options</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L688">server.configs.redis.unresponsive_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>An optional timeout for Unresponsive commands in seconds. This should be less than default_command_timeout.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L690">server.configs.redis.use_legacy_version</a></div></td>
    <td><div><code>false</code></div></td>
    <td>RESP protocol for fred crate (set this to true if using RESPv2 or redis version < 6)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L694">server.configs.replica_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L696">server.configs.replica_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L698">server.configs.replica_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L711">server.configs.report_download_config.authentication_function</a></div></td>
    <td><div><code>"report_download_config_authentication_function"</code></div></td>
    <td>Config to authentication function</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L701">server.configs.report_download_config.dispute_function</a></div></td>
    <td><div><code>"report_download_config_dispute_function"</code></div></td>
    <td>Config to download dispute report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L703">server.configs.report_download_config.payment_function</a></div></td>
    <td><div><code>"report_download_config_payment_function"</code></div></td>
    <td>Config to download payment report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L707">server.configs.report_download_config.payout_function</a></div></td>
    <td><div><code>"report_download_config_payout_function"</code></div></td>
    <td>Config to download payout report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L705">server.configs.report_download_config.refund_function</a></div></td>
    <td><div><code>"report_download_config_refund_function"</code></div></td>
    <td>Config to download refund report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L709">server.configs.report_download_config.region</a></div></td>
    <td><div><code>"report_download_config_region"</code></div></td>
    <td>Region of the bucket</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L713">server.configs.report_download_config.relay_function</a></div></td>
    <td><div><code>"report_download_config_relay_function"</code></div></td>
    <td>Config to download relay report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L722">server.configs.revenue_recovery.card_config.amex.max_retries_per_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L723">server.configs.revenue_recovery.card_config.amex.max_retry_count_for_thirty_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L731">server.configs.revenue_recovery.card_config.discover.max_retries_per_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L732">server.configs.revenue_recovery.card_config.discover.max_retry_count_for_thirty_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L725">server.configs.revenue_recovery.card_config.mastercard.max_retries_per_day</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L726">server.configs.revenue_recovery.card_config.mastercard.max_retry_count_for_thirty_day</a></div></td>
    <td><div><code>35</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L728">server.configs.revenue_recovery.card_config.visa.max_retries_per_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L729">server.configs.revenue_recovery.card_config.visa.max_retry_count_for_thirty_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L716">server.configs.revenue_recovery.monitoring_threshold_in_seconds</a></div></td>
    <td><div><code>10368000</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L736">server.configs.revenue_recovery.recovery_timestamp.initial_timestamp_in_seconds</a></div></td>
    <td><div><code>3600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L737">server.configs.revenue_recovery.recovery_timestamp.job_schedule_buffer_time_in_seconds</a></div></td>
    <td><div><code>900</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L739">server.configs.revenue_recovery.recovery_timestamp.max_random_schedule_delay_in_seconds</a></div></td>
    <td><div><code>18000</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L740">server.configs.revenue_recovery.recovery_timestamp.redis_ttl_buffer_in_seconds</a></div></td>
    <td><div><code>300</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L738">server.configs.revenue_recovery.recovery_timestamp.reopen_workflow_buffer_time_in_seconds</a></div></td>
    <td><div><code>3600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L741">server.configs.revenue_recovery.recovery_timestamp.unretried_invoice_schedule_time_offset_seconds</a></div></td>
    <td><div><code>300</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L718">server.configs.revenue_recovery.redis_ttl_in_seconds</a></div></td>
    <td><div><code>3888000</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L717">server.configs.revenue_recovery.retry_algorithm_type</a></div></td>
    <td><div><code>"cascading"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L895">server.configs.secrets.migration_encryption_timestamp._secret</a></div></td>
    <td><div><code>"1685510751"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L744">server.configs.secrets_management.secrets_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Secrets manager client to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L769">server.configs.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L770">server.configs.server.port</a></div></td>
    <td><div><code>8080</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L772">server.configs.server.request_body_limit</a></div></td>
    <td><div><code>32768</code></div></td>
    <td>HTTP Request body limit. Defaults to 32kB</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L775">server.configs.server.shutdown_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>For more details: https://actix.rs/docs/server/#graceful-shutdown</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L776">server.configs.server.workers</a></div></td>
    <td><div><code>8</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L756">server.configs.superposition</a></div></td>
    <td><div><code>{
  "endpoint": "",
  "org_id": "hyperswitch",
  "token": "123456",
  "workspace_id": "hyperswitch"
}</code></div></td>
    <td>Superposition client config (mandatory at boot as of newer router builds). Defaults assume the bundled `superposition` subchart under this release name.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L760">server.configs.superposition.endpoint</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Superposition service URL. Left empty it resolves to the Superposition of this release (`http://<release>-superposition.<namespace>.svc.cluster.local:80`), so it follows the release name instead of being pinned to one. Set it explicitly to point somewhere else.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L762">server.configs.superposition.token</a></div></td>
    <td><div><code>"123456"</code></div></td>
    <td>Must match the subchart's SUPERPOSITION_TOKEN below (defaults to "123456").</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L526">server.configs.theme.email_config.background_color</a></div></td>
    <td><div><code>"#FFFFFF"</code></div></td>
    <td>Background color of email body</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L520">server.configs.theme.email_config.entity_logo_url</a></div></td>
    <td><div><code>"https://example.com/logo.png"</code></div></td>
    <td>Logo URL of the entity to be used in emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L518">server.configs.theme.email_config.entity_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td>Name of the entity to be showed in emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L522">server.configs.theme.email_config.foreground_color</a></div></td>
    <td><div><code>"#000000"</code></div></td>
    <td>Foreground color of email text</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L524">server.configs.theme.email_config.primary_color</a></div></td>
    <td><div><code>"#006DF9"</code></div></td>
    <td>Primary color of email body</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L515">server.configs.theme.storage.aws_s3.bucket_name</a></div></td>
    <td><div><code>"bucket"</code></div></td>
    <td>AWS S3 bucket name for theme storage</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L513">server.configs.theme.storage.aws_s3.region</a></div></td>
    <td><div><code>"bucket_region"</code></div></td>
    <td>AWS region where the S3 bucket for theme storage is located</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L510">server.configs.theme.storage.file_storage_backend</a></div></td>
    <td><div><code>"aws_s3"</code></div></td>
    <td>Theme storage backend to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L183">server.env</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Environmant variables that are to be used by the hyperswitch application service this will extend the existing global configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L171">server.extraVolumeMounts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Extra volume mounts for the router container</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L169">server.extraVolumes</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Extra volumes for the router pods, e.g. a ConfigMap holding a Superposition fallback seed. Inherited by the olap and paymentMethodModular services unless they set their own.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L105">server.ingress.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Custom annotations for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L103">server.ingress.className</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Ingress class name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L101">server.ingress.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L107">server.ingress.hostname</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Hostname for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L109">server.ingress.path</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td>Path for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L111">server.ingress.pathType</a></div></td>
    <td><div><code>"Prefix"</code></div></td>
    <td>Path type for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L113">server.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>TLS configuration for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L165">server.labels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L160">server.podAnnotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L115">server.progressDeadlineSeconds</a></div></td>
    <td><div><code>600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L98">server.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for the application</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L147">server.resources</a></div></td>
    <td><div><code>{
  "limits": {
    "cpu": "1000m",
    "memory": "1Gi"
  },
  "requests": {
    "cpu": "200m",
    "memory": "500Mi"
  }
}</code></div></td>
    <td>Resource requests and limits for the router/server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L187">server.run_env</a></div></td>
    <td><div><code>"sandbox"</code></div></td>
    <td>Processor URLs will be decided based on this config, Eg: production, sandbox or integ</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L178">server.serviceAccount.annotations</a></div></td>
    <td><div><code>{
  "eks.amazonaws.com/role-arn": "my-role-arn"
}</code></div></td>
    <td>Annotations to be added to the service account</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L174">server.serviceAccount.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Service account creation for the application</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L181">server.serviceAccount.labels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Labels to be added to the service account</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L176">server.serviceAccount.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Service account name for the application ( default: <release-name>-hyperswitch-router-role)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L119">server.strategy.rollingUpdate.maxSurge</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L120">server.strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L121">server.strategy.type</a></div></td>
    <td><div><code>"RollingUpdate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L158">server.terminationGracePeriodSeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td>The time kubernetes will wait after sending the termination signal to the pods</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L17">services.consumer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L39">services.drainer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L28">services.producer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L3">services.router.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2140">superpositionDB.aliasService</a></div></td>
    <td><div><code>"superposition-db"</code></div></td>
    <td>Name of the ExternalName Service. Must match the host in `superposition.configs.db_host`. Change both together if two releases share a namespace.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2137">superpositionDB.enable</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Create the alias Service and, if enabled below, run the schema Job.  Off by default: the alias Service has a fixed, release-independent name (that is the point of it), so two releases of this chart in one namespace would collide on it. Turn it on when a single release owns the namespace - `hyperswitch-stack` does exactly that. When you do, set `superposition.configs.db_host` to `<aliasService>:5432` and `db_name` / `db_user` / `secrets.db_password` to this release's PostgreSQL credentials.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2143">superpositionDB.migration.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Apply files/superposition.sql to `superposition.configs.db_name`</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2145">superpositionDB.migration.image</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2144">superpositionDB.migration.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1617">superpositionFallback.configMap</a></div></td>
    <td><div><code>"superposition-seed"</code></div></td>
    <td>Name of the ConfigMap holding the seed file, for `source: configMap`. Create it yourself; it is not part of the chart.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1593">superpositionFallback.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Mount a Superposition seed file as the fallback config source</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1597">superpositionFallback.fetch</a></div></td>
    <td><div><code>{
  "baseUrl": "https://raw.githubusercontent.com/juspay/hyperswitch",
  "image": "curlimages/curl:8.11.1",
  "imageRegistry": "docker.io",
  "path": "config/superposition_seed.toml",
  "resources": {
    "limits": {
      "cpu": "200m",
      "memory": "128Mi"
    },
    "requests": {
      "cpu": "25m",
      "memory": "32Mi"
    }
  },
  "version": ""
}</code></div></td>
    <td>Settings for `source: fetch`</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1603">superpositionFallback.fetch.baseUrl</a></div></td>
    <td><div><code>"https://raw.githubusercontent.com/juspay/hyperswitch"</code></div></td>
    <td>Base URL of the hyperswitch source repository</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1601">superpositionFallback.fetch.image</a></div></td>
    <td><div><code>"curlimages/curl:8.11.1"</code></div></td>
    <td>Image that performs the download; needs `curl` and `sh`</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1599">superpositionFallback.fetch.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td>Registry for the image that performs the download</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1605">superpositionFallback.fetch.path</a></div></td>
    <td><div><code>"config/superposition_seed.toml"</code></div></td>
    <td>Path of the seed file inside that repository</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1607">superpositionFallback.fetch.version</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Ref to download from. Empty means `services.router.version`, so the seed matches the router.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1619">superpositionFallback.key</a></div></td>
    <td><div><code>"superposition_seed.toml"</code></div></td>
    <td>Key inside that ConfigMap</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1623">superpositionFallback.mountPath</a></div></td>
    <td><div><code>"/local/config/superposition/superposition_seed.toml"</code></div></td>
    <td>Path the file is mounted at, and the value of ROUTER__SUPERPOSITION__BACKUP_FILE_PATH. Under `source: fetch` the parent directory is the mount point, so keep it in a directory of its own rather than directly in /local/config.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1595">superpositionFallback.source</a></div></td>
    <td><div><code>"fetch"</code></div></td>
    <td>Where the seed file comes from: `fetch` (init container) or `configMap` (bring your own)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2094">superposition_fallback_cronjob.aws_kms</a></div></td>
    <td><div><code>{
  "key_id": "",
  "region": ""
}</code></div></td>
    <td>AWS KMS configuration used by the config backup job</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2098">superposition_fallback_cronjob.aws_kms.key_id</a></div></td>
    <td><div><code>""</code></div></td>
    <td>KMS key ID or ARN used for encryption and decryption</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2096">superposition_fallback_cronjob.aws_kms.region</a></div></td>
    <td><div><code>""</code></div></td>
    <td>AWS region containing the KMS key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2076">superposition_fallback_cronjob.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable the CronJob that syncs superposition config to EFS</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2090">superposition_fallback_cronjob.failedJobsHistoryLimit</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of failed job runs to retain in history</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2082">superposition_fallback_cronjob.image</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Container image for the backup job</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2084">superposition_fallback_cronjob.imagePullPolicy</a></div></td>
    <td><div><code>"IfNotPresent"</code></div></td>
    <td>Image pull policy</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2078">superposition_fallback_cronjob.name</a></div></td>
    <td><div><code>"superposition-config-backup-cronjob"</code></div></td>
    <td>Name of the CronJob resource</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2114">superposition_fallback_cronjob.resources</a></div></td>
    <td><div><code>{
  "limits": {
    "cpu": "100m",
    "memory": "64Mi"
  },
  "requests": {
    "cpu": "25m",
    "memory": "32Mi"
  }
}</code></div></td>
    <td>Resource requests and limits for the cronjob container</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2086">superposition_fallback_cronjob.restartPolicy</a></div></td>
    <td><div><code>"OnFailure"</code></div></td>
    <td>Restart policy for the job pod</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2092">superposition_fallback_cronjob.retentionCount</a></div></td>
    <td><div><code>"10"</code></div></td>
    <td>Number of backup files to retain in EFS</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2080">superposition_fallback_cronjob.schedule</a></div></td>
    <td><div><code>"* * * * *"</code></div></td>
    <td>Cron schedule (minimum Kubernetes CronJob interval is 1 minute)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2088">superposition_fallback_cronjob.successfulJobsHistoryLimit</a></div></td>
    <td><div><code>3</code></div></td>
    <td>Number of successful job runs to retain in history</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2100">superposition_fallback_cronjob.superposition</a></div></td>
    <td><div><code>{
  "endpoint": "http://localhost:8081",
  "orgId": "",
  "tokenSecretKey": "ROUTER__SUPERPOSITION__TOKEN",
  "tokenSecretName": "hyperswitch-secrets",
  "workspaceId": ""
}</code></div></td>
    <td>Superposition service connection details</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2102">superposition_fallback_cronjob.superposition.endpoint</a></div></td>
    <td><div><code>"http://localhost:8081"</code></div></td>
    <td>Superposition API endpoint URL</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2110">superposition_fallback_cronjob.superposition.orgId</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Superposition organisation ID (must match superposition.org_id)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2108">superposition_fallback_cronjob.superposition.tokenSecretKey</a></div></td>
    <td><div><code>"ROUTER__SUPERPOSITION__TOKEN"</code></div></td>
    <td>Key within the secret that holds the token value</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2106">superposition_fallback_cronjob.superposition.tokenSecretName</a></div></td>
    <td><div><code>"hyperswitch-secrets"</code></div></td>
    <td>Name of the Kubernetes Secret containing the Superposition API token.   tokenSecretName: "hyperswitch-secrets"   tokenSecretKey: "ROUTER__SUPERPOSITION__TOKEN"</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2112">superposition_fallback_cronjob.superposition.workspaceId</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Superposition workspace ID (must match superposition.workspace_id)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2064">superposition_fallback_efs.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable creation of an EFS-backed PVC and volumeMounts in all pods</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2072">superposition_fallback_efs.mountPath</a></div></td>
    <td><div><code>"/mnt/data"</code></div></td>
    <td>Mount path inside the containers for the EFS volume</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2066">superposition_fallback_efs.pvcName</a></div></td>
    <td><div><code>"superposition-config-backup"</code></div></td>
    <td>Name of the PersistentVolumeClaim to create and reference</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2070">superposition_fallback_efs.storage</a></div></td>
    <td><div><code>"1Gi"</code></div></td>
    <td>Storage size for the PVC</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L2068">superposition_fallback_efs.storageClassName</a></div></td>
    <td><div><code>"efs-sc"</code></div></td>
    <td>StorageClass to use for the PVC (must have an EFS CSI provisioner)</td>
  </tr>
</tbody>
</table>

