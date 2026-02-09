# hyperswitch-app

Hyperswitch is a community-led, open payments switch designed to empower digital businesses by providing fast, reliable, and affordable access to the best payments infrastructure.

![Version: 1.0.2](https://img.shields.io/badge/Version-1.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.117.0](https://img.shields.io/badge/AppVersion-v1.117.0-informational?style=flat-square)

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

## Values
<h3>Dependencies configuration</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L1625">clickhouse.auth.password</a></div></td>
    <td><div><code>"jhdvfvsnbdj"</code></div></td>
    <td>Clickhouse password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1622">clickhouse.auth.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1632">clickhouse.config.TZ</a></div></td>
    <td><div><code>"Asia/Kolkata"</code></div></td>
    <td>Clickhouse timezone</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1614">clickhouse.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Clickhouse sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1618">clickhouse.fullnameOverride</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>Name of the Clickhouse sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1647">clickhouse.logLevel</a></div></td>
    <td><div><code>"error"</code></div></td>
    <td>Clickhouse log level</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1638">clickhouse.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse replica count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1635">clickhouse.shards</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse shard count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1644">clickhouse.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Zookerper replica count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1249">externalPostgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Postgres server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1272">externalPostgresql.primary.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1266">externalPostgresql.primary.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1269">externalPostgresql.primary.auth.plainpassword</a></div></td>
    <td><div><code>null</code></div></td>
    <td>master DB plainpassword</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1263">externalPostgresql.primary.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1253">externalPostgresql.primary.host</a></div></td>
    <td><div><code>"postgresql-ext"</code></div></td>
    <td>External postgres host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1295">externalPostgresql.readOnly.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1292">externalPostgresql.readOnly.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1289">externalPostgresql.readOnly.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1276">externalPostgresql.readOnly.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>External postgres read only host enabled or disabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1279">externalPostgresql.readOnly.host</a></div></td>
    <td><div><code>"postgres-service"</code></div></td>
    <td>External postgres read only host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1181">externalRedis.auth.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>auth enabled or disabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1187">externalRedis.auth.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1184">externalRedis.auth.username</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1174">externalRedis.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Redis server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1177">externalRedis.host</a></div></td>
    <td><div><code>"redis-ext-master"</code></div></td>
    <td>External redis host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1561">kafka.broker.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for broker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1556">kafka.controller.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for controller</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1548">kafka.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Kafka sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1551">kafka.fullnameOverride</a></div></td>
    <td><div><code>"kafka0"</code></div></td>
    <td>Name of the Kafka sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1580">kafka.listeners.client.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener client protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1592">kafka.listeners.controller.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener controller protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1588">kafka.listeners.external.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener external protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1584">kafka.listeners.interbroker.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener interbroker protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1596">kafka.provisioning.replicationFactor</a></div></td>
    <td><div><code>1</code></div></td>
    <td>kafka provisioning replicationFactor</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1575">kafka.service.ports.client</a></div></td>
    <td><div><code>29092</code></div></td>
    <td>Client port for Kafka</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1570">kafka.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for zookeeper</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1663">mailhog.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Mailhog sub-chart helm installation for email testing</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1666">mailhog.fullnameOverride</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Name of the Mailhog sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1219">postgresql.architecture</a></div></td>
    <td><div><code>"replication"</code></div></td>
    <td>Postgresql architecture: replication or standalone</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1201">postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>enable Bitnami postgresql sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1216">postgresql.global.postgresql.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql database</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1213">postgresql.global.postgresql.auth.password</a></div></td>
    <td><div><code>"ZGJwYXNzd29yZDEx"</code></div></td>
    <td>Postgresql password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1210">postgresql.global.postgresql.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1230">postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>postgres primary name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1235">postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"150m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1239">postgresql.readReplicas.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of read replicas</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1244">postgresql.readReplicas.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1226">postgresql.replication.numSynchronousReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of synchronous replicas</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1223">postgresql.replication.synchronousCommit</a></div></td>
    <td><div><code>"off"</code></div></td>
    <td>synchronous_commit parameter</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1166">redis.auth.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable redis auth</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1169">redis.auth.sentinel</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable sentinel</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1151">redis.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>- enable Bitnami redis sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1158">redis.master.count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for master</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1162">redis.replica.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of replicas to be used for replica</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1672">vector.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Vector sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1676">vector.env[0]</a></div></td>
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
    <td><div><a href="./values.yaml#L1310">istio</a></div></td>
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
    <td><div><a href="./values.yaml#L205">server.configs.analytics.clickhouse.database_name</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse database name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L208">server.configs.analytics.clickhouse.host</a></div></td>
    <td><div><code>"http://clickhouse:8123"</code></div></td>
    <td>Clickhouse host in http(s)://<URL>:<PORT> format</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L214">server.configs.analytics.clickhouse.password</a></div></td>
    <td><div><code>{
  "_secretRef": {
    "key": "admin-password",
    "name": "clickhouse"
  }
}</code></div></td>
    <td>Clickhouse password (optional)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L211">server.configs.analytics.clickhouse.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L825">server.configs.api_keys.hash_key</a></div></td>
    <td><div><code>{
  "_secret": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
}</code></div></td>
    <td>API key hashing key.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L269">server.configs.applepay_decrypt_keys.apple_pay_merchant_cert</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L273">server.configs.applepay_decrypt_keys.apple_pay_merchant_cert_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Private key generated by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L277">server.configs.applepay_decrypt_keys.apple_pay_ppc</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Payment Processing Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Payment Processing Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L281">server.configs.applepay_decrypt_keys.apple_pay_ppc_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Private key generated by Elliptic-curve prime256v1 curve. You can use `openssl ecparam -out private.key -name prime256v1 -genkey` to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L264">server.configs.applepay_merchant_configs.common_merchant_identifier</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Refer to config.example.toml to learn how you can generate this value</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L256">server.configs.applepay_merchant_configs.merchant_cert</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L260">server.configs.applepay_merchant_configs.merchant_cert_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Private key generate by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L357">server.configs.email.aws_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS region used by AWS SES</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L361">server.configs.email.aws_ses.email_role_arn</a></div></td>
    <td><div><code>"arn:aws:iam::123456789012:role/SendEmailRole"</code></div></td>
    <td>The amazon resource name ( arn ) of the role which has permission to send emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L364">server.configs.email.aws_ses.sts_role_session_name</a></div></td>
    <td><div><code>"SendEmailRole"</code></div></td>
    <td>An identifier for the assumed role session, used to uniquely identify a session.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L367">server.configs.email.prod_intent_recipient_email</a></div></td>
    <td><div><code>"business@example.com"</code></div></td>
    <td>Recipient email for prod intent email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L370">server.configs.email.recon_recipient_email</a></div></td>
    <td><div><code>"recon@example.com"</code></div></td>
    <td>Recipient email for recon request email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L373">server.configs.email.sender_email</a></div></td>
    <td><div><code>"example@example.com"</code></div></td>
    <td>Sender email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L379">server.configs.email.smtp.host</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Host of the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L435">server.configs.forex_api.api_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Api key for making request to foreign exchange Api, Follow https://github.com/juspay/hyperswitch/tree/main/crates/analytics#setting-up-forex-apis to get the forex api key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L439">server.configs.forex_api.fallback_api_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Forex Api key for the fallback service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L763">server.configs.jwekey.vault_encryption_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the locker from locker-public-key.pub, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L777">server.configs.jwekey.vault_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>The private key for the tenant from tenant-private-key.pem, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L835">server.configs.key_manager.ca</a></div></td>
    <td><div><code>{
  "_secret": "sample_ca"
}</code></div></td>
    <td>CA certificate for the keymanager service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L839">server.configs.key_manager.cert</a></div></td>
    <td><div><code>{
  "_secret": "sample_cert"
}</code></div></td>
    <td>Client certificate for the keymanager service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L756">server.configs.kms.key_id</a></div></td>
    <td><div><code>{
  "_secret": "kms_key_id"
}</code></div></td>
    <td>KMS key id for encryption and decryption</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L539">server.configs.locker.redis_temp_locker_encryption_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td>Encryption key for redis temp locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L620">server.configs.payment_method_auth.pm_auth_key</a></div></td>
    <td><div><code>{
  "_secret": "dummy_val"
}</code></div></td>
    <td># Payment method auth key used for authorization</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L627">server.configs.paze_decrypt_keys.paze_private_key</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY"</code></div></td>
    <td>Base 64 Encoded Private Key File cakey.pem generated for Paze -> Command to create private key: openssl req -newkey rsa:2048 -x509 -keyout cakey.pem -out cacert.pem -days 365</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L630">server.configs.paze_decrypt_keys.paze_private_key_passphrase</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY_PASSPHRASE"</code></div></td>
    <td>PEM Passphrase used for generating Private Key File cakey.pem</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L850">server.configs.secrets.admin_api_key</a></div></td>
    <td><div><code>{
  "_secret": "test_admin"
}</code></div></td>
    <td>admin API key for admin authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L854">server.configs.secrets.jwt_secret</a></div></td>
    <td><div><code>{
  "_secret": "test_admin"
}</code></div></td>
    <td>JWT secret used for user authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L858">server.configs.secrets.master_enc_key</a></div></td>
    <td><div><code>{
  "_secret": "471f22516724347bcca9c20c5fa88d9821c4604e63a6aceffd24605809c9237c"
}</code></div></td>
    <td>Master Encryption key used to encrypt merchant wise encryption key. Should be 32-byte long.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L862">server.configs.secrets.recon_admin_api_key</a></div></td>
    <td><div><code>{
  "_secret": "test_admin"
}</code></div></td>
    <td>Recon Admin API key for recon admin authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L843">server.configs.user_auth_methods</a></div></td>
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
    <td><div><code>"v1.117.0"</code></div></td>
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
    <td><div><code>"v1.117.0"</code></div></td>
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
    <td><div><code>"v1.117.0"</code></div></td>
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
    <td><div><code>"v1.117.0"</code></div></td>
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
    <td><div><a href="./values.yaml#L93">_references</a></div></td>
    <td><div><code>{
  "configs": "{{ .Release.Name }}-hyperswitch-configs",
  "secrets": "{{ .Release.Name }}-hyperswitch-secrets"
}</code></div></td>
    <td>Common references for templated resource names</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L97">_references.configs</a></div></td>
    <td><div><code>"{{ .Release.Name }}-hyperswitch-configs"</code></div></td>
    <td>Hyperswitch configs reference with release name prefix</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L95">_references.secrets</a></div></td>
    <td><div><code>"{{ .Release.Name }}-hyperswitch-secrets"</code></div></td>
    <td>Hyperswitch secrets reference with release name prefix</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1409">argoRollouts.canary.analysis</a></div></td>
    <td><div><code>{
  "args": [],
  "enabled": false,
  "interval": "30s",
  "startingStep": 2,
  "victoriaMetrics": {
    "address": ""
  }
}</code></div></td>
    <td>Optional Canary Configuration Settings antiAffinity: object canaryService: string stableService: string maxSurge: stringOrInt maxUnavailable: stringOrInt trafficRouting: object AB Testing Analysis Configuration Performs automated analysis of canary deployments using VictoriaMetrics Checks for 5xx errors and fails the deployment after 3 occurrences</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1422">argoRollouts.canary.analysis.args</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Additional arguments to pass to the analysis template</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1411">argoRollouts.canary.analysis.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable AB testing analysis</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1418">argoRollouts.canary.analysis.interval</a></div></td>
    <td><div><code>"30s"</code></div></td>
    <td>Interval between metric queries</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1420">argoRollouts.canary.analysis.startingStep</a></div></td>
    <td><div><code>2</code></div></td>
    <td>Starting step for analysis (0-indexed)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1413">argoRollouts.canary.analysis.victoriaMetrics</a></div></td>
    <td><div><code>{
  "address": ""
}</code></div></td>
    <td>VictoriaMetrics configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1416">argoRollouts.canary.analysis.victoriaMetrics.address</a></div></td>
    <td><div><code>""</code></div></td>
    <td>VictoriaMetrics Prometheus-compatible API address Example: http://victoria-metrics.monitoring:8428</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1385">argoRollouts.canary.steps</a></div></td>
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
    <td><div><a href="./values.yaml#L1442">argoRollouts.canary.trafficRouting.headerRouting.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable header-based canary routing</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1447">argoRollouts.canary.trafficRouting.headerRouting.match</a></div></td>
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
    <td><div><a href="./values.yaml#L1445">argoRollouts.canary.trafficRouting.headerRouting.routeName</a></div></td>
    <td><div><code>"header-canary-route"</code></div></td>
    <td>Route name for managed header routing This route will be auto added to the VirtualService when headerRouting is enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1427">argoRollouts.canary.trafficRouting.istio</a></div></td>
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
    <td><div><a href="./values.yaml#L1434">argoRollouts.canary.trafficRouting.istio.destinationRule</a></div></td>
    <td><div><code>{
  "canarySubsetName": "canary",
  "stableSubsetName": "stable"
}</code></div></td>
    <td>DestinationRule subset names</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1430">argoRollouts.canary.trafficRouting.istio.virtualService</a></div></td>
    <td><div><code>{
  "routeNames": [
    "primary"
  ]
}</code></div></td>
    <td>VirtualService route name to manage canary routing</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1380">argoRollouts.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable Argo Rollouts for canary deployments (uses Rollout resource instead of Deployment) When disabled, standard Kubernetes Deployment is used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1453">argoRollouts.revisionHistoryLimit</a></div></td>
    <td><div><code>3</code></div></td>
    <td>Revision history limit for rollouts</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1459">autoscaling.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1461">autoscaling.maxReplicas</a></div></td>
    <td><div><code>5</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1460">autoscaling.minReplicas</a></div></td>
    <td><div><code>3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1462">autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1611">clickhouse.host</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1627">clickhouse.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/clickhouse"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1628">clickhouse.image.tag</a></div></td>
    <td><div><code>24.3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1615">clickhouse.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1641">clickhouse.zookeeper.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/zookeeper"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1472">disableInternalSecrets</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1478">externalSecretsOperator.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable External Secrets Operator resources</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1517">externalSecretsOperator.externalSecrets.secrets</a></div></td>
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
    <td><div><a href="./values.yaml#L1524">externalSecretsOperator.externalSecrets.secrets[0].creationPolicy</a></div></td>
    <td><div><code>"Owner"</code></div></td>
    <td>Creation policy</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1526">externalSecretsOperator.externalSecrets.secrets[0].dataFrom</a></div></td>
    <td><div><code>[
  {
    "extract": {
      "key": "HyperswitchKmsDataSecret"
    }
  }
]</code></div></td>
    <td>Extract configuration (use dataFrom.extract for full secret)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1522">externalSecretsOperator.externalSecrets.secrets[0].refreshInterval</a></div></td>
    <td><div><code>"1h"</code></div></td>
    <td>Refresh interval</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1520">externalSecretsOperator.externalSecrets.secrets[0].targetName</a></div></td>
    <td><div><code>"hyperswitch-secrets"</code></div></td>
    <td>Target secret name in Kubernetes</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1494">externalSecretsOperator.secretStore.name</a></div></td>
    <td><div><code>"hyperswitch-secret-store"</code></div></td>
    <td>Name of the SecretStore</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1497">externalSecretsOperator.secretStore.provider</a></div></td>
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
    <td><div><a href="./values.yaml#L1485">externalSecretsOperator.serviceAccount.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Annotations for the service account (e.g., IRSA role)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1483">externalSecretsOperator.serviceAccount.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Create service account</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1487">externalSecretsOperator.serviceAccount.extraLabels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Extra labels for the service account</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1489">externalSecretsOperator.serviceAccount.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Name of the service account (default: hyperswitch-eso-sa)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1465">hyperswitch-card-vault.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1469">hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1468">hyperswitch-card-vault.initDB.checkPGisUp.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1607">initCH.checkCHisUp.image</a></div></td>
    <td><div><code>"bitnamilegacy/clickhouse:24.3"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1606">initCH.checkCHisUp.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1608">initCH.checkCHisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1301">initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1300">initDB.checkPGisUp.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1302">initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1298">initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1306">initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1305">initDB.migration.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1303">initDB.refs</a></div></td>
    <td><div><code>"tags"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1357">istio.destinationRule</a></div></td>
    <td><div><code>{
  "trafficPolicy": {}
}</code></div></td>
    <td>DestinationRule configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1359">istio.destinationRule.trafficPolicy</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Traffic policy configuration for router - rendered directly as YAML</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1312">istio.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable Istio resources</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1315">istio.virtualService</a></div></td>
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
    <td><div><a href="./values.yaml#L1317">istio.virtualService.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Create VirtualService</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1321">istio.virtualService.gateways</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Gateways for the VirtualService</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1319">istio.virtualService.hosts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Hosts for the VirtualService</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1325">istio.virtualService.http</a></div></td>
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
    <td><div><a href="./values.yaml#L1562">kafka.broker.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1557">kafka.controller.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1600">kafka.extraConfig</a></div></td>
    <td><div><code>"offsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1545">kafka.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/kafka"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1567">kafka.zookeeper.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/zookeeper"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1456">loadBalancer.targetSecurityGroup</a></div></td>
    <td><div><code>"loadBalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1203">postgresql.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1204">postgresql.image.tag</a></div></td>
    <td><div><code>"16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1153">redis.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/redis"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1154">redis.image.tag</a></div></td>
    <td><div><code>"7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1192">redisMiscConfig.checkRedisIsUp.initContainer.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1194">redisMiscConfig.checkRedisIsUp.initContainer.image</a></div></td>
    <td><div><code>"bitnamilegacy/redis:7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1193">redisMiscConfig.checkRedisIsUp.initContainer.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1195">redisMiscConfig.checkRedisIsUp.initContainer.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L166">server.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L183">server.binary</a></div></td>
    <td><div><code>"router"</code></div></td>
    <td>Binary to be used for the hyperswitch Router</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L250">server.configs.analytics.forex_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L219">server.configs.analytics.source</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>The Analytics source/strategy to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L245">server.configs.analytics.sqlx.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L222">server.configs.analytics.sqlx.dbname</a></div></td>
    <td><div><code>{
  "_configRef": {
    "key": "ROUTER__MASTER_DATABASE__DBNAME",
    "name": "{{ .Release.Name }}-hyperswitch-configs"
  }
}</code></div></td>
    <td>Database name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L227">server.configs.analytics.sqlx.host</a></div></td>
    <td><div><code>{
  "_configRef": {
    "key": "ROUTER__MASTER_DATABASE__HOST",
    "name": "{{ .Release.Name }}-hyperswitch-configs"
  }
}</code></div></td>
    <td>Database host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L247">server.configs.analytics.sqlx.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L232">server.configs.analytics.sqlx.port</a></div></td>
    <td><div><code>{
  "_configRef": {
    "key": "ROUTER__MASTER_DATABASE__PORT",
    "name": "{{ .Release.Name }}-hyperswitch-configs"
  }
}</code></div></td>
    <td>Database port</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L249">server.configs.analytics.sqlx.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L237">server.configs.analytics.sqlx.username</a></div></td>
    <td><div><code>{
  "_configRef": {
    "key": "ROUTER__MASTER_DATABASE__USERNAME",
    "name": "{{ .Release.Name }}-hyperswitch-configs"
  }
}</code></div></td>
    <td>Database username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L253">server.configs.applepay_merchant_configs.applepay_endpoint</a></div></td>
    <td><div><code>"https://apple-pay-gateway.apple.com/paymentservices/registerMerchant"</code></div></td>
    <td>Apple pay gateway merchant endpoint</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L285">server.configs.cell_information.id</a></div></td>
    <td><div><code>"12345"</code></div></td>
    <td>Default CellID for Global Cell Information</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L198">server.configs.chat.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L200">server.configs.chat.hyperswitch_ai_host</a></div></td>
    <td><div><code>"http://0.0.0.0:8000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L290">server.configs.clone_connector_allowlist.connector_names</a></div></td>
    <td><div><code>"stripe,adyen,paypal,checkout,braintree,cybersource,square,worldpay,klarna,noon,archipel"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L288">server.configs.clone_connector_allowlist.merchant_ids</a></div></td>
    <td><div><code>"merchant_ids"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L296">server.configs.connector_onboarding.paypal.client_id._secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L299">server.configs.connector_onboarding.paypal.client_secret._secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L293">server.configs.connector_onboarding.paypal.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L302">server.configs.connector_onboarding.paypal.partner_id._secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L305">server.configs.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id[0]</a></div></td>
    <td><div><code>"merchant_id_1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L305">server.configs.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id[1]</a></div></td>
    <td><div><code>"merchant_id_2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L310">server.configs.connectors.hyperswitch_vault.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L312">server.configs.connectors.unified_authentication_service</a></div></td>
    <td><div><code>{
  "base_url": "http://localhost:8080"
}</code></div></td>
    <td>Unified Authentication Service Configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L314">server.configs.connectors.unified_authentication_service.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td>base url to call unified authentication service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L336">server.configs.cors.allowed_methods</a></div></td>
    <td><div><code>"GET,POST,PUT,DELETE"</code></div></td>
    <td>List of methods that are allowed</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L339">server.configs.cors.max_age</a></div></td>
    <td><div><code>30</code></div></td>
    <td>Maximum time (in seconds) for which this CORS request may be cached.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L337">server.configs.cors.origin</a></div></td>
    <td><div><code>"https://hyperswti"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L341">server.configs.cors.wildcard_origin</a></div></td>
    <td><div><code>true</code></div></td>
    <td>If true, allows any origin to make requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L344">server.configs.crm.crm_manager</a></div></td>
    <td><div><code>"hubspot_proxy"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L347">server.configs.crm.hubspot_proxy.form_id</a></div></td>
    <td><div><code>"form_id"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L349">server.configs.crm.hubspot_proxy.request_url</a></div></td>
    <td><div><code>"request_url"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L352">server.configs.email.active_email_client</a></div></td>
    <td><div><code>"SMTP"</code></div></td>
    <td>The currently active email client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L354">server.configs.email.allowed_unverified_days</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of days the api calls ( with jwt token ) can be made without verifying the email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L376">server.configs.email.smtp.connection</a></div></td>
    <td><div><code>"plaintext"</code></div></td>
    <td>connection type to be used for the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L389">server.configs.email.smtp.port</a></div></td>
    <td><div><code>"1025"</code></div></td>
    <td>Port of the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L391">server.configs.email.smtp.timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>timeout for the smtp server connection</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L394">server.configs.encryption_management.encryption_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Encryption manager client to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L404">server.configs.events.kafka.api_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-api-log-events"</code></div></td>
    <td>Kafka topic to be used for incoming api events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L406">server.configs.events.kafka.attempt_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td>Kafka topic to be used for PaymentAttempt events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L408">server.configs.events.kafka.audit_events_topic</a></div></td>
    <td><div><code>"hyperswitch-audit-events"</code></div></td>
    <td>Kafka topic to be used for Payment Audit events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L410">server.configs.events.kafka.authentication_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-authentication-events"</code></div></td>
    <td>Kafka topic to be used for Authentication events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L411">server.configs.events.kafka.brokers[0]</a></div></td>
    <td><div><code>"kafka0:29092"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L413">server.configs.events.kafka.connector_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-connector-events"</code></div></td>
    <td>Kafka topic to be used for connector api events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L415">server.configs.events.kafka.consolidated_events_topic</a></div></td>
    <td><div><code>"hyperswitch-consolidated-events"</code></div></td>
    <td>Kafka topic to be used for Consolidated events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L417">server.configs.events.kafka.dispute_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td>Kafka topic to be used for Dispute events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L419">server.configs.events.kafka.fraud_check_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-fraud-check-events"</code></div></td>
    <td>Kafka topic to be used for Fraud Check events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L421">server.configs.events.kafka.intent_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td>Kafka topic to be used for PaymentIntent events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L423">server.configs.events.kafka.outgoing_webhook_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-webhook-events"</code></div></td>
    <td>Kafka topic to be used for outgoing webhook events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L425">server.configs.events.kafka.payout_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payout-events"</code></div></td>
    <td>Kafka topic to be used for Payouts and PayoutAttempt events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L427">server.configs.events.kafka.refund_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td>Kafka topic to be used for Refund events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L431">server.configs.events.kafka.revenue_recovery_topic</a></div></td>
    <td><div><code>"topic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L429">server.configs.events.kafka.routing_logs_topic</a></div></td>
    <td><div><code>"topic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L401">server.configs.events.source</a></div></td>
    <td><div><code>"kafka"</code></div></td>
    <td>The event sink to push events supports kafka or logs (stdout)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L748">server.configs.file_upload_config.bucket_name</a></div></td>
    <td><div><code>"bucket"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L749">server.configs.file_upload_config.region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L442">server.configs.forex_api.data_expiration_delay_in_seconds</a></div></td>
    <td><div><code>21600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L444">server.configs.forex_api.redis_lock_timeout_in_seconds</a></div></td>
    <td><div><code>100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L446">server.configs.forex_api.redis_ttl_in_seconds</a></div></td>
    <td><div><code>172800</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L458">server.configs.generic_link.payment_method_collect.enabled_payment_methods.bank_transfer</a></div></td>
    <td><div><code>"ach,bacs,sepa"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L457">server.configs.generic_link.payment_method_collect.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L459">server.configs.generic_link.payment_method_collect.enabled_payment_methods.wallet</a></div></td>
    <td><div><code>"paypal,pix,venmo"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L451">server.configs.generic_link.payment_method_collect.expiry</a></div></td>
    <td><div><code>"900"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L450">server.configs.generic_link.payment_method_collect.sdk_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Auto-generated from services.sdk. Override with custom URL if needed.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L453">server.configs.generic_link.payment_method_collect.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L454">server.configs.generic_link.payment_method_collect.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L455">server.configs.generic_link.payment_method_collect.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L465">server.configs.generic_link.payout_link.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L463">server.configs.generic_link.payout_link.expiry</a></div></td>
    <td><div><code>"900"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L462">server.configs.generic_link.payout_link.sdk_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Auto-generated from services.sdk. Override with custom URL if needed.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L467">server.configs.generic_link.payout_link.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L468">server.configs.generic_link.payout_link.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L469">server.configs.generic_link.payout_link.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L632">server.configs.google_pay_decrypt_keys.google_pay_root_signing_keys</a></div></td>
    <td><div><code>"GOOGLE_PAY_ROOT_SIGNING_KEYS"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L477">server.configs.grpc_client.dynamic_routing_client.host</a></div></td>
    <td><div><code>"localhost"</code></div></td>
    <td>Client Host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L479">server.configs.grpc_client.dynamic_routing_client.port</a></div></td>
    <td><div><code>7000</code></div></td>
    <td>Client Port</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L481">server.configs.grpc_client.dynamic_routing_client.service</a></div></td>
    <td><div><code>"dynamo"</code></div></td>
    <td>Client Service Name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L492">server.configs.grpc_client.recovery_decider_client.base_url</a></div></td>
    <td><div><code>"http://127.0.0.1:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L484">server.configs.grpc_client.unified_connector_service.base_url</a></div></td>
    <td><div><code>"http://localhost:8000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L486">server.configs.grpc_client.unified_connector_service.connection_timeout</a></div></td>
    <td><div><code>"10"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L488">server.configs.grpc_client.unified_connector_service.ucs_only_connectors</a></div></td>
    <td><div><code>"paytm, phonepe"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L812">server.configs.jwekey.rust_locker_encryption_key._secret</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsn4glmrihAG7Vppqd3Hm\nRXZiGmuZW0J+NQt72453oSnGc6Sw1Fk/vY0WhQIn6/Ip1Xt6dnMyorI3b9RtfQNP\nDFND3/g7n2I9uMqEr6aYxg0pKw9UW3uBlzR5JzvMVnzEjIRfdtuqSlphdpAVuZPE\nFEN9kE/VasBIeaKmbYFZxmz4AN2IBBvqWCaqIQZOrTRzfGNhVBlX/O+Sv59cy6n6\nQEoYJ/Ww3R7cUlSrueQNlSubkoa8ihBcm9VA7Bdklrps7B17yzMTAgqhZPkLMIQQ\nDBI1vFDlSKrWHNXfm4WyAXJ8MXOl+ThNJdAoDw2wNJmfOrgaPQFiMfPZYgKl/2Gu\nYQIDAQAB\n-----END PUBLIC KEY-----\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L809">server.configs.jwekey.tunnel_private_key._secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L828">server.configs.key_manager</a></div></td>
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
    <td><div><a href="./values.yaml#L830">server.configs.key_manager.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable or disable keymanager</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L832">server.configs.key_manager.url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>KeyManager service URL</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L753">server.configs.kms.key_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS KMS region</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L515">server.configs.kv_config.soft_kill</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L514">server.configs.kv_config.ttl</a></div></td>
    <td><div><code>900</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L518">server.configs.lock_settings.delay_between_retries_in_milliseconds</a></div></td>
    <td><div><code>500</code></div></td>
    <td>Delay between retries in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L520">server.configs.lock_settings.redis_lock_expiry_seconds</a></div></td>
    <td><div><code>180</code></div></td>
    <td>Seconds before the redis lock expires</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L526">server.configs.locker.host</a></div></td>
    <td><div><code>"http://hyperswitch-vault"</code></div></td>
    <td>Locker host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L528">server.configs.locker.host_rs</a></div></td>
    <td><div><code>null</code></div></td>
    <td>Rust Locker host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L530">server.configs.locker.locker_enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Boolean to enable or disable saving cards in locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L532">server.configs.locker.locker_signing_key_id</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td>Key_id to sign basilisk hs locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L534">server.configs.locker.mock_locker</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Emulate a locker locally using Postgres</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L536">server.configs.locker.ttl_for_storage_in_secs</a></div></td>
    <td><div><code>220752000</code></div></td>
    <td>Time to live for storage entries in locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L543">server.configs.log.console.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L545">server.configs.log.console.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td>Log level for console logs, ERROR, WARN, INFO, DEBUG</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L546">server.configs.log.console.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L548">server.configs.log.file.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L549">server.configs.log.file.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L550">server.configs.log.file.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L554">server.configs.log.telemetry.bg_metrics_collection_interval_in_secs</a></div></td>
    <td><div><code>15</code></div></td>
    <td>Interval for collecting the metrics in background thread</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L556">server.configs.log.telemetry.ignore_errors</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether to ignore errors during traces or metrics pipeline setup</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L558">server.configs.log.telemetry.metrics_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether metrics are enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L563">server.configs.log.telemetry.otel_exporter_otlp_endpoint</a></div></td>
    <td><div><code>""</code></div></td>
    <td>URL for external OpenTelemetry Collector endpoint to send metrics and traces to. The OpenTelemetry Collector must have a gRPC OTLP receiver listening at this endpoint. If left empty, the endpoint will be auto-configured as: <release-name>-opentelemetry-collector.<namespace>.svc.cluster.local:4317 when using hyperswitch-stack with monitoring enabled. Leave empty for auto-configuration or specify custom endpoint.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L565">server.configs.log.telemetry.otel_exporter_otlp_timeout</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>timeout (in milliseconds) for sending metrics and traces</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L566">server.configs.log.telemetry.route_to_trace[0]</a></div></td>
    <td><div><code>"*/confirm"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L567">server.configs.log.telemetry.sampling_rate</a></div></td>
    <td><div><code>0.1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L569">server.configs.log.telemetry.traces_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether traces are enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L571">server.configs.log.telemetry.use_xray_generator</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Set this to true for AWS X-ray compatible traces</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L579">server.configs.master_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L581">server.configs.master_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L583">server.configs.master_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L575">server.configs.merchant_id_auth.merchant_id_auth_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L585">server.configs.multitenancy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L587">server.configs.multitenancy.global_tenant.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L588">server.configs.multitenancy.global_tenant.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L589">server.configs.multitenancy.global_tenant.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L590">server.configs.multitenancy.global_tenant.tenant_id</a></div></td>
    <td><div><code>"global"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L595">server.configs.multitenancy.tenants.public.accounts_schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L593">server.configs.multitenancy.tenants.public.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L597">server.configs.multitenancy.tenants.public.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L596">server.configs.multitenancy.tenants.public.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L594">server.configs.multitenancy.tenants.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L599">server.configs.multitenancy.tenants.public.user.control_center_url</a></div></td>
    <td><div><code>"http://localhost:9000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L331">server.configs.network_tokenization_service.check_token_status_url</a></div></td>
    <td><div><code>"https://example.com/status"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L329">server.configs.network_tokenization_service.delete_token_url</a></div></td>
    <td><div><code>"https://example.com/delete"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L319">server.configs.network_tokenization_service.fetch_token_url</a></div></td>
    <td><div><code>"https://example.com/fetch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L317">server.configs.network_tokenization_service.generate_token_url</a></div></td>
    <td><div><code>"https://example.com/generate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L327">server.configs.network_tokenization_service.key_id</a></div></td>
    <td><div><code>"key_id"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L325">server.configs.network_tokenization_service.private_key</a></div></td>
    <td><div><code>"private_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L323">server.configs.network_tokenization_service.public_key</a></div></td>
    <td><div><code>"public_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L321">server.configs.network_tokenization_service.token_service_api_key</a></div></td>
    <td><div><code>"api_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L333">server.configs.network_tokenization_service.webhook_source_verification_key</a></div></td>
    <td><div><code>"placeholder_webhook_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L602">server.configs.opensearch.auth.auth</a></div></td>
    <td><div><code>"basic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L604">server.configs.opensearch.auth.password</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L605">server.configs.opensearch.auth.region</a></div></td>
    <td><div><code>"eu-central-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L603">server.configs.opensearch.auth.username</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L607">server.configs.opensearch.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L606">server.configs.opensearch.host</a></div></td>
    <td><div><code>"https://localhost:9200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L609">server.configs.opensearch.indexes.disputes</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L610">server.configs.opensearch.indexes.payment_attempts</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L611">server.configs.opensearch.indexes.payment_intents</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L612">server.configs.opensearch.indexes.refunds</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L613">server.configs.opensearch.indexes.sessionizer_disputes</a></div></td>
    <td><div><code>"sessionizer-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L614">server.configs.opensearch.indexes.sessionizer_payment_attempts</a></div></td>
    <td><div><code>"sessionizer-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L615">server.configs.opensearch.indexes.sessionizer_payment_intents</a></div></td>
    <td><div><code>"sessionizer-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L616">server.configs.opensearch.indexes.sessionizer_refunds</a></div></td>
    <td><div><code>"sessionizer-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L472">server.configs.payment_link.sdk_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Auto-generated from services.sdk. Override with custom URL if needed.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L623">server.configs.payment_method_auth.redis_expiry</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Redis expiry time in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L635">server.configs.proxy.bypass_proxy_hosts</a></div></td>
    <td><div><code>"localhost, cluster.local"</code></div></td>
    <td>A comma-separated list of domains or IP addresses that should not use the proxy. Whitespace between entries would be ignored.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L636">server.configs.proxy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L638">server.configs.proxy.http_url</a></div></td>
    <td><div><code>"http://proxy_http_url"</code></div></td>
    <td>Outgoing proxy http URL to proxy the HTTP traffic</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L640">server.configs.proxy.https_url</a></div></td>
    <td><div><code>"https://proxy_https_url"</code></div></td>
    <td>Outgoing proxy https URL to proxy the HTTPS traffic</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L643">server.configs.proxy_status_mapping.proxy_connector_http_status_code</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L647">server.configs.redis.auto_pipeline</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Whether or not the client should automatically pipeline commands across tasks when possible.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L649">server.configs.redis.cluster_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L651">server.configs.redis.cluster_urls</a></div></td>
    <td><div><code>[
  "redis.cluster.uri-1:8080",
  "redis.cluster.uri-2:4115"
]</code></div></td>
    <td>List of redis cluster urls</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L653">server.configs.redis.default_command_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>An optional timeout to apply to all commands. In seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L655">server.configs.redis.default_hash_ttl</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Default TTL for hashes entries, in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L657">server.configs.redis.default_ttl</a></div></td>
    <td><div><code>300</code></div></td>
    <td>Default TTL for entries, in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L659">server.configs.redis.disable_auto_backpressure</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Whether or not to disable the automatic backpressure features when pipelining is enabled.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L661">server.configs.redis.max_feed_count</a></div></td>
    <td><div><code>200</code></div></td>
    <td>The maximum number of frames that will be fed to a socket before flushing.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L663">server.configs.redis.max_in_flight_commands</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>The maximum number of in-flight commands (per connection) before backpressure will be applied.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L665">server.configs.redis.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L667">server.configs.redis.reconnect_delay</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Delay between reconnection attempts, in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L669">server.configs.redis.reconnect_max_attempts</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Maximum number of reconnection attempts to make before failing. Set to 0 to retry forever.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L671">server.configs.redis.stream_read_count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Default number of entries to read from stream if not provided in stream read options</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L673">server.configs.redis.unresponsive_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>An optional timeout for Unresponsive commands in seconds. This should be less than default_command_timeout.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L675">server.configs.redis.use_legacy_version</a></div></td>
    <td><div><code>false</code></div></td>
    <td>RESP protocol for fred crate (set this to true if using RESPv2 or redis version < 6)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L679">server.configs.replica_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L681">server.configs.replica_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L683">server.configs.replica_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L694">server.configs.report_download_config.authentication_function</a></div></td>
    <td><div><code>"report_download_config_authentication_function"</code></div></td>
    <td>Config to authentication function</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L686">server.configs.report_download_config.dispute_function</a></div></td>
    <td><div><code>"report_download_config_dispute_function"</code></div></td>
    <td>Config to download dispute report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L688">server.configs.report_download_config.payment_function</a></div></td>
    <td><div><code>"report_download_config_payment_function"</code></div></td>
    <td>Config to download payment report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L690">server.configs.report_download_config.refund_function</a></div></td>
    <td><div><code>"report_download_config_refund_function"</code></div></td>
    <td>Config to download refund report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L692">server.configs.report_download_config.region</a></div></td>
    <td><div><code>"report_download_config_region"</code></div></td>
    <td>Region of the bucket</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L703">server.configs.revenue_recovery.card_config.amex.max_retries_per_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L704">server.configs.revenue_recovery.card_config.amex.max_retry_count_for_thirty_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L712">server.configs.revenue_recovery.card_config.discover.max_retries_per_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L713">server.configs.revenue_recovery.card_config.discover.max_retry_count_for_thirty_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L706">server.configs.revenue_recovery.card_config.mastercard.max_retries_per_day</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L707">server.configs.revenue_recovery.card_config.mastercard.max_retry_count_for_thirty_day</a></div></td>
    <td><div><code>35</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L709">server.configs.revenue_recovery.card_config.visa.max_retries_per_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L710">server.configs.revenue_recovery.card_config.visa.max_retry_count_for_thirty_day</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L697">server.configs.revenue_recovery.monitoring_threshold_in_seconds</a></div></td>
    <td><div><code>10368000</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L717">server.configs.revenue_recovery.recovery_timestamp.initial_timestamp_in_hours</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L699">server.configs.revenue_recovery.redis_ttl_in_seconds</a></div></td>
    <td><div><code>3888000</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L698">server.configs.revenue_recovery.retry_algorithm_type</a></div></td>
    <td><div><code>"cascading"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L865">server.configs.secrets.migration_encryption_timestamp._secret</a></div></td>
    <td><div><code>"1685510751"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L720">server.configs.secrets_management.secrets_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Secrets manager client to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L732">server.configs.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L733">server.configs.server.port</a></div></td>
    <td><div><code>8080</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L735">server.configs.server.request_body_limit</a></div></td>
    <td><div><code>32768</code></div></td>
    <td>HTTP Request body limit. Defaults to 32kB</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L738">server.configs.server.shutdown_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>For more details: https://actix.rs/docs/server/#graceful-shutdown</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L739">server.configs.server.workers</a></div></td>
    <td><div><code>8</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L512">server.configs.theme.email_config.background_color</a></div></td>
    <td><div><code>"#FFFFFF"</code></div></td>
    <td>Background color of email body</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L506">server.configs.theme.email_config.entity_logo_url</a></div></td>
    <td><div><code>"https://example.com/logo.png"</code></div></td>
    <td>Logo URL of the entity to be used in emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L504">server.configs.theme.email_config.entity_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td>Name of the entity to be showed in emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L508">server.configs.theme.email_config.foreground_color</a></div></td>
    <td><div><code>"#000000"</code></div></td>
    <td>Foreground color of email text</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L510">server.configs.theme.email_config.primary_color</a></div></td>
    <td><div><code>"#006DF9"</code></div></td>
    <td>Primary color of email body</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L501">server.configs.theme.storage.aws_s3.bucket_name</a></div></td>
    <td><div><code>"bucket"</code></div></td>
    <td>AWS S3 bucket name for theme storage</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L499">server.configs.theme.storage.aws_s3.region</a></div></td>
    <td><div><code>"bucket_region"</code></div></td>
    <td>AWS region where the S3 bucket for theme storage is located</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L496">server.configs.theme.storage.file_storage_backend</a></div></td>
    <td><div><code>"aws_s3"</code></div></td>
    <td>Theme storage backend to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L741">server.configs.user.base_url</a></div></td>
    <td><div><code>"http://localhost:9000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L746">server.configs.user.force_cookies</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L742">server.configs.user.force_two_factor_auth</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L743">server.configs.user.password_validity_in_days</a></div></td>
    <td><div><code>"90"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L744">server.configs.user.totp_issuer_name</a></div></td>
    <td><div><code>"Hyperswitch Sandbox"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L745">server.configs.user.two_factor_auth_expiry_in_secs</a></div></td>
    <td><div><code>"300"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L181">server.env</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>Environmant variables that are to be used by the hyperswitch application service this will extend the existing global configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L108">server.ingress.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Custom annotations for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L106">server.ingress.className</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Ingress class name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L104">server.ingress.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L110">server.ingress.hostname</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Hostname for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L112">server.ingress.path</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td>Path for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L114">server.ingress.pathType</a></div></td>
    <td><div><code>"Prefix"</code></div></td>
    <td>Path type for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L116">server.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>TLS configuration for the ingress</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L168">server.labels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L163">server.podAnnotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L118">server.progressDeadlineSeconds</a></div></td>
    <td><div><code>600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L101">server.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for the application</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L150">server.resources</a></div></td>
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
    <td><div><a href="./values.yaml#L185">server.run_env</a></div></td>
    <td><div><code>"sandbox"</code></div></td>
    <td>Processor URLs will be decided based on this config, Eg: production, sandbox or integ</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L176">server.serviceAccount.annotations</a></div></td>
    <td><div><code>{
  "eks.amazonaws.com/role-arn": "my-role-arn"
}</code></div></td>
    <td>Annotations to be added to the service account</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L172">server.serviceAccount.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Service account creation for the application</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L179">server.serviceAccount.labels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td>Labels to be added to the service account</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L174">server.serviceAccount.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Service account name for the application ( default: <release-name>-hyperswitch-router-role)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L122">server.strategy.rollingUpdate.maxSurge</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L123">server.strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L124">server.strategy.type</a></div></td>
    <td><div><code>"RollingUpdate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L161">server.terminationGracePeriodSeconds</a></div></td>
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
  </tr>
</tbody>
</table>

