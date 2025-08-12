<p align="center">
  <img src="https://raw.githubusercontent.com/juspay/hyperswitch/refs/heads/main/docs/imgs/hyperswitch-logo-dark.svg#gh-dark-mode-only" alt="Hyperswitch-Logo" width="40%" />
  <img src="https://raw.githubusercontent.com/juspay/hyperswitch/refs/heads/main/docs/imgs/hyperswitch-logo-light.svg#gh-light-mode-only" alt="Hyperswitch-Logo" width="40%" />
</p>

<h1 align="center">The open-source payments switch</h1>

<div align="center" >
The single API to access payment ecosystems across 130+ countries</div>

<p align="center">
  <a href="#try-a-payment">💳 Try a Payment</a> •
  <a href="#quick-setup">Setup in k8s</a> •
  <a href="https://api-reference.hyperswitch.io/introduction"> API Docs </a>
   <br>
  <a href="#community-contributions">Community and Contributions</a> •
  <a href="#copyright-and-license">Copyright and License</a>
</p>

<p align="center">
  <a href="https://github.com/juspay/hyperswitch/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/juspay/hyperswitch" />
  </a>
</p>
<p align="center">
  <a href="https://www.linkedin.com/company/hyperswitch/">
    <img src="https://img.shields.io/badge/follow-hyperswitch-blue?logo=linkedin&labelColor=grey"/>
  </a>
  <a href="https://x.com/hyperswitchio">
    <img src="https://img.shields.io/badge/follow-%40hyperswitchio-white?logo=x&labelColor=grey"/>
  </a>
  <a href="https://join.slack.com/t/hyperswitch-io/shared_invite/zt-2jqxmpsbm-WXUENx022HjNEy~Ark7Orw">
    <img src="https://img.shields.io/badge/chat-on_slack-blue?logo=slack&labelColor=grey&color=%233f0e40"/>
  </a>
</p>

<hr>

Hyperswitch is a community-led, open payments switch designed to empower digital businesses by providing fast, reliable, and affordable access to the best payments infrastructure.

Here are the components of Hyperswitch that deliver the whole solution:

* [Hyperswitch Backend](https://github.com/juspay/hyperswitch): Powering Payment Processing

* [SDK (Frontend)](https://github.com/juspay/hyperswitch-web): Simplifying Integration and Powering the UI

* [Control Centre](https://github.com/juspay/hyperswitch-control-center): Managing Operations with Ease

Jump in and contribute to these repositories to help improve and expand Hyperswitch!

<img src="https://raw.githubusercontent.com/juspay/hyperswitch/refs/heads/main/docs/imgs/switch.png" />

<a href="https://app.hyperswitch.io/">
  <h2 id="try-a-payment">💳 Try a Payment</h2>
</a>

To quickly experience the ease of Hyperswitch, sign up on the [Hyperswitch Control Center](https://app.hyperswitch.io/) and try a payment. Once you've completed your first transaction, you’ve successfully made your first payment with Hyperswitch!

<a href="#Quick Setup">
  <h2 id="quick-setup">⚡️ Quick Setup</h2>
</a>

# Deploy on Kubernetes using Helm

This section outlines cloud-provider agnostic deployment steps for easy installation of the Hyperswitch stack on your K8s cluster

## Installation

### Step 1 - Clone repo and Update Configurations

Clone the [hyperswitch-stack](https://github.com/juspay/hyperswitch-helm) repo and start updating the configs

```bash
helm repo add hyperswitch https://juspay.github.io/hyperswitch-helm
helm repo update
```

### Step 2 - Install Hyperswitch

Before installing the service make sure you labels your kubernetes nodes and create a namespace `hyperswitch`
Note: minimum --memory 6000 --cpus 4 needed
```bash
kubectl create namespace hyperswitch
```
Use below command to install hyperswitch services with above configs

```bash
helm install hypers-v1 hyperswitch/hyperswitch-stack -n hyperswitch
```

That's it! Hyperswitch should be up and running on your Cluster  :tada: :tada:

## Post-Deployment Checklist

After deploying the Helm chart, you should verify that everything is working correctly

### App Server

* [ ] &#x20;Check that `hyperswitch_server/health` returns `health is good`

### Control Center

* [ ] &#x20;Verify if you are able to sign in or sign up
* [ ] &#x20;Verify if you are able to [create API key](https://docs.hyperswitch.io/hyperswitch-open-source/account-setup/using-hyperswitch-control-center#user-content-create-an-api-key)
* [ ] &#x20;Verify if you are able to [configure a new payment processor](https://docs.hyperswitch.io/hyperswitch-open-source/account-setup/using-hyperswitch-control-center#add-a-payment-processor)

### UCS (Unified Connector Service)

* [ ] &#x20;Check that the gRPC health endpoint is responding: `grpcurl -plaintext localhost:8000 grpc.health.v1.Health/Check`
* [ ] &#x20;Verify metrics are being exposed at `localhost:8080/metrics`

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

<a href="#community-contributions">
  <h2 id="community-contributions">✅ Community & Contributions</h2>
</a>

The community and core team are available in [GitHub Discussions](https://github.com/juspay/hyperswitch/discussions), where you can ask for support, discuss roadmap, and share ideas.

Join our Conversation in [Slack](https://join.slack.com/t/hyperswitch-io/shared_invite/zt-2jqxmpsbm-WXUENx022HjNEy~Ark7Orw), [Discord](https://discord.gg/wJZ7DVW8mm), [Twitter](https://x.com/hyperswitchio)

When you want others to use the changes you have added you need to package it and then index it
```bash
# To package and index the new changes
task pihh
# To update readme file
task ur
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../hyperswitch-app | hyperswitch-app | 0.2.11 |
| file://../hyperswitch-monitoring | hyperswitch-monitoring | 0.1.2 |
| file://../hyperswitch-ucs | hyperswitch-ucs | 0.1.1 |
| file://../hyperswitch-web | hyperswitch-web | 0.2.10 |

## Values
<h3>Dependencies configuration</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1244">hyperswitch-app.clickhouse.auth.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Clickhouse password</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1241">hyperswitch-app.clickhouse.auth.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1250">hyperswitch-app.clickhouse.config.TZ</a></div></td>
    <td><div><code>"Asia/Kolkata"</code></div></td>
    <td>Clickhouse timezone</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1233">hyperswitch-app.clickhouse.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Clickhouse sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1237">hyperswitch-app.clickhouse.fullnameOverride</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>Name of the Clickhouse sub-chart</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1263">hyperswitch-app.clickhouse.logLevel</a></div></td>
    <td><div><code>"error"</code></div></td>
    <td>Clickhouse log level</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1256">hyperswitch-app.clickhouse.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse replica count</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1253">hyperswitch-app.clickhouse.shards</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse shard count</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1260">hyperswitch-app.clickhouse.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Zookerper replica count</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1103">hyperswitch-app.externalPostgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Postgres server</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1120">hyperswitch-app.externalPostgresql.primary.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB name</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1114">hyperswitch-app.externalPostgresql.primary.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB password</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1117">hyperswitch-app.externalPostgresql.primary.auth.plainpassword</a></div></td>
    <td><div><code>null</code></div></td>
    <td>master DB plainpassword</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1111">hyperswitch-app.externalPostgresql.primary.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB username</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1107">hyperswitch-app.externalPostgresql.primary.host</a></div></td>
    <td><div><code>"postgresql-ext"</code></div></td>
    <td>External postgres host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1140">hyperswitch-app.externalPostgresql.readOnly.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB name</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1134">hyperswitch-app.externalPostgresql.readOnly.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB password</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1137">hyperswitch-app.externalPostgresql.readOnly.auth.plainpassword</a></div></td>
    <td><div><code>null</code></div></td>
    <td>replica DB plainpassword</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1131">hyperswitch-app.externalPostgresql.readOnly.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB username</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1124">hyperswitch-app.externalPostgresql.readOnly.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>External postgres read only host enabled or disabled</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1127">hyperswitch-app.externalPostgresql.readOnly.host</a></div></td>
    <td><div><code>"postgres-service"</code></div></td>
    <td>External postgres read only host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1037">hyperswitch-app.externalRedis.auth.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>auth enabled or disabled</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1043">hyperswitch-app.externalRedis.auth.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis password</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1040">hyperswitch-app.externalRedis.auth.username</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis username</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1030">hyperswitch-app.externalRedis.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Redis server</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1033">hyperswitch-app.externalRedis.host</a></div></td>
    <td><div><code>"redis-ext-master"</code></div></td>
    <td>External redis host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1183">hyperswitch-app.kafka.broker.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for broker</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1178">hyperswitch-app.kafka.controller.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for controller</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1170">hyperswitch-app.kafka.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Kafka sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1173">hyperswitch-app.kafka.fullnameOverride</a></div></td>
    <td><div><code>"kafka0"</code></div></td>
    <td>Name of the Kafka sub-chart</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1200">hyperswitch-app.kafka.listeners.client.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener client protocol</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1212">hyperswitch-app.kafka.listeners.controller.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener controller protocol</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1208">hyperswitch-app.kafka.listeners.external.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener external protocol</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1204">hyperswitch-app.kafka.listeners.interbroker.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener interbroker protocol</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1216">hyperswitch-app.kafka.provisioning.replicationFactor</a></div></td>
    <td><div><code>1</code></div></td>
    <td>kafka provisioning replicationFactor</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1195">hyperswitch-app.kafka.service.ports.client</a></div></td>
    <td><div><code>29092</code></div></td>
    <td>Client port for Kafka</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1190">hyperswitch-app.kafka.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for zookeeper</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1279">hyperswitch-app.mailhog.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Mailhog sub-chart helm installation for email testing</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1282">hyperswitch-app.mailhog.fullnameOverride</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Name of the Mailhog sub-chart</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1073">hyperswitch-app.postgresql.architecture</a></div></td>
    <td><div><code>"replication"</code></div></td>
    <td>Postgresql architecture: replication or standalone</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1056">hyperswitch-app.postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>enable Bitnami postgresql sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1070">hyperswitch-app.postgresql.global.postgresql.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql database</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1067">hyperswitch-app.postgresql.global.postgresql.auth.password</a></div></td>
    <td><div><code>"ZGJwYXNzd29yZDEx"</code></div></td>
    <td>Postgresql password</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1064">hyperswitch-app.postgresql.global.postgresql.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql username</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1084">hyperswitch-app.postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>postgres primary name</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1089">hyperswitch-app.postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"150m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1093">hyperswitch-app.postgresql.readReplicas.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of read replicas</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1098">hyperswitch-app.postgresql.readReplicas.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1080">hyperswitch-app.postgresql.replication.numSynchronousReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of synchronous replicas</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1077">hyperswitch-app.postgresql.replication.synchronousCommit</a></div></td>
    <td><div><code>"off"</code></div></td>
    <td>synchronous_commit parameter</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1022">hyperswitch-app.redis.auth.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable redis auth</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1025">hyperswitch-app.redis.auth.sentinel</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable sentinel</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1008">hyperswitch-app.redis.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>- enable Bitnami redis sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1014">hyperswitch-app.redis.master.count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for master</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1018">hyperswitch-app.redis.replica.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of replicas to be used for replica</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1289">hyperswitch-app.vector.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Vector sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1293">hyperswitch-app.vector.env[0]</a></div></td>
    <td><div><code>{
  "name": "KAFKA_HOST",
  "value": "kafka0:29092"
}</code></div></td>
    <td>Vector environment variables</td>
  </tr></tbody>
</table>
<h3>Control Center configs</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L974">hyperswitch-app.controlCenter.env.default__endpoints__agreement_url</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"</code></div></td>
    <td>Hyperswitch terms and conditions url</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L977">hyperswitch-app.controlCenter.env.default__endpoints__agreement_version</a></div></td>
    <td><div><code>"1.0.0"</code></div></td>
    <td>Agreement version</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L968">hyperswitch-app.controlCenter.env.default__endpoints__dss_certificate_url</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/certificates/PCI_DSS_v4-0_AOC_Juspay_2024.pdf"</code></div></td>
    <td>PCI DSS certificate url</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L971">hyperswitch-app.controlCenter.env.default__endpoints__favicon_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Endpoints favicon url</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L981">hyperswitch-app.controlCenter.env.default__endpoints__mixpanel_token</a></div></td>
    <td><div><code>"dd4da7f62941557e716fbc0a19f9cc7e"</code></div></td>
    <td>Mixpanel token</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L884">hyperswitch-app.controlCenter.env.default__features__branding</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables customization of branding elements like logos, colors.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L881">hyperswitch-app.controlCenter.env.default__features__email</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables user sign-in and sign-up using magic links instead of passwords. When enabled, users can request a magic link via email that logs them into their account or creates a new account if they are signing up.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L911">hyperswitch-app.controlCenter.env.default__features__feedback</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the ability for users to provide direct product feedback from within the dashboard. When enabled, a feedback modal will be available in the UI that allows users to rate features, report bugs, and suggest improvements. Disabling this flag will remove the feedback modal and prevent collection of any user data.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L899">hyperswitch-app.controlCenter.env.default__features__frm</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the Fraud and Risk Management (FRM) module within the dashboard. When enabled, this unlocks integrations with FRM players like Riskified and Signified. https://docs.hyperswitch.io/explore-hyperswitch/payment-flows-and-management/fraud-and-risk-management</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L914">hyperswitch-app.controlCenter.env.default__features__generate_report</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the ability to generate detailed reports on payments, refunds, and disputes. When enabled, this allows users to pull reports covering the previous 6 months of transaction data. The reports can provide insights into trends, identify issues, and inform business decisions.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L908">hyperswitch-app.controlCenter.env.default__features__is_live_mode</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the live mode - that the user is accessing. When enabled, it will show a visual indicator within the dashboard signaling whether the user is currently in a test environment or live production environment. In Live mode, current users are not allowed to sign up. Users must be created manually.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L902">hyperswitch-app.controlCenter.env.default__features__mixpanel</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Controls the collection and transmission of anonymous usage data to Mixpanel for analytics. When enabled, the dashboard will automatically send information about user actions and events to Mixpanel without collecting any personally identifiable information via REST API.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L896">hyperswitch-app.controlCenter.env.default__features__payout</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the payout functionality in the dashboard. When enabled, this allows users to configure payout profiles, manage recipient details, schedule disbursements, and process payout batches to pay out funds to third parties.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L890">hyperswitch-app.controlCenter.env.default__features__quick_start</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the simplified onboarding flow for new users, where they connect to processors, configure payment routing and test a payment, all in one flow.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L893">hyperswitch-app.controlCenter.env.default__features__recon</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables access to reconciliation capabilities in the Hyperswitch dashboard. When turned on, this unlocks the Reconciliation module that allows users to match payment transactions with bank/ledger entries for accounting purposes.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L905">hyperswitch-app.controlCenter.env.default__features__sample_data</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the ability to load simulated sample data into the dashboard for preview purposes. When enabled, dummy transactions, analytics, and reporting data can be generated.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L887">hyperswitch-app.controlCenter.env.default__features__surcharge</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the ability to apply surcharges to payments. When enabled, you can create advanced rules based on payment parameters like amount, currency, and payment method to enforce surcharges as needed.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L919">hyperswitch-app.controlCenter.env.default__features__test_live_toggle</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables users to toggle between test and live modes when signing in. When enabled, users will see an option during sign-in to actively switch between test and live environments.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L922">hyperswitch-app.controlCenter.env.default__features__test_processors</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Allows enabling sandbox/test payment processors for testing purposes. When enabled, developers and testers can add test payment processors like Stripe Test or PayPal Test to trial payment flows without touching live transactions or making processor API calls.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L928">hyperswitch-app.controlCenter.env.default__features__totp</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables totp will mandate 2fa for all users</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L925">hyperswitch-app.controlCenter.env.default__features__user_journey_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Grants access to the user journey module within the analytics section of the dashboard. This feature provides comprehensive graphical representations of payment analytics, facilitating a deeper understanding of user behavior and usage patterns.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L987">hyperswitch-app.controlCenter.env.default__theme__primary_color</a></div></td>
    <td><div><code>"#006DF9"</code></div></td>
    <td>Primary color for the theme</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L990">hyperswitch-app.controlCenter.env.default__theme__primary_hover_color</a></div></td>
    <td><div><code>"#005ED6"</code></div></td>
    <td>Primary hover color for the theme</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L993">hyperswitch-app.controlCenter.env.default__theme__sidebar_color</a></div></td>
    <td><div><code>"#242F48"</code></div></td>
    <td>Secondary color for the theme</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1002">hyperswitch-app.controlCenter.env.mixpanelToken</a></div></td>
    <td><div><code>"dd4da7f62941557e716fbc0a19f9cc7e"</code></div></td>
    <td>Mix panel token</td>
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
    <td><div><a href="../hyperswitch-app/values.yaml#L293">hyperswitch-app.server.analytics.clickhouse.database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse database name</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L296">hyperswitch-app.server.analytics.clickhouse.host</a></div></td>
    <td><div><code>"http://clickhouse:8123"</code></div></td>
    <td>Clickhouse host in http(s)://<URL>:<PORT> format</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L302">hyperswitch-app.server.analytics.clickhouse.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Clickhouse password (optional)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L299">hyperswitch-app.server.analytics.clickhouse.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L381">hyperswitch-app.server.email.aws_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS region used by AWS SES</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L385">hyperswitch-app.server.email.aws_ses.email_role_arn</a></div></td>
    <td><div><code>"arn:aws:iam::123456789012:role/SendEmailRole"</code></div></td>
    <td>The amazon resource name ( arn ) of the role which has permission to send emails</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L388">hyperswitch-app.server.email.aws_ses.sts_role_session_name</a></div></td>
    <td><div><code>"SendEmailRole"</code></div></td>
    <td>An identifier for the assumed role session, used to uniquely identify a session.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L391">hyperswitch-app.server.email.prod_intent_recipient_email</a></div></td>
    <td><div><code>"business@example.com"</code></div></td>
    <td>Recipient email for prod intent email</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L394">hyperswitch-app.server.email.recon_recipient_email</a></div></td>
    <td><div><code>"recon@example.com"</code></div></td>
    <td>Recipient email for recon request email</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L397">hyperswitch-app.server.email.sender_email</a></div></td>
    <td><div><code>"example@example.com"</code></div></td>
    <td>Sender email</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L403">hyperswitch-app.server.email.smtp.host</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Host of the smtp server</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L408">hyperswitch-app.server.email.smtp.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Password for the smtp server</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L616">hyperswitch-app.server.paze_decrypt_keys.paze_private_key</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY"</code></div></td>
    <td>Base 64 Encoded Private Key File cakey.pem generated for Paze -> Command to create private key: openssl req -newkey rsa:2048 -x509 -keyout cakey.pem -out cacert.pem -days 365</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L619">hyperswitch-app.server.paze_decrypt_keys.paze_private_key_passphrase</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY_PASSPHRASE"</code></div></td>
    <td>PEM Passphrase used for generating Private Key File cakey.pem</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L167">hyperswitch-app.server.secrets.admin_api_key</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>admin API key for admin authentication.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L282">hyperswitch-app.server.secrets.api_hash_key</a></div></td>
    <td><div><code>"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"</code></div></td>
    <td>API key hashing key.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L252">hyperswitch-app.server.secrets.apple_pay_merchant_cert</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L255">hyperswitch-app.server.secrets.apple_pay_merchant_cert_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generated by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L264">hyperswitch-app.server.secrets.apple_pay_merchant_conf_merchant_cert</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L267">hyperswitch-app.server.secrets.apple_pay_merchant_conf_merchant_cert_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generate by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L270">hyperswitch-app.server.secrets.apple_pay_merchant_conf_merchant_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Refer to config.example.toml to learn how you can generate this value</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L258">hyperswitch-app.server.secrets.apple_pay_ppc</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Payment Processing Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Payment Processing Certificate</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L261">hyperswitch-app.server.secrets.apple_pay_ppc_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generated by Elliptic-curve prime256v1 curve. You can use `openssl ecparam -out private.key -name prime256v1 -genkey` to generate the private key</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L273">hyperswitch-app.server.secrets.forex_api_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Api key for making request to foreign exchange Api, Follow https://github.com/juspay/hyperswitch/tree/main/crates/analytics#setting-up-forex-apis to get the forex api key</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L276">hyperswitch-app.server.secrets.forex_fallback_api_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Forex Api key for the fallback service</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L170">hyperswitch-app.server.secrets.jwt_secret</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>JWT secret used for user authentication.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L285">hyperswitch-app.server.secrets.keymanager</a></div></td>
    <td><div><code>{
  "ca": "sample_ca",
  "cert": "sample_cert"
}</code></div></td>
    <td>Encryption key used for encrypting data in user_authentication_methods table</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L186">hyperswitch-app.server.secrets.kms_jwekey_vault_encryption_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the locker from locker-public-key.pub, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L199">hyperswitch-app.server.secrets.kms_jwekey_vault_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>The private key for the tenant from tenant-private-key.pem, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L179">hyperswitch-app.server.secrets.kms_key_id</a></div></td>
    <td><div><code>"kms_key_id"</code></div></td>
    <td>KMS key id for encryption and decryption</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L182">hyperswitch-app.server.secrets.kms_key_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS KMS region</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L173">hyperswitch-app.server.secrets.master_enc_key</a></div></td>
    <td><div><code>"471f22516724347bcca9c20c5fa88d9821c4604e63a6aceffd24605809c9237c"</code></div></td>
    <td>Master Encryption key used to encrypt merchant wise encryption key. Should be 32-byte long.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L279">hyperswitch-app.server.secrets.pm_auth_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td># Payment method auth key used for authorization</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L176">hyperswitch-app.server.secrets.recon_admin_api_key</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>Recon Admin API key for recon admin authentication.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L249">hyperswitch-app.server.secrets.redis_temp_locker_encryption_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Encryption key for redis temp locker</td>
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
    <td><div><a href="../hyperswitch-app/values.yaml#L20">hyperswitch-app.services.consumer.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-consumer:v1.116.0"</code></div></td>
    <td>Consumer image</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L17">hyperswitch-app.services.consumer.version</a></div></td>
    <td><div><code>"v1.116.0"</code></div></td>
    <td>Consumer version</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L36">hyperswitch-app.services.drainer.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-drainer:v1.116.0"</code></div></td>
    <td>Drainer image</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L33">hyperswitch-app.services.drainer.version</a></div></td>
    <td><div><code>"v1.116.0"</code></div></td>
    <td>Drainer version</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L28">hyperswitch-app.services.producer.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-producer:v1.116.0"</code></div></td>
    <td>Producer image</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L25">hyperswitch-app.services.producer.version</a></div></td>
    <td><div><code>"v1.116.0"</code></div></td>
    <td>Producer version</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L12">hyperswitch-app.services.router.host</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td>Router host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L9">hyperswitch-app.services.router.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-router:v1.116.0"</code></div></td>
    <td>Router image</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L6">hyperswitch-app.services.router.version</a></div></td>
    <td><div><code>"v1.116.0"</code></div></td>
    <td>Router version</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L46">hyperswitch-app.services.sdk.host</a></div></td>
    <td><div><code>"http://localhost:9050"</code></div></td>
    <td>SDK host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L52">hyperswitch-app.services.sdk.subversion</a></div></td>
    <td><div><code>"v1"</code></div></td>
    <td>SDK subversion</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L49">hyperswitch-app.services.sdk.version</a></div></td>
    <td><div><code>"0.125.0"</code></div></td>
    <td>SDK version</td>
  </tr></tbody>
</table>
<h3>Connector Service</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L169">hyperswitch-ucs.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Affinity for pod assignment</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L144">hyperswitch-ucs.autoscaling</a></div></td>
    <td><div><code>{
  "enabled": false,
  "maxReplicas": 100,
  "minReplicas": 1,
  "targetCPUUtilizationPercentage": 80
}</code></div></td>
    <td>Autoscaling configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L147">hyperswitch-ucs.autoscaling.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable autoscaling</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L153">hyperswitch-ucs.autoscaling.maxReplicas</a></div></td>
    <td><div><code>100</code></div></td>
    <td>Maximum number of replicas</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L150">hyperswitch-ucs.autoscaling.minReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Minimum number of replicas</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L156">hyperswitch-ucs.autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td>Target CPU utilization percentage</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L30">hyperswitch-ucs.fullnameOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Override the full name of the chart</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L11">hyperswitch-ucs.image</a></div></td>
    <td><div><code>{
  "pullPolicy": "IfNotPresent",
  "repository": "ghcr.io/juspay/connector-service",
  "tag": "main-b1487cb"
}</code></div></td>
    <td>Container image configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L17">hyperswitch-ucs.image.pullPolicy</a></div></td>
    <td><div><code>"IfNotPresent"</code></div></td>
    <td>Image pull policy</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L14">hyperswitch-ucs.image.repository</a></div></td>
    <td><div><code>"ghcr.io/juspay/connector-service"</code></div></td>
    <td>Docker image repository</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L20">hyperswitch-ucs.image.tag</a></div></td>
    <td><div><code>"main-b1487cb"</code></div></td>
    <td>Image tag to use</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L24">hyperswitch-ucs.imagePullSecrets</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Image pull secrets for private registries</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L93">hyperswitch-ucs.ingress</a></div></td>
    <td><div><code>{
  "annotations": {},
  "className": "",
  "enabled": false,
  "hosts": [
    {
      "host": "hyperswitch-ucs.local",
      "paths": [
        {
          "path": "/",
          "pathType": "ImplementationSpecific"
        }
      ]
    }
  ],
  "tls": []
}</code></div></td>
    <td>Ingress configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L102">hyperswitch-ucs.ingress.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Additional annotations for the Ingress resource</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L99">hyperswitch-ucs.ingress.className</a></div></td>
    <td><div><code>""</code></div></td>
    <td>IngressClass that will be used to implement the Ingress</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L96">hyperswitch-ucs.ingress.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable ingress controller resource</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L108">hyperswitch-ucs.ingress.hosts</a></div></td>
    <td><div><code>[
  {
    "host": "hyperswitch-ucs.local",
    "paths": [
      {
        "path": "/",
        "pathType": "ImplementationSpecific"
      }
    ]
  }
]</code></div></td>
    <td>An array with hostname(s) to be covered with the ingress record</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L115">hyperswitch-ucs.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>TLS configuration for hostname(s) to be covered with this ingress record</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L173">hyperswitch-ucs.livenessProbe</a></div></td>
    <td><div><code>{
  "failureThreshold": 3,
  "grpc": {
    "port": 8000,
    "service": "grpc.health.v1.Health"
  },
  "initialDelaySeconds": 90,
  "periodSeconds": 30,
  "successThreshold": 1,
  "timeoutSeconds": 10
}</code></div></td>
    <td>Liveness probe configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L176">hyperswitch-ucs.livenessProbe.failureThreshold</a></div></td>
    <td><div><code>3</code></div></td>
    <td>Number of failures before pod is restarted</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L179">hyperswitch-ucs.livenessProbe.grpc</a></div></td>
    <td><div><code>{
  "port": 8000,
  "service": "grpc.health.v1.Health"
}</code></div></td>
    <td>gRPC health check configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L182">hyperswitch-ucs.livenessProbe.grpc.port</a></div></td>
    <td><div><code>8000</code></div></td>
    <td>gRPC port for health check</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L185">hyperswitch-ucs.livenessProbe.grpc.service</a></div></td>
    <td><div><code>"grpc.health.v1.Health"</code></div></td>
    <td>gRPC service name for health check</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L188">hyperswitch-ucs.livenessProbe.initialDelaySeconds</a></div></td>
    <td><div><code>90</code></div></td>
    <td>Initial delay before probe starts</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L191">hyperswitch-ucs.livenessProbe.periodSeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td>How often to perform the probe</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L194">hyperswitch-ucs.livenessProbe.successThreshold</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Minimum consecutive successes for the probe to be considered successful</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L197">hyperswitch-ucs.livenessProbe.timeoutSeconds</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Number of seconds after which the probe times out</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L27">hyperswitch-ucs.nameOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Override the name of the chart</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L161">hyperswitch-ucs.nodeSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Node labels for pod assignment</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L47">hyperswitch-ucs.podAnnotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Annotations to add to the pod</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L51">hyperswitch-ucs.podSecurityContext</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Pod security context</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L201">hyperswitch-ucs.readinessProbe</a></div></td>
    <td><div><code>{
  "failureThreshold": 5,
  "grpc": {
    "port": 8000,
    "service": "grpc.health.v1.Health"
  },
  "initialDelaySeconds": 30,
  "periodSeconds": 30,
  "successThreshold": 1,
  "timeoutSeconds": 5
}</code></div></td>
    <td>Readiness probe configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L204">hyperswitch-ucs.readinessProbe.failureThreshold</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of failures before pod is marked unready</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L207">hyperswitch-ucs.readinessProbe.grpc</a></div></td>
    <td><div><code>{
  "port": 8000,
  "service": "grpc.health.v1.Health"
}</code></div></td>
    <td>gRPC health check configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L210">hyperswitch-ucs.readinessProbe.grpc.port</a></div></td>
    <td><div><code>8000</code></div></td>
    <td>gRPC port for health check</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L213">hyperswitch-ucs.readinessProbe.grpc.service</a></div></td>
    <td><div><code>"grpc.health.v1.Health"</code></div></td>
    <td>gRPC service name for health check</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L216">hyperswitch-ucs.readinessProbe.initialDelaySeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td>Initial delay before probe starts</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L219">hyperswitch-ucs.readinessProbe.periodSeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td>How often to perform the probe</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L222">hyperswitch-ucs.readinessProbe.successThreshold</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Minimum consecutive successes for the probe to be considered successful</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L225">hyperswitch-ucs.readinessProbe.timeoutSeconds</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of seconds after which the probe times out</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L7">hyperswitch-ucs.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas for the UCS deployment</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L122">hyperswitch-ucs.resources</a></div></td>
    <td><div><code>{
  "limits": {
    "cpu": "1000m",
    "memory": "1000Mi"
  },
  "requests": {
    "cpu": "400m",
    "memory": "400Mi"
  }
}</code></div></td>
    <td>Resource limits and requests for the UCS containers</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L125">hyperswitch-ucs.resources.limits</a></div></td>
    <td><div><code>{
  "cpu": "1000m",
  "memory": "1000Mi"
}</code></div></td>
    <td>Resource limits</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L128">hyperswitch-ucs.resources.limits.cpu</a></div></td>
    <td><div><code>"1000m"</code></div></td>
    <td>CPU limit</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L131">hyperswitch-ucs.resources.limits.memory</a></div></td>
    <td><div><code>"1000Mi"</code></div></td>
    <td>Memory limit</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L134">hyperswitch-ucs.resources.requests</a></div></td>
    <td><div><code>{
  "cpu": "400m",
  "memory": "400Mi"
}</code></div></td>
    <td>Resource requests</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L137">hyperswitch-ucs.resources.requests.cpu</a></div></td>
    <td><div><code>"400m"</code></div></td>
    <td>CPU request</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L140">hyperswitch-ucs.resources.requests.memory</a></div></td>
    <td><div><code>"400Mi"</code></div></td>
    <td>Memory request</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L57">hyperswitch-ucs.securityContext</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Container security context</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L68">hyperswitch-ucs.service</a></div></td>
    <td><div><code>{
  "grpc": {
    "port": 8000,
    "targetPort": 8000
  },
  "metrics": {
    "port": 8080,
    "targetPort": 8080
  },
  "type": "ClusterIP"
}</code></div></td>
    <td>Service configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L74">hyperswitch-ucs.service.grpc</a></div></td>
    <td><div><code>{
  "port": 8000,
  "targetPort": 8000
}</code></div></td>
    <td>gRPC service configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L77">hyperswitch-ucs.service.grpc.port</a></div></td>
    <td><div><code>8000</code></div></td>
    <td>gRPC service port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L80">hyperswitch-ucs.service.grpc.targetPort</a></div></td>
    <td><div><code>8000</code></div></td>
    <td>gRPC container port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L83">hyperswitch-ucs.service.metrics</a></div></td>
    <td><div><code>{
  "port": 8080,
  "targetPort": 8080
}</code></div></td>
    <td>Metrics service configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L86">hyperswitch-ucs.service.metrics.port</a></div></td>
    <td><div><code>8080</code></div></td>
    <td>Metrics service port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L89">hyperswitch-ucs.service.metrics.targetPort</a></div></td>
    <td><div><code>8080</code></div></td>
    <td>Metrics container port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L71">hyperswitch-ucs.service.type</a></div></td>
    <td><div><code>"ClusterIP"</code></div></td>
    <td>Service type</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L34">hyperswitch-ucs.serviceAccount</a></div></td>
    <td><div><code>{
  "annotations": {},
  "create": true,
  "name": ""
}</code></div></td>
    <td>Service account configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L40">hyperswitch-ucs.serviceAccount.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Annotations to add to the service account</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L37">hyperswitch-ucs.serviceAccount.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Specifies whether a service account should be created</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L43">hyperswitch-ucs.serviceAccount.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>The name of the service account to use. If not set and create is true, a name is generated using the fullname template</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L165">hyperswitch-ucs.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Tolerations for pod assignment</td>
  </tr></tbody>
</table>
<h3>Connector Service Configurations</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L267">hyperswitch-ucs.config.connectors.adyen.base_url</a></div></td>
    <td><div><code>"https://{{merchant_endpoint_prefix}}-checkout-live.adyenpayments.com/checkout/"</code></div></td>
    <td>Adyen base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L270">hyperswitch-ucs.config.connectors.adyen.dispute_base_url</a></div></td>
    <td><div><code>"https://{{merchant_endpoint_prefix}}-ca-live.adyen.com/"</code></div></td>
    <td>Adyen dispute base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L305">hyperswitch-ucs.config.connectors.authorizedotnet.base_url</a></div></td>
    <td><div><code>"https://api.authorize.net/xml/v1/request.api/"</code></div></td>
    <td>Authorize.net base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L300">hyperswitch-ucs.config.connectors.checkout.base_url</a></div></td>
    <td><div><code>"https://api.checkout.com/"</code></div></td>
    <td>Checkout base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L285">hyperswitch-ucs.config.connectors.elavon.base_url</a></div></td>
    <td><div><code>"https://api.convergepay.com/VirtualMerchant/"</code></div></td>
    <td>Elavon base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L280">hyperswitch-ucs.config.connectors.fiserv.base_url</a></div></td>
    <td><div><code>"https://cert.api.fiservapps.com/"</code></div></td>
    <td>Fiserv base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L275">hyperswitch-ucs.config.connectors.razorpay.base_url</a></div></td>
    <td><div><code>"https://api.razorpay.com/"</code></div></td>
    <td>Razorpay base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L295">hyperswitch-ucs.config.connectors.razorpayv2.base_url</a></div></td>
    <td><div><code>"https://api.razorpay.com/"</code></div></td>
    <td>Razorpay v2 base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L290">hyperswitch-ucs.config.connectors.xendit.base_url</a></div></td>
    <td><div><code>"https://api.xendit.co/"</code></div></td>
    <td>Xendit base URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L235">hyperswitch-ucs.config.log.console.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable console logging</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L238">hyperswitch-ucs.config.log.console.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td>Log level (DEBUG, INFO, WARN, ERROR)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L241">hyperswitch-ucs.config.log.console.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td>Log format (json, text)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L257">hyperswitch-ucs.config.metrics.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td>Metrics server host address</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L260">hyperswitch-ucs.config.metrics.port</a></div></td>
    <td><div><code>8080</code></div></td>
    <td>Metrics server port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L319">hyperswitch-ucs.config.proxy.bypass_proxy_urls</a></div></td>
    <td><div><code>[
  "localhost",
  "local"
]</code></div></td>
    <td>URLs to bypass proxy</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L313">hyperswitch-ucs.config.proxy.http_url</a></div></td>
    <td><div><code>"http_proxy"</code></div></td>
    <td>HTTP proxy URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L310">hyperswitch-ucs.config.proxy.https_url</a></div></td>
    <td><div><code>"https_proxy"</code></div></td>
    <td>HTTPS proxy URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L316">hyperswitch-ucs.config.proxy.idle_pool_connection_timeout</a></div></td>
    <td><div><code>90</code></div></td>
    <td>Idle pool connection timeout</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L246">hyperswitch-ucs.config.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td>Server host address</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L249">hyperswitch-ucs.config.server.port</a></div></td>
    <td><div><code>8000</code></div></td>
    <td>Server port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-ucs/values.yaml#L252">hyperswitch-ucs.config.server.type</a></div></td>
    <td><div><code>"grpc"</code></div></td>
    <td>Server type</td>
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
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L8">global.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L4">global.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L8">global.labels.stack</a></div></td>
    <td><div><code>"hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L19">global.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L176">hyperswitch-monitoring.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L179">hyperswitch-monitoring.global.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L189">hyperswitch-monitoring.kube-prometheus-stack.alertmanager.alertmanagerSpec.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L186">hyperswitch-monitoring.kube-prometheus-stack.grafana.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L184">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L192">hyperswitch-monitoring.loki.singleBinary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L196">hyperswitch-monitoring.opentelemetry-collector.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L194">hyperswitch-monitoring.promtail.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1155">hyperswitch-app.autoscaling.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1157">hyperswitch-app.autoscaling.maxReplicas</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1156">hyperswitch-app.autoscaling.minReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1158">hyperswitch-app.autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1230">hyperswitch-app.clickhouse.host</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1246">hyperswitch-app.clickhouse.image.tag</a></div></td>
    <td><div><code>24.3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1234">hyperswitch-app.clickhouse.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L878">hyperswitch-app.controlCenter.env.binary</a></div></td>
    <td><div><code>"dashboard"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L978">hyperswitch-app.controlCenter.env.default__endpoints__hypersense_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L983">hyperswitch-app.controlCenter.env.default__endpoints__logo_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Endpoints logo url</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L984">hyperswitch-app.controlCenter.env.default__endpoints__recon_iframe_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L929">hyperswitch-app.controlCenter.env.default__features__authentication_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L930">hyperswitch-app.controlCenter.env.default__features__compliance_certificate</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L931">hyperswitch-app.controlCenter.env.default__features__configure_pmts</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L932">hyperswitch-app.controlCenter.env.default__features__custom_webhook_headers</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L933">hyperswitch-app.controlCenter.env.default__features__dev_alt_payment_methods</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L934">hyperswitch-app.controlCenter.env.default__features__dev_click_to_pay</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L935">hyperswitch-app.controlCenter.env.default__features__dev_debit_routing</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L936">hyperswitch-app.controlCenter.env.default__features__dev_hypersense_v2_product</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L937">hyperswitch-app.controlCenter.env.default__features__dev_intelligent_routing_v2</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L938">hyperswitch-app.controlCenter.env.default__features__dev_modularity_v2</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L939">hyperswitch-app.controlCenter.env.default__features__dev_recon_v2_product</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L940">hyperswitch-app.controlCenter.env.default__features__dev_recovery_v2_product</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L941">hyperswitch-app.controlCenter.env.default__features__dev_vault_v2_product</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L942">hyperswitch-app.controlCenter.env.default__features__dev_webhooks</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L943">hyperswitch-app.controlCenter.env.default__features__dispute_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L944">hyperswitch-app.controlCenter.env.default__features__dispute_evidence_upload</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L945">hyperswitch-app.controlCenter.env.default__features__down_time</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L946">hyperswitch-app.controlCenter.env.default__features__force_cookies</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L947">hyperswitch-app.controlCenter.env.default__features__global_search</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L948">hyperswitch-app.controlCenter.env.default__features__global_search_filters</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L949">hyperswitch-app.controlCenter.env.default__features__granularity</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L950">hyperswitch-app.controlCenter.env.default__features__live_users_counter</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L951">hyperswitch-app.controlCenter.env.default__features__maintainence_alert</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L952">hyperswitch-app.controlCenter.env.default__features__new_analytics</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L953">hyperswitch-app.controlCenter.env.default__features__new_analytics_filters</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L954">hyperswitch-app.controlCenter.env.default__features__new_analytics_refunds</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L955">hyperswitch-app.controlCenter.env.default__features__new_analytics_smart_retries</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L956">hyperswitch-app.controlCenter.env.default__features__performance_monitor</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L957">hyperswitch-app.controlCenter.env.default__features__pm_authentication_processor</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L958">hyperswitch-app.controlCenter.env.default__features__recon_v2</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L916">hyperswitch-app.controlCenter.env.default__features__system_metrics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the ability to load simulated sample data into the dashboard for preview purposes.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L959">hyperswitch-app.controlCenter.env.default__features__tax_processors</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L962">hyperswitch-app.controlCenter.env.default__features__tenant_user</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L960">hyperswitch-app.controlCenter.env.default__features__threeds_authenticator</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L961">hyperswitch-app.controlCenter.env.default__features__transaction_view</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L963">hyperswitch-app.controlCenter.env.default__merchant_config__new_analytics__merchant_ids</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L964">hyperswitch-app.controlCenter.env.default__merchant_config__new_analytics__org_ids</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L965">hyperswitch-app.controlCenter.env.default__merchant_config__new_analytics__profile_ids</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L994">hyperswitch-app.controlCenter.env.default__theme__sidebar_border_color</a></div></td>
    <td><div><code>"#ECEFF3"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L995">hyperswitch-app.controlCenter.env.default__theme__sidebar_primary</a></div></td>
    <td><div><code>"#FCFCFD"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L996">hyperswitch-app.controlCenter.env.default__theme__sidebar_primary_text_color</a></div></td>
    <td><div><code>"#1C6DEA"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L997">hyperswitch-app.controlCenter.env.default__theme__sidebar_secondary</a></div></td>
    <td><div><code>"#FFFFFF"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L998">hyperswitch-app.controlCenter.env.default__theme__sidebar_secondary_text_color</a></div></td>
    <td><div><code>"#525866"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L999">hyperswitch-app.controlCenter.env.host</a></div></td>
    <td><div><code>"hyperswitch-control-center"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L843">hyperswitch-app.controlCenter.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for the application</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1161">hyperswitch-app.hyperswitch-card-vault.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1164">hyperswitch-app.hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"docker.io/bitnami/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1226">hyperswitch-app.initCH.checkCHisUp.image</a></div></td>
    <td><div><code>"docker.io/bitnami/clickhouse:24.3"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1227">hyperswitch-app.initCH.checkCHisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1145">hyperswitch-app.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"docker.io/bitnami/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1146">hyperswitch-app.initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1143">hyperswitch-app.initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1149">hyperswitch-app.initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1147">hyperswitch-app.initDB.refs</a></div></td>
    <td><div><code>"tags"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1184">hyperswitch-app.kafka.broker.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1179">hyperswitch-app.kafka.controller.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1220">hyperswitch-app.kafka.extraConfig</a></div></td>
    <td><div><code>"offsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1152">hyperswitch-app.loadBalancer.targetSecurityGroup</a></div></td>
    <td><div><code>"loadBalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1058">hyperswitch-app.postgresql.image.tag</a></div></td>
    <td><div><code>"16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1010">hyperswitch-app.redis.image.tag</a></div></td>
    <td><div><code>"7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1048">hyperswitch-app.redisMiscConfig.checkRedisIsUp.initContainer.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1049">hyperswitch-app.redisMiscConfig.checkRedisIsUp.initContainer.image</a></div></td>
    <td><div><code>"docker.io/bitnami/redis:7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L1050">hyperswitch-app.redisMiscConfig.checkRedisIsUp.initContainer.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L312">hyperswitch-app.server.analytics.forex_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L304">hyperswitch-app.server.analytics.source</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>The Analytics source/strategy to be used</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L307">hyperswitch-app.server.analytics.sqlx.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L309">hyperswitch-app.server.analytics.sqlx.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L311">hyperswitch-app.server.analytics.sqlx.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L148">hyperswitch-app.server.annotations</a></div></td>
    <td><div><code>{
  "deployment.kubernetes.io/revision": "1"
}</code></div></td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L315">hyperswitch-app.server.applepay_merchant_configs.applepay_endpoint</a></div></td>
    <td><div><code>"https://apple-pay-gateway.apple.com/paymentservices/registerMerchant"</code></div></td>
    <td>Apple pay gateway merchant endpoint</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L318">hyperswitch-app.server.cell_information.id</a></div></td>
    <td><div><code>"12345"</code></div></td>
    <td>Default CellID for Global Cell Information</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L162">hyperswitch-app.server.chat.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L163">hyperswitch-app.server.chat.hyperswitch_ai_host</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L323">hyperswitch-app.server.clone_connector_allowlist.connector_names</a></div></td>
    <td><div><code>"stripe,adyen,paypal,checkout,braintree,cybersource,square,worldpay,klarna,noon,archipel"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L321">hyperswitch-app.server.clone_connector_allowlist.merchant_ids</a></div></td>
    <td><div><code>"merchant_ids"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L326">hyperswitch-app.server.connector_onboarding.paypal.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L329">hyperswitch-app.server.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id</a></div></td>
    <td><div><code>"['merchant_id_1','merchant_id_2']"</code></div></td>
    <td>List of merchant ids for which the payment id should be sent as connector request id</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L334">hyperswitch-app.server.connectors.hyperswitch_vault.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L336">hyperswitch-app.server.connectors.unified_authentication_service</a></div></td>
    <td><div><code>{
  "base_url": "http://localhost:8080"
}</code></div></td>
    <td>Unified Authentication Service Configuration</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L338">hyperswitch-app.server.connectors.unified_authentication_service.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td>base url to call unified authentication service</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L360">hyperswitch-app.server.cors.allowed_methods</a></div></td>
    <td><div><code>"GET,POST,PUT,DELETE"</code></div></td>
    <td>List of methods that are allowed</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L363">hyperswitch-app.server.cors.max_age</a></div></td>
    <td><div><code>30</code></div></td>
    <td>Maximum time (in seconds) for which this CORS request may be cached.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L361">hyperswitch-app.server.cors.origin</a></div></td>
    <td><div><code>"https://hyperswti"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L365">hyperswitch-app.server.cors.wildcard_origin</a></div></td>
    <td><div><code>true</code></div></td>
    <td>If true, allows any origin to make requests</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L368">hyperswitch-app.server.crm.crm_manager</a></div></td>
    <td><div><code>"hubspot_proxy"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L371">hyperswitch-app.server.crm.hubspot_proxy.form_id</a></div></td>
    <td><div><code>"form_id"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L373">hyperswitch-app.server.crm.hubspot_proxy.request_url</a></div></td>
    <td><div><code>"request_url"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L376">hyperswitch-app.server.email.active_email_client</a></div></td>
    <td><div><code>"SMTP"</code></div></td>
    <td>The currently active email client</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L378">hyperswitch-app.server.email.allowed_unverified_days</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of days the api calls ( with jwt token ) can be made without verifying the email</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L400">hyperswitch-app.server.email.smtp.connection</a></div></td>
    <td><div><code>"plaintext"</code></div></td>
    <td>connection type to be used for the smtp server</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L410">hyperswitch-app.server.email.smtp.port</a></div></td>
    <td><div><code>"1025"</code></div></td>
    <td>Port of the smtp server</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L412">hyperswitch-app.server.email.smtp.timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>timeout for the smtp server connection</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L405">hyperswitch-app.server.email.smtp.username</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Username for the smtp server</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L415">hyperswitch-app.server.encryption_management.encryption_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Encryption manager client to be used</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L421">hyperswitch-app.server.events.kafka.api_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-api-log-events"</code></div></td>
    <td>Kafka topic to be used for incoming api events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L423">hyperswitch-app.server.events.kafka.attempt_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td>Kafka topic to be used for PaymentAttempt events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L425">hyperswitch-app.server.events.kafka.audit_events_topic</a></div></td>
    <td><div><code>"hyperswitch-audit-events"</code></div></td>
    <td>Kafka topic to be used for Payment Audit events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L427">hyperswitch-app.server.events.kafka.authentication_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-authentication-events"</code></div></td>
    <td>Kafka topic to be used for Authentication events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L428">hyperswitch-app.server.events.kafka.brokers</a></div></td>
    <td><div><code>"['kafka0:29092']"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L430">hyperswitch-app.server.events.kafka.connector_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-connector-events"</code></div></td>
    <td>Kafka topic to be used for connector api events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L432">hyperswitch-app.server.events.kafka.consolidated_events_topic</a></div></td>
    <td><div><code>"hyperswitch-consolidated-events"</code></div></td>
    <td>Kafka topic to be used for Consolidated events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L434">hyperswitch-app.server.events.kafka.dispute_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td>Kafka topic to be used for Dispute events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L436">hyperswitch-app.server.events.kafka.fraud_check_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-fraud-check-events"</code></div></td>
    <td>Kafka topic to be used for Fraud Check events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L438">hyperswitch-app.server.events.kafka.intent_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td>Kafka topic to be used for PaymentIntent events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L440">hyperswitch-app.server.events.kafka.outgoing_webhook_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-webhook-events"</code></div></td>
    <td>Kafka topic to be used for outgoing webhook events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L442">hyperswitch-app.server.events.kafka.payout_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payout-events"</code></div></td>
    <td>Kafka topic to be used for Payouts and PayoutAttempt events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L444">hyperswitch-app.server.events.kafka.refund_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td>Kafka topic to be used for Refund events</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L446">hyperswitch-app.server.events.kafka.routing_logs_topic</a></div></td>
    <td><div><code>"topic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L418">hyperswitch-app.server.events.source</a></div></td>
    <td><div><code>"kafka"</code></div></td>
    <td>The event sink to push events supports kafka or logs (stdout)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L449">hyperswitch-app.server.forex_api.data_expiration_delay_in_seconds</a></div></td>
    <td><div><code>21600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L451">hyperswitch-app.server.forex_api.redis_lock_timeout_in_seconds</a></div></td>
    <td><div><code>100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L453">hyperswitch-app.server.forex_api.redis_ttl_in_seconds</a></div></td>
    <td><div><code>172800</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L462">hyperswitch-app.server.generic_link.payment_method_collect.enabled_payment_methods.bank_transfer</a></div></td>
    <td><div><code>"ach,bacs,sepa"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L461">hyperswitch-app.server.generic_link.payment_method_collect.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L463">hyperswitch-app.server.generic_link.payment_method_collect.enabled_payment_methods.wallet</a></div></td>
    <td><div><code>"paypal,pix,venmo"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L457">hyperswitch-app.server.generic_link.payment_method_collect.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L458">hyperswitch-app.server.generic_link.payment_method_collect.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L459">hyperswitch-app.server.generic_link.payment_method_collect.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L466">hyperswitch-app.server.generic_link.payout_link.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L468">hyperswitch-app.server.generic_link.payout_link.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L469">hyperswitch-app.server.generic_link.payout_link.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L470">hyperswitch-app.server.generic_link.payout_link.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L621">hyperswitch-app.server.google_pay_decrypt_keys.google_pay_root_signing_keys</a></div></td>
    <td><div><code>"GOOGLE_PAY_ROOT_SIGNING_KEYS"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L474">hyperswitch-app.server.grpc_client.dynamic_routing_client.host</a></div></td>
    <td><div><code>"localhost"</code></div></td>
    <td>Client Host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L476">hyperswitch-app.server.grpc_client.dynamic_routing_client.port</a></div></td>
    <td><div><code>7000</code></div></td>
    <td>Client Port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L478">hyperswitch-app.server.grpc_client.dynamic_routing_client.service</a></div></td>
    <td><div><code>"dynamo"</code></div></td>
    <td>Client Service Name</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L485">hyperswitch-app.server.grpc_client.unified_connectors_client.connection_timeout</a></div></td>
    <td><div><code>"10"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L481">hyperswitch-app.server.grpc_client.unified_connectors_client.host</a></div></td>
    <td><div><code>"localhost"</code></div></td>
    <td>Client Host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L483">hyperswitch-app.server.grpc_client.unified_connectors_client.port</a></div></td>
    <td><div><code>8000</code></div></td>
    <td>Client Port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L713">hyperswitch-app.server.keymanager.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable or disable keymanager</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L715">hyperswitch-app.server.keymanager.url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>KeyManager service URL</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L508">hyperswitch-app.server.kv_config.soft_kill</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L507">hyperswitch-app.server.kv_config.tls</a></div></td>
    <td><div><code>900</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L151">hyperswitch-app.server.labels</a></div></td>
    <td><div><code>{
  "app": "hyperswitch-server"
}</code></div></td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L512">hyperswitch-app.server.lock_settings.delay_between_retries_in_milliseconds</a></div></td>
    <td><div><code>500</code></div></td>
    <td>Delay between retries in milliseconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L514">hyperswitch-app.server.lock_settings.redis_lock_expiry_seconds</a></div></td>
    <td><div><code>180</code></div></td>
    <td>Seconds before the redis lock expires</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L520">hyperswitch-app.server.locker.host</a></div></td>
    <td><div><code>"http://hyperswitch-vault"</code></div></td>
    <td>Locker host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L522">hyperswitch-app.server.locker.host_rs</a></div></td>
    <td><div><code>null</code></div></td>
    <td>Rust Locker host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L524">hyperswitch-app.server.locker.locker_enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Boolean to enable or disable saving cards in locker</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L526">hyperswitch-app.server.locker.locker_signing_key_id</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td>Key_id to sign basilisk hs locker</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L528">hyperswitch-app.server.locker.mock_locker</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Emulate a locker locally using Postgres</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L530">hyperswitch-app.server.locker.ttl_for_storage_in_secs</a></div></td>
    <td><div><code>220752000</code></div></td>
    <td>Time to live for storage entries in locker</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L533">hyperswitch-app.server.log.console.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L535">hyperswitch-app.server.log.console.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td>Log level for console logs, ERROR, WARN, INFO, DEBUG</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L536">hyperswitch-app.server.log.console.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L538">hyperswitch-app.server.log.file.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L539">hyperswitch-app.server.log.file.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L540">hyperswitch-app.server.log.file.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L556">hyperswitch-app.server.log.telemetry.autoConfigureOtelEndpoint</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable this when using hyperswitch-stack with monitoring. Auto-configures endpoint as: <release-name>-opentelemetry-collector.<namespace>.svc.cluster.local:4317 Leave false for standalone deployments or when using external collectors.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L544">hyperswitch-app.server.log.telemetry.bg_metrics_collection_interval_in_secs</a></div></td>
    <td><div><code>15</code></div></td>
    <td>Interval for collecting the metrics in background thread</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L552">hyperswitch-app.server.log.telemetry.external_otel_collector_endpoint</a></div></td>
    <td><div><code>""</code></div></td>
    <td>URL for external OpenTelemetry Collector endpoint to send metrics and traces to. The OpenTelemetry Collector must have a gRPC OTLP receiver listening at this endpoint. The value of `external_otel_collector_endpoint` will be considered even if the `hyperswitch-monitoring` chart is enabled.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L546">hyperswitch-app.server.log.telemetry.ignore_errors</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether to ignore errors during traces or metrics pipeline setup</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L548">hyperswitch-app.server.log.telemetry.metrics_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether metrics are enabled</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L558">hyperswitch-app.server.log.telemetry.otel_exporter_otlp_timeout</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>timeout (in milliseconds) for sending metrics and traces</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L559">hyperswitch-app.server.log.telemetry.route_to_trace</a></div></td>
    <td><div><code>"['*/confirm']"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L560">hyperswitch-app.server.log.telemetry.sampling_rate</a></div></td>
    <td><div><code>0.1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L562">hyperswitch-app.server.log.telemetry.traces_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether traces are enabled</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L564">hyperswitch-app.server.log.telemetry.use_xray_generator</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Set this to true for AWS X-ray compatible traces</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L572">hyperswitch-app.server.master_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L574">hyperswitch-app.server.master_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L576">hyperswitch-app.server.master_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L568">hyperswitch-app.server.merchant_id_auth.merchant_id_auth_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L578">hyperswitch-app.server.multitenancy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L580">hyperswitch-app.server.multitenancy.global_tenant.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L581">hyperswitch-app.server.multitenancy.global_tenant.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L582">hyperswitch-app.server.multitenancy.global_tenant.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L583">hyperswitch-app.server.multitenancy.global_tenant.tenant_id</a></div></td>
    <td><div><code>"global"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L588">hyperswitch-app.server.multitenancy.tenants.public.accounts_schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L586">hyperswitch-app.server.multitenancy.tenants.public.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L590">hyperswitch-app.server.multitenancy.tenants.public.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L589">hyperswitch-app.server.multitenancy.tenants.public.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L587">hyperswitch-app.server.multitenancy.tenants.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L592">hyperswitch-app.server.multitenancy.tenants.public.user.control_center_url</a></div></td>
    <td><div><code>"http://localhost:9000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L355">hyperswitch-app.server.network_tokenization_service.check_token_status_url</a></div></td>
    <td><div><code>"https://example.com/status"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L353">hyperswitch-app.server.network_tokenization_service.delete_token_url</a></div></td>
    <td><div><code>"https://example.com/delete"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L343">hyperswitch-app.server.network_tokenization_service.fetch_token_url</a></div></td>
    <td><div><code>"https://example.com/fetch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L341">hyperswitch-app.server.network_tokenization_service.generate_token_url</a></div></td>
    <td><div><code>"https://example.com/generate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L351">hyperswitch-app.server.network_tokenization_service.key_id</a></div></td>
    <td><div><code>"key_id"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L349">hyperswitch-app.server.network_tokenization_service.private_key</a></div></td>
    <td><div><code>"private_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L347">hyperswitch-app.server.network_tokenization_service.public_key</a></div></td>
    <td><div><code>"public_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L345">hyperswitch-app.server.network_tokenization_service.token_service_api_key</a></div></td>
    <td><div><code>"api_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L357">hyperswitch-app.server.network_tokenization_service.webhook_source_verification_key</a></div></td>
    <td><div><code>"placeholder_webhook_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L595">hyperswitch-app.server.opensearch.auth.auth</a></div></td>
    <td><div><code>"basic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L597">hyperswitch-app.server.opensearch.auth.password</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L598">hyperswitch-app.server.opensearch.auth.region</a></div></td>
    <td><div><code>"eu-central-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L596">hyperswitch-app.server.opensearch.auth.username</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L600">hyperswitch-app.server.opensearch.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L599">hyperswitch-app.server.opensearch.host</a></div></td>
    <td><div><code>"https://localhost:9200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L602">hyperswitch-app.server.opensearch.indexes.disputes</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L603">hyperswitch-app.server.opensearch.indexes.payment_attempts</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L604">hyperswitch-app.server.opensearch.indexes.payment_intents</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L605">hyperswitch-app.server.opensearch.indexes.refunds</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L606">hyperswitch-app.server.opensearch.indexes.sessionizer_disputes</a></div></td>
    <td><div><code>"sessionizer-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L607">hyperswitch-app.server.opensearch.indexes.sessionizer_payment_attempts</a></div></td>
    <td><div><code>"sessionizer-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L608">hyperswitch-app.server.opensearch.indexes.sessionizer_payment_intents</a></div></td>
    <td><div><code>"sessionizer-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L609">hyperswitch-app.server.opensearch.indexes.sessionizer_refunds</a></div></td>
    <td><div><code>"sessionizer-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L612">hyperswitch-app.server.payment_method_auth.redis_expiry</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Redis expiry time in milliseconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L145">hyperswitch-app.server.podAnnotations</a></div></td>
    <td><div><code>{
  "traffic_sidecar_istio_io_excludeOutboundIPRanges": "10.23.6.12/32"
}</code></div></td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L108">hyperswitch-app.server.progressDeadlineSeconds</a></div></td>
    <td><div><code>600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L624">hyperswitch-app.server.proxy.bypass_proxy_hosts</a></div></td>
    <td><div><code>"localhost, cluster.local"</code></div></td>
    <td>A comma-separated list of domains or IP addresses that should not use the proxy. Whitespace between entries would be ignored.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L625">hyperswitch-app.server.proxy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L627">hyperswitch-app.server.proxy.http_url</a></div></td>
    <td><div><code>"http://proxy_http_url"</code></div></td>
    <td>Outgoing proxy http URL to proxy the HTTP traffic</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L629">hyperswitch-app.server.proxy.https_url</a></div></td>
    <td><div><code>"https://proxy_https_url"</code></div></td>
    <td>Outgoing proxy https URL to proxy the HTTPS traffic</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L633">hyperswitch-app.server.redis.auto_pipeline</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Whether or not the client should automatically pipeline commands across tasks when possible.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L635">hyperswitch-app.server.redis.cluster_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L637">hyperswitch-app.server.redis.cluster_urls</a></div></td>
    <td><div><code>"['redis.cluster.uri-1:8080', 'redis.cluster.uri-2:4115']"</code></div></td>
    <td>List of redis cluster urls</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L639">hyperswitch-app.server.redis.default_command_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>An optional timeout to apply to all commands. In seconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L641">hyperswitch-app.server.redis.default_hash_ttl</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Default TTL for hashes entries, in seconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L643">hyperswitch-app.server.redis.default_ttl</a></div></td>
    <td><div><code>300</code></div></td>
    <td>Default TTL for entries, in seconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L645">hyperswitch-app.server.redis.disable_auto_backpressure</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Whether or not to disable the automatic backpressure features when pipelining is enabled.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L646">hyperswitch-app.server.redis.host</a></div></td>
    <td><div><code>"127.0.0.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L648">hyperswitch-app.server.redis.max_feed_count</a></div></td>
    <td><div><code>200</code></div></td>
    <td>The maximum number of frames that will be fed to a socket before flushing.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L650">hyperswitch-app.server.redis.max_in_flight_commands</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>The maximum number of in-flight commands (per connection) before backpressure will be applied.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L652">hyperswitch-app.server.redis.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L653">hyperswitch-app.server.redis.port</a></div></td>
    <td><div><code>6379</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L655">hyperswitch-app.server.redis.reconnect_delay</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Delay between reconnection attempts, in milliseconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L657">hyperswitch-app.server.redis.reconnect_max_attempts</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Maximum number of reconnection attempts to make before failing. Set to 0 to retry forever.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L659">hyperswitch-app.server.redis.stream_read_count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Default number of entries to read from stream if not provided in stream read options</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L661">hyperswitch-app.server.redis.unresponsive_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>An optional timeout for Unresponsive commands in seconds. This should be less than default_command_timeout.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L663">hyperswitch-app.server.redis.use_legacy_version</a></div></td>
    <td><div><code>false</code></div></td>
    <td>RESP protocol for fred crate (set this to true if using RESPv2 or redis version < 6)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L667">hyperswitch-app.server.replica_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L669">hyperswitch-app.server.replica_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L671">hyperswitch-app.server.replica_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L106">hyperswitch-app.server.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for the application</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L682">hyperswitch-app.server.report_download_config.authentication_function</a></div></td>
    <td><div><code>"report_download_config_authentication_function"</code></div></td>
    <td>Config to authentication function</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L674">hyperswitch-app.server.report_download_config.dispute_function</a></div></td>
    <td><div><code>"report_download_config_dispute_function"</code></div></td>
    <td>Config to download dispute report</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L676">hyperswitch-app.server.report_download_config.payment_function</a></div></td>
    <td><div><code>"report_download_config_payment_function"</code></div></td>
    <td>Config to download payment report</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L678">hyperswitch-app.server.report_download_config.refund_function</a></div></td>
    <td><div><code>"report_download_config_refund_function"</code></div></td>
    <td>Config to download refund report</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L680">hyperswitch-app.server.report_download_config.region</a></div></td>
    <td><div><code>"report_download_config_region"</code></div></td>
    <td>Region of the bucket</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L684">hyperswitch-app.server.run_env</a></div></td>
    <td><div><code>"sandbox"</code></div></td>
    <td>Processor URLs will be decided based on this config, Eg: sandbox or production</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L242">hyperswitch-app.server.secrets.kms_connector_onboarding_paypal_client_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L244">hyperswitch-app.server.secrets.kms_connector_onboarding_paypal_client_secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L246">hyperswitch-app.server.secrets.kms_connector_onboarding_paypal_partner_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L231">hyperswitch-app.server.secrets.kms_jwekey_rust_locker_encryption_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsn4glmrihAG7Vppqd3Hm\nRXZiGmuZW0J+NQt72453oSnGc6Sw1Fk/vY0WhQIn6/Ip1Xt6dnMyorI3b9RtfQNP\nDFND3/g7n2I9uMqEr6aYxg0pKw9UW3uBlzR5JzvMVnzEjIRfdtuqSlphdpAVuZPE\nFEN9kE/VasBIeaKmbYFZxmz4AN2IBBvqWCaqIQZOrTRzfGNhVBlX/O+Sv59cy6n6\nQEoYJ/Ww3R7cUlSrueQNlSubkoa8ihBcm9VA7Bdklrps7B17yzMTAgqhZPkLMIQQ\nDBI1vFDlSKrWHNXfm4WyAXJ8MXOl+ThNJdAoDw2wNJmfOrgaPQFiMfPZYgKl/2Gu\nYQIDAQAB\n-----END PUBLIC KEY-----\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L229">hyperswitch-app.server.secrets.kms_jwekey_tunnel_private_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L690">hyperswitch-app.server.secrets_management.hc_vault.token</a></div></td>
    <td><div><code>"vault_token"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L689">hyperswitch-app.server.secrets_management.hc_vault.url</a></div></td>
    <td><div><code>"http://vault:8200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L687">hyperswitch-app.server.secrets_management.secrets_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Secrets manager client to be used</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L693">hyperswitch-app.server.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L694">hyperswitch-app.server.server.port</a></div></td>
    <td><div><code>8080</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L696">hyperswitch-app.server.server.request_body_limit</a></div></td>
    <td><div><code>32768</code></div></td>
    <td>HTTP Request body limit. Defaults to 32kB</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L699">hyperswitch-app.server.server.shutdown_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>For more details: https://actix.rs/docs/server/#graceful-shutdown</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L700">hyperswitch-app.server.server.workers</a></div></td>
    <td><div><code>8</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L154">hyperswitch-app.server.serviceAccountAnnotations</a></div></td>
    <td><div><code>{
  "eks.amazonaws.com/role-arn": "my-role-arn"
}</code></div></td>
    <td>service account annotations to be used</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L112">hyperswitch-app.server.strategy.rollingUpdate.maxSurge</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L113">hyperswitch-app.server.strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L114">hyperswitch-app.server.strategy.type</a></div></td>
    <td><div><code>"RollingUpdate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L143">hyperswitch-app.server.terminationGracePeriodSeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td>The time kubernetes will wait after sending the termination signal to the pods</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L505">hyperswitch-app.server.theme.email_config.background_color</a></div></td>
    <td><div><code>"#FFFFFF"</code></div></td>
    <td>Background color of email body</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L499">hyperswitch-app.server.theme.email_config.entity_logo</a></div></td>
    <td><div><code>"https://example.com/logo.png"</code></div></td>
    <td>Logo URL of the entity to be used in emails</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L497">hyperswitch-app.server.theme.email_config.entity_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td>Name of the entity to be showed in emails</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L501">hyperswitch-app.server.theme.email_config.foreground_color</a></div></td>
    <td><div><code>"#000000"</code></div></td>
    <td>Foreground color of email text</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L503">hyperswitch-app.server.theme.email_config.primary_color</a></div></td>
    <td><div><code>"#006DF9"</code></div></td>
    <td>Primary color of email body</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L494">hyperswitch-app.server.theme.storage.aws_s3.bucket_name</a></div></td>
    <td><div><code>"bucket"</code></div></td>
    <td>AWS S3 bucket name for theme storage</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L492">hyperswitch-app.server.theme.storage.aws_s3.region</a></div></td>
    <td><div><code>"bucket_region"</code></div></td>
    <td>AWS region where the S3 bucket for theme storage is located</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L489">hyperswitch-app.server.theme.storage.file_storage_backend</a></div></td>
    <td><div><code>"aws_s3"</code></div></td>
    <td>Theme storage backend to be used</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L702">hyperswitch-app.server.user.base_url</a></div></td>
    <td><div><code>"http://localhost:9000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L707">hyperswitch-app.server.user.force_cookies</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L703">hyperswitch-app.server.user.force_two_factor_auth</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L704">hyperswitch-app.server.user.password_validity_in_days</a></div></td>
    <td><div><code>"90"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L705">hyperswitch-app.server.user.totp_issuer_name</a></div></td>
    <td><div><code>"Hyperswitch Sandbox"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L706">hyperswitch-app.server.user.two_factor_auth_expiry_in_secs</a></div></td>
    <td><div><code>"300"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L709">hyperswitch-app.server.user_auth_methods.encryption_key</a></div></td>
    <td><div><code>"A8EF32E029BC3342E54BF2E172A4D7AA43E8EF9D2C3A624A9F04E2EF79DC698F"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L14">hyperswitch-app.services.consumer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L38">hyperswitch-app.services.controlCenter.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L42">hyperswitch-app.services.controlCenter.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-control-center:v1.37.3"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L40">hyperswitch-app.services.controlCenter.version</a></div></td>
    <td><div><code>"v1.37.3"</code></div></td>
    <td>Control Center image</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L30">hyperswitch-app.services.drainer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L22">hyperswitch-app.services.producer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-app/values.yaml#L3">hyperswitch-app.services.router.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L11">hyperswitch-app.hyperswitch-card-vault.backend</a></div></td>
    <td><div><code>"local"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L177">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.database</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L173">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.host</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L176">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.password</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L174">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.port</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L175">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.username</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L171">hyperswitch-app.hyperswitch-card-vault.external.postgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L184">hyperswitch-app.hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"postgres:16-alpine3.19"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L185">hyperswitch-app.hyperswitch-card-vault.initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L182">hyperswitch-app.hyperswitch-card-vault.initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L187">hyperswitch-app.hyperswitch-card-vault.initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L161">hyperswitch-app.hyperswitch-card-vault.postgresql.architecture</a></div></td>
    <td><div><code>"standalone"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L160">hyperswitch-app.hyperswitch-card-vault.postgresql.auth.database</a></div></td>
    <td><div><code>"locker-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L159">hyperswitch-app.hyperswitch-card-vault.postgresql.auth.password</a></div></td>
    <td><div><code>"dummyPassword"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L158">hyperswitch-app.hyperswitch-card-vault.postgresql.auth.username</a></div></td>
    <td><div><code>"db_user"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L155">hyperswitch-app.hyperswitch-card-vault.postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L156">hyperswitch-app.hyperswitch-card-vault.postgresql.nameOverride</a></div></td>
    <td><div><code>"locker-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L163">hyperswitch-app.hyperswitch-card-vault.postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L167">hyperswitch-app.hyperswitch-card-vault.postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L164">hyperswitch-app.hyperswitch-card-vault.postgresql.primary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L133">hyperswitch-app.hyperswitch-card-vault.secrets.api_client.identity</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L115">hyperswitch-app.hyperswitch-card-vault.secrets.aws.key_id</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L116">hyperswitch-app.hyperswitch-card-vault.secrets.aws.region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L110">hyperswitch-app.hyperswitch-card-vault.secrets.database.password</a></div></td>
    <td><div><code>"dummyPassword"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L129">hyperswitch-app.hyperswitch-card-vault.secrets.external_key_manager.cert</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L78">hyperswitch-app.hyperswitch-card-vault.secrets.locker_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>To create this key pairs, follow the instructions provided here: </br> # Generating the private keys <pre>openssl genrsa -out locker-private-key.pem 2048</pre> <pre>openssl genrsa -out tenant-private-key.pem 2048</pre> # Generating the public keys </br> <pre>openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem</pre> <pre>openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem</pre> The private key for the locker from locker-private-key.pem</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L124">hyperswitch-app.hyperswitch-card-vault.secrets.tls.certificate</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L125">hyperswitch-app.hyperswitch-card-vault.secrets.tls.private_key</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L120">hyperswitch-app.hyperswitch-card-vault.secrets.vault.token</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L32">hyperswitch-app.hyperswitch-card-vault.server.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L16">hyperswitch-app.hyperswitch-card-vault.server.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L53">hyperswitch-app.hyperswitch-card-vault.server.apiClient.identity</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L56">hyperswitch-app.hyperswitch-card-vault.server.awsKms.keyId</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L57">hyperswitch-app.hyperswitch-card-vault.server.awsKms.region</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L50">hyperswitch-app.hyperswitch-card-vault.server.externalKeyManager.cert</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L49">hyperswitch-app.hyperswitch-card-vault.server.externalKeyManager.url</a></div></td>
    <td><div><code>"http://localhost:5000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L46">hyperswitch-app.hyperswitch-card-vault.server.extra.env</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L20">hyperswitch-app.hyperswitch-card-vault.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L24">hyperswitch-app.hyperswitch-card-vault.server.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-card-vault:v0.6.5-dev"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L29">hyperswitch-app.hyperswitch-card-vault.server.pod.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L21">hyperswitch-app.hyperswitch-card-vault.server.port</a></div></td>
    <td><div><code>"8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L60">hyperswitch-app.hyperswitch-card-vault.server.vault.url</a></div></td>
    <td><div><code>"http://127.0.0.1:8200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L22">hyperswitch-app.hyperswitch-card-vault.server.version</a></div></td>
    <td><div><code>"v0.6.5"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L138">hyperswitch-app.hyperswitch-card-vault.tenant_secrets.public.master_key</a></div></td>
    <td><div><code>"8283d68fdbd89a78aef9bed8285ed1cd9310012f660eefbad865f20a3f3dd9498f06147da6a7d9b84677cafca95024990b3d2296fbafc55e10dd76df"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L141">hyperswitch-app.hyperswitch-card-vault.tenant_secrets.public.public_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the tenant from tenant_secrets-public-public_key.pem</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L151">hyperswitch-app.hyperswitch-card-vault.tenant_secrets.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L194">hyperswitch-app.hyperswitch-card-vault.vaultKeysJob.checkVaultService.host</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L192">hyperswitch-app.hyperswitch-card-vault.vaultKeysJob.checkVaultService.image</a></div></td>
    <td><div><code>"curlimages/curl:8.7.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L193">hyperswitch-app.hyperswitch-card-vault.vaultKeysJob.checkVaultService.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L195">hyperswitch-app.hyperswitch-card-vault.vaultKeysJob.checkVaultService.port</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L190">hyperswitch-app.hyperswitch-card-vault.vaultKeysJob.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L197">hyperswitch-app.hyperswitch-card-vault.vaultKeysJob.keys.key1</a></div></td>
    <td><div><code>"3c82773a6621feee3d5e0ce96654bf1f"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L198">hyperswitch-app.hyperswitch-card-vault.vaultKeysJob.keys.key2</a></div></td>
    <td><div><code>"7de95dbbd5d020e6b2a44847b8942bf5"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L371">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/backend-protocol"</a></div></td>
    <td><div><code>"HTTP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L372">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/backend-protocol-version"</a></div></td>
    <td><div><code>"HTTP1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L373">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/group.name"</a></div></td>
    <td><div><code>"hyperswitch-monitoring-alb-ingress-group"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L374">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/ip-address-type"</a></div></td>
    <td><div><code>"ipv4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L375">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/listen-ports"</a></div></td>
    <td><div><code>"[{\"HTTP\": 80}]"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L376">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/load-balancer-name"</a></div></td>
    <td><div><code>"hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L377">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/scheme"</a></div></td>
    <td><div><code>"internet-facing"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L378">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/security-groups"</a></div></td>
    <td><div><code>"loadbalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L379">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/tags"</a></div></td>
    <td><div><code>"stack=hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L380">hyperswitch-monitoring.grafana.ingress.annotations."alb.ingress.kubernetes.io/target-type"</a></div></td>
    <td><div><code>"ip"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L368">hyperswitch-monitoring.grafana.ingress.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L382">hyperswitch-monitoring.grafana.ingress.hosts[0].host</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L384">hyperswitch-monitoring.grafana.ingress.hosts[0].paths[0].path</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L385">hyperswitch-monitoring.grafana.ingress.hosts[0].paths[0].pathType</a></div></td>
    <td><div><code>"Prefix"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L369">hyperswitch-monitoring.grafana.ingress.ingressClassName</a></div></td>
    <td><div><code>"alb"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L386">hyperswitch-monitoring.grafana.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L23">hyperswitch-monitoring.kube-prometheus-stack.alertmanager.alertmanagerSpec.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L20">hyperswitch-monitoring.kube-prometheus-stack.alertmanager.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L12">hyperswitch-monitoring.kube-prometheus-stack.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L105">hyperswitch-monitoring.kube-prometheus-stack.grafana.additionalDataSources</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L88">hyperswitch-monitoring.kube-prometheus-stack.grafana.adminPassword</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L102">hyperswitch-monitoring.kube-prometheus-stack.grafana.defaultDatasourceEnabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L87">hyperswitch-monitoring.kube-prometheus-stack.grafana.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L95">hyperswitch-monitoring.kube-prometheus-stack.grafana.image.tag</a></div></td>
    <td><div><code>"10.0.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L99">hyperswitch-monitoring.kube-prometheus-stack.grafana.plugins[0]</a></div></td>
    <td><div><code>"volkovlabs-variable-panel"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L110">hyperswitch-monitoring.kube-prometheus-stack.grafana.prometheus.datasource.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L125">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.dashboards.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L126">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.dashboards.label</a></div></td>
    <td><div><code>"grafana_dashboard"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L127">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.dashboards.labelValue</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L132">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.dashboards.provider.allowUiUpdates</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L129">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.dashboards.searchNamespace</a></div></td>
    <td><div><code>"ALL"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L121">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.datasources.defaultDatasourceEnabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L115">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.datasources.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L116">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.datasources.label</a></div></td>
    <td><div><code>"grafana_datasource"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L117">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.datasources.labelValue</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L119">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.datasources.searchNamespace</a></div></td>
    <td><div><code>"{{ .Release.Namespace }}"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L123">hyperswitch-monitoring.kube-prometheus-stack.grafana.sidecar.datasources.skipTlsVerify</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L91">hyperswitch-monitoring.kube-prometheus-stack.grafana.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L27">hyperswitch-monitoring.kube-prometheus-stack.prometheus.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L61">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].job_name</a></div></td>
    <td><div><code>"kubernetes-pods"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L63">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].kubernetes_sd_configs[0].role</a></div></td>
    <td><div><code>"pod"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L66">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[0].action</a></div></td>
    <td><div><code>"keep"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L67">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[0].regex</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L65">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[0].source_labels[0]</a></div></td>
    <td><div><code>"__meta_kubernetes_pod_annotation_prometheus_io_scrape"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L69">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[1].action</a></div></td>
    <td><div><code>"replace"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L71">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[1].regex</a></div></td>
    <td><div><code>"(.+)"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L68">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[1].source_labels[0]</a></div></td>
    <td><div><code>"__meta_kubernetes_pod_annotation_prometheus_io_path"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L70">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[1].target_label</a></div></td>
    <td><div><code>"__metrics_path__"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L73">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].action</a></div></td>
    <td><div><code>"replace"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L75">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].regex</a></div></td>
    <td><div><code>"([^:]+)(?::\\d+)?;(\\d+)"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L76">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].replacement</a></div></td>
    <td><div><code>"$1:$2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L72">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].source_labels[0]</a></div></td>
    <td><div><code>"__address__"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L72">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].source_labels[1]</a></div></td>
    <td><div><code>"__meta_kubernetes_pod_annotation_prometheus_io_port"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L74">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].target_label</a></div></td>
    <td><div><code>"__address__"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L78">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[1].job_name</a></div></td>
    <td><div><code>"kubernetes-nodes"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L80">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[1].kubernetes_sd_configs[0].role</a></div></td>
    <td><div><code>"node"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L82">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[1].relabel_configs[0].action</a></div></td>
    <td><div><code>"labelmap"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L83">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[1].relabel_configs[0].regex</a></div></td>
    <td><div><code>"__meta_kubernetes_node_label_(.+)"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L39">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.resources.limits.cpu</a></div></td>
    <td><div><code>"500m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L38">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.resources.limits.memory</a></div></td>
    <td><div><code>"1Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L36">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.cpu</a></div></td>
    <td><div><code>"50m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L35">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.memory</a></div></td>
    <td><div><code>"256Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L42">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.retention</a></div></td>
    <td><div><code>"30d"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L48">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.serviceMonitorNamespaceSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L45">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.serviceMonitorSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L54">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]</a></div></td>
    <td><div><code>"ReadWriteOnce"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L57">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage</a></div></td>
    <td><div><code>"50Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L30">hyperswitch-monitoring.kube-prometheus-stack.prometheus.prometheusSpec.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L17">hyperswitch-monitoring.kube-prometheus-stack.prometheusOperator.admissionWebhooks.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L390">hyperswitch-monitoring.loadBalancer.targetSecurityGroup</a></div></td>
    <td><div><code>"loadbalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L193">hyperswitch-monitoring.loki.backend.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L199">hyperswitch-monitoring.loki.chunksCache.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L170">hyperswitch-monitoring.loki.deploymentMode</a></div></td>
    <td><div><code>"SingleBinary"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L137">hyperswitch-monitoring.loki.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L138">hyperswitch-monitoring.loki.fullnameOverride</a></div></td>
    <td><div><code>"loki"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L195">hyperswitch-monitoring.loki.gateway.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L142">hyperswitch-monitoring.loki.loki.auth_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L149">hyperswitch-monitoring.loki.loki.commonConfig.replication_factor</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L167">hyperswitch-monitoring.loki.loki.limits_config.ingestion_burst_size_mb</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L166">hyperswitch-monitoring.loki.loki.limits_config.ingestion_rate_mb</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L165">hyperswitch-monitoring.loki.loki.limits_config.retention_period</a></div></td>
    <td><div><code>"168h"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L156">hyperswitch-monitoring.loki.loki.schemaConfig.configs[0].from</a></div></td>
    <td><div><code>"2024-01-01"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L162">hyperswitch-monitoring.loki.loki.schemaConfig.configs[0].index.period</a></div></td>
    <td><div><code>"24h"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L161">hyperswitch-monitoring.loki.loki.schemaConfig.configs[0].index.prefix</a></div></td>
    <td><div><code>"index_"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L158">hyperswitch-monitoring.loki.loki.schemaConfig.configs[0].object_store</a></div></td>
    <td><div><code>"filesystem"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L159">hyperswitch-monitoring.loki.loki.schemaConfig.configs[0].schema</a></div></td>
    <td><div><code>"v13"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L157">hyperswitch-monitoring.loki.loki.schemaConfig.configs[0].store</a></div></td>
    <td><div><code>"tsdb"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L146">hyperswitch-monitoring.loki.loki.server.grpc_listen_port</a></div></td>
    <td><div><code>9095</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L145">hyperswitch-monitoring.loki.loki.server.http_listen_port</a></div></td>
    <td><div><code>3100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L152">hyperswitch-monitoring.loki.loki.storage.type</a></div></td>
    <td><div><code>"filesystem"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L189">hyperswitch-monitoring.loki.read.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L201">hyperswitch-monitoring.loki.resultsCache.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L177">hyperswitch-monitoring.loki.singleBinary.persistence.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L178">hyperswitch-monitoring.loki.singleBinary.persistence.size</a></div></td>
    <td><div><code>"10Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L173">hyperswitch-monitoring.loki.singleBinary.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L184">hyperswitch-monitoring.loki.singleBinary.resources.limits.cpu</a></div></td>
    <td><div><code>"500m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L185">hyperswitch-monitoring.loki.singleBinary.resources.limits.memory</a></div></td>
    <td><div><code>"512Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L181">hyperswitch-monitoring.loki.singleBinary.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L182">hyperswitch-monitoring.loki.singleBinary.resources.requests.memory</a></div></td>
    <td><div><code>"256Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L175">hyperswitch-monitoring.loki.singleBinary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L191">hyperswitch-monitoring.loki.write.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L299">hyperswitch-monitoring.opentelemetry-collector.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L264">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.exporters.debug.verbosity</a></div></td>
    <td><div><code>"detailed"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L266">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.exporters.prometheus.endpoint</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:9898"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L270">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.extensions.health_check.endpoint</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:13133"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L247">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.batch</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L249">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.memory_limiter.check_interval</a></div></td>
    <td><div><code>"5s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L250">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.memory_limiter.limit_percentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L251">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.memory_limiter.spike_limit_percentage</a></div></td>
    <td><div><code>25</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L255">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].context</a></div></td>
    <td><div><code>"datapoint"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L257">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[0]</a></div></td>
    <td><div><code>"set(attributes[\"source_namespace\"], resource.attributes[\"k8s.namespace.name\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L258">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[1]</a></div></td>
    <td><div><code>"set(attributes[\"source_pod\"], resource.attributes[\"k8s.pod.name\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L259">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[2]</a></div></td>
    <td><div><code>"set(attributes[\"source_app\"], resource.attributes[\"app\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L260">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[3]</a></div></td>
    <td><div><code>"set(attributes[\"source_version\"], resource.attributes[\"version\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L244">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.receivers.otlp.protocols.grpc.endpoint</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:4317"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L281">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.extensions[0]</a></div></td>
    <td><div><code>"health_check"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L291">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.pipelines.metrics.exporters[0]</a></div></td>
    <td><div><code>"prometheus"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L287">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[0]</a></div></td>
    <td><div><code>"memory_limiter"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L288">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[1]</a></div></td>
    <td><div><code>"transform"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L289">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[2]</a></div></td>
    <td><div><code>"batch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L285">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.pipelines.metrics.receivers[0]</a></div></td>
    <td><div><code>"otlp"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L276">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.telemetry.logs.encoding</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L275">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.telemetry.logs.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L279">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.telemetry.metrics.address</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:8888"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L278">hyperswitch-monitoring.opentelemetry-collector.alternateConfig.service.telemetry.metrics.level</a></div></td>
    <td><div><code>"detailed"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L226">hyperswitch-monitoring.opentelemetry-collector.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L294">hyperswitch-monitoring.opentelemetry-collector.image.repository</a></div></td>
    <td><div><code>"docker.io/otel/opentelemetry-collector-contrib"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L295">hyperswitch-monitoring.opentelemetry-collector.image.tag</a></div></td>
    <td><div><code>"0.122.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L228">hyperswitch-monitoring.opentelemetry-collector.mode</a></div></td>
    <td><div><code>"deployment"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L231">hyperswitch-monitoring.opentelemetry-collector.namespaceOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L297">hyperswitch-monitoring.opentelemetry-collector.nodeSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L315">hyperswitch-monitoring.opentelemetry-collector.ports.hs-metrics.containerPort</a></div></td>
    <td><div><code>9898</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L314">hyperswitch-monitoring.opentelemetry-collector.ports.hs-metrics.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L317">hyperswitch-monitoring.opentelemetry-collector.ports.hs-metrics.protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L316">hyperswitch-monitoring.opentelemetry-collector.ports.hs-metrics.servicePort</a></div></td>
    <td><div><code>9898</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L321">hyperswitch-monitoring.opentelemetry-collector.ports.jaeger-compact.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L325">hyperswitch-monitoring.opentelemetry-collector.ports.jaeger-grpc.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L323">hyperswitch-monitoring.opentelemetry-collector.ports.jaeger-thrift.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L310">hyperswitch-monitoring.opentelemetry-collector.ports.otel-metrics.containerPort</a></div></td>
    <td><div><code>8888</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L309">hyperswitch-monitoring.opentelemetry-collector.ports.otel-metrics.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L312">hyperswitch-monitoring.opentelemetry-collector.ports.otel-metrics.protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L311">hyperswitch-monitoring.opentelemetry-collector.ports.otel-metrics.servicePort</a></div></td>
    <td><div><code>8888</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L319">hyperswitch-monitoring.opentelemetry-collector.ports.otlp-http.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L307">hyperswitch-monitoring.opentelemetry-collector.ports.otlp.appProtocol</a></div></td>
    <td><div><code>"grpc"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L304">hyperswitch-monitoring.opentelemetry-collector.ports.otlp.containerPort</a></div></td>
    <td><div><code>4317</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L303">hyperswitch-monitoring.opentelemetry-collector.ports.otlp.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L306">hyperswitch-monitoring.opentelemetry-collector.ports.otlp.protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L305">hyperswitch-monitoring.opentelemetry-collector.ports.otlp.servicePort</a></div></td>
    <td><div><code>4317</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L327">hyperswitch-monitoring.opentelemetry-collector.ports.zipkin.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L235">hyperswitch-monitoring.opentelemetry-collector.presets.kubernetesAttributes.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L237">hyperswitch-monitoring.opentelemetry-collector.presets.kubernetesAttributes.extractAllPodAnnotations</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L236">hyperswitch-monitoring.opentelemetry-collector.presets.kubernetesAttributes.extractAllPodLabels</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L339">hyperswitch-monitoring.opentelemetry-collector.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L333">hyperswitch-monitoring.opentelemetry-collector.resources.limits.cpu</a></div></td>
    <td><div><code>"1500m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L334">hyperswitch-monitoring.opentelemetry-collector.resources.limits.memory</a></div></td>
    <td><div><code>"4Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L336">hyperswitch-monitoring.opentelemetry-collector.resources.requests.cpu</a></div></td>
    <td><div><code>"250m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L337">hyperswitch-monitoring.opentelemetry-collector.resources.requests.memory</a></div></td>
    <td><div><code>"512Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L342">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L345">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.metricsEndpoints[0].honorLabels</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L346">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.metricsEndpoints[0].interval</a></div></td>
    <td><div><code>"30s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L347">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.metricsEndpoints[0].path</a></div></td>
    <td><div><code>"/metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L344">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.metricsEndpoints[0].port</a></div></td>
    <td><div><code>"otel-metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L349">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.metricsEndpoints[1].honorLabels</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L350">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.metricsEndpoints[1].interval</a></div></td>
    <td><div><code>"15s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L351">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.metricsEndpoints[1].path</a></div></td>
    <td><div><code>"/metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L348">hyperswitch-monitoring.opentelemetry-collector.serviceMonitor.metricsEndpoints[1].port</a></div></td>
    <td><div><code>"hs-metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L298">hyperswitch-monitoring.opentelemetry-collector.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L357">hyperswitch-monitoring.postgresql.external</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L363">hyperswitch-monitoring.postgresql.primary.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L359">hyperswitch-monitoring.postgresql.primary.host</a></div></td>
    <td><div><code>"postgresql"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L362">hyperswitch-monitoring.postgresql.primary.password</a></div></td>
    <td><div><code>"ZGJwYXNzd29yZDEx"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L360">hyperswitch-monitoring.postgresql.primary.port</a></div></td>
    <td><div><code>5432</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L361">hyperswitch-monitoring.postgresql.primary.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L212">hyperswitch-monitoring.promtail.config.clients[0].url</a></div></td>
    <td><div><code>"http://loki:3100/loki/api/v1/push"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L220">hyperswitch-monitoring.promtail.config.snippets.extraRelabelConfigs[0].action</a></div></td>
    <td><div><code>"keep"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L221">hyperswitch-monitoring.promtail.config.snippets.extraRelabelConfigs[0].regex</a></div></td>
    <td><div><code>"hyperswitch-.*"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L222">hyperswitch-monitoring.promtail.config.snippets.extraRelabelConfigs[0].source_labels[0]</a></div></td>
    <td><div><code>"__meta_kubernetes_pod_label_app"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L216">hyperswitch-monitoring.promtail.config.snippets.pipelineStages[0].cri</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L205">hyperswitch-monitoring.promtail.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-monitoring/values.yaml#L208">hyperswitch-monitoring.promtail.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L48">hyperswitch-web.autoBuild.buildImage</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-web"</code></div></td>
    <td>docker image to use for the build</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L64">hyperswitch-web.autoBuild.buildParam.appCloudFrontUrl</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L62">hyperswitch-web.autoBuild.buildParam.disableCSP</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L58">hyperswitch-web.autoBuild.buildParam.envBackendUrl</a></div></td>
    <td><div><code>"https://hyperswitch"</code></div></td>
    <td>node build parameter, hyperswitch server host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L60">hyperswitch-web.autoBuild.buildParam.envLogsUrl</a></div></td>
    <td><div><code>"https://hyperswitch-sdk-logs"</code></div></td>
    <td>node build parameter, hyperswitch SDK logs host</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L56">hyperswitch-web.autoBuild.buildParam.envSdkUrl</a></div></td>
    <td><div><code>"https://hyperswitch-sdk"</code></div></td>
    <td>node build parameter, hyperswitch-web sdk host (same as ingress host)</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L65">hyperswitch-web.autoBuild.buildParam.sdkCloudFrontUrl</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L44">hyperswitch-web.autoBuild.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td>enable npm auto build</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L46">hyperswitch-web.autoBuild.forceBuild</a></div></td>
    <td><div><code>false</code></div></td>
    <td>force rebuild assets even these files exist</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L51">hyperswitch-web.autoBuild.gitCloneParam.gitRepo</a></div></td>
    <td><div><code>"https://github.com/juspay/hyperswitch-web"</code></div></td>
    <td>hyperswitch-web repository</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L53">hyperswitch-web.autoBuild.gitCloneParam.gitVersion</a></div></td>
    <td><div><code>"0.125.0"</code></div></td>
    <td>hyperswitch-web repository tag</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L68">hyperswitch-web.autoBuild.nginxConfig.extraPath</a></div></td>
    <td><div><code>"v1"</code></div></td>
    <td>nginx static server extra path ( like https://<host>/0.15.8/v0 )</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L70">hyperswitch-web.autoBuild.nginxConfig.image</a></div></td>
    <td><div><code>"nginx"</code></div></td>
    <td>nginx static server image</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L72">hyperswitch-web.autoBuild.nginxConfig.tag</a></div></td>
    <td><div><code>"1.25.3"</code></div></td>
    <td>nginx static server tag</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L193">hyperswitch-web.envFrom[0].configMapRef.name</a></div></td>
    <td><div><code>"hyperswitch-web-nginx"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L84">hyperswitch-web.image.nginxConfig.extraPath</a></div></td>
    <td><div><code>"v1"</code></div></td>
    <td>nginx extra path used to set liveness and readiness probe /0.80.0/v0</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L79">hyperswitch-web.image.pullPolicy</a></div></td>
    <td><div><code>"IfNotPresent"</code></div></td>
    <td>prebuild image pull policy</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L77">hyperswitch-web.image.repository</a></div></td>
    <td><div><code>"nginx"</code></div></td>
    <td>prebuild SDK image</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L81">hyperswitch-web.image.tag</a></div></td>
    <td><div><code>"0.35.4"</code></div></td>
    <td>prebuild image tag, the image tag whose default is the chart appVersion.</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L139">hyperswitch-web.ingress.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>ingress annotations</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L137">hyperswitch-web.ingress.className</a></div></td>
    <td><div><code>"nginx"</code></div></td>
    <td>ingress class name</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L135">hyperswitch-web.ingress.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>enable/disable ingress</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L143">hyperswitch-web.ingress.hosts</a></div></td>
    <td><div><code>[
  {
    "host": "chart-example.local",
    "paths": [
      {
        "path": "/",
        "pathType": "ImplementationSpecific"
      }
    ]
  }
]</code></div></td>
    <td>ingress hosts list</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L149">hyperswitch-web.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>tls configurations list</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L108">hyperswitch-web.podAnnotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>pod annotations</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L110">hyperswitch-web.podLabels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>pod labels</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L113">hyperswitch-web.podSecurityContext</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>pod security context</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L40">hyperswitch-web.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>deployment/statefulset replicas</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L117">hyperswitch-web.securityContext</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>security context</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L130">hyperswitch-web.service.port</a></div></td>
    <td><div><code>9050</code></div></td>
    <td>service port</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L128">hyperswitch-web.service.type</a></div></td>
    <td><div><code>"ClusterIP"</code></div></td>
    <td>service type</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L214">hyperswitch-web.services.router.host</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L217">hyperswitch-web.services.sdkDemo.hyperswitchPublishableKey</a></div></td>
    <td><div><code>"pub_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L218">hyperswitch-web.services.sdkDemo.hyperswitchSecretKey</a></div></td>
    <td><div><code>"secret_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-web/values.yaml#L216">hyperswitch-web.services.sdkDemo.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-web:v1.0.10"</code></div></td>
    <td></td>
  </tr>
</tbody>
</table>

