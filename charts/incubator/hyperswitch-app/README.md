# hyperswitch-app

Hyperswitch is a community-led, open payments switch designed to empower digital businesses by providing fast, reliable, and affordable access to the best payments infrastructure.

![Version: 0.2.11](https://img.shields.io/badge/Version-0.2.11-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

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
| file://../hyperswitch-card-vault | hyperswitch-card-vault | 0.1.2 |
| https://charts.bitnami.com/bitnami | clickhouse | 6.3.3 |
| https://charts.bitnami.com/bitnami | kafka | 31.0.0 |
| https://charts.bitnami.com/bitnami | postgresql | 15.5.38 |
| https://charts.bitnami.com/bitnami | redis | 18.6.1 |
| https://codecentric.github.io/helm-charts | mailhog | 4.0.0 |
| https://helm.vector.dev | vector | 0.37.0 |

## Values
<h3>Dependencies configuration</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L1244">clickhouse.auth.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Clickhouse password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1241">clickhouse.auth.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1250">clickhouse.config.TZ</a></div></td>
    <td><div><code>"Asia/Kolkata"</code></div></td>
    <td>Clickhouse timezone</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1233">clickhouse.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Clickhouse sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1237">clickhouse.fullnameOverride</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>Name of the Clickhouse sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1263">clickhouse.logLevel</a></div></td>
    <td><div><code>"error"</code></div></td>
    <td>Clickhouse log level</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1256">clickhouse.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse replica count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1253">clickhouse.shards</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse shard count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1260">clickhouse.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Zookerper replica count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1103">externalPostgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Postgres server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1120">externalPostgresql.primary.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1114">externalPostgresql.primary.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1117">externalPostgresql.primary.auth.plainpassword</a></div></td>
    <td><div><code>null</code></div></td>
    <td>master DB plainpassword</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1111">externalPostgresql.primary.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1107">externalPostgresql.primary.host</a></div></td>
    <td><div><code>"postgresql-ext"</code></div></td>
    <td>External postgres host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1140">externalPostgresql.readOnly.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1134">externalPostgresql.readOnly.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1137">externalPostgresql.readOnly.auth.plainpassword</a></div></td>
    <td><div><code>null</code></div></td>
    <td>replica DB plainpassword</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1131">externalPostgresql.readOnly.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1124">externalPostgresql.readOnly.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>External postgres read only host enabled or disabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1127">externalPostgresql.readOnly.host</a></div></td>
    <td><div><code>"postgres-service"</code></div></td>
    <td>External postgres read only host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1037">externalRedis.auth.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>auth enabled or disabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1043">externalRedis.auth.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1040">externalRedis.auth.username</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1030">externalRedis.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Redis server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1033">externalRedis.host</a></div></td>
    <td><div><code>"redis-ext-master"</code></div></td>
    <td>External redis host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1183">kafka.broker.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for broker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1178">kafka.controller.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for controller</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1170">kafka.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Kafka sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1173">kafka.fullnameOverride</a></div></td>
    <td><div><code>"kafka0"</code></div></td>
    <td>Name of the Kafka sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1200">kafka.listeners.client.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener client protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1212">kafka.listeners.controller.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener controller protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1208">kafka.listeners.external.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener external protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1204">kafka.listeners.interbroker.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener interbroker protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1216">kafka.provisioning.replicationFactor</a></div></td>
    <td><div><code>1</code></div></td>
    <td>kafka provisioning replicationFactor</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1195">kafka.service.ports.client</a></div></td>
    <td><div><code>29092</code></div></td>
    <td>Client port for Kafka</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1190">kafka.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for zookeeper</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1279">mailhog.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Mailhog sub-chart helm installation for email testing</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1282">mailhog.fullnameOverride</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Name of the Mailhog sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1073">postgresql.architecture</a></div></td>
    <td><div><code>"replication"</code></div></td>
    <td>Postgresql architecture: replication or standalone</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1056">postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>enable Bitnami postgresql sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1070">postgresql.global.postgresql.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql database</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1067">postgresql.global.postgresql.auth.password</a></div></td>
    <td><div><code>"ZGJwYXNzd29yZDEx"</code></div></td>
    <td>Postgresql password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1064">postgresql.global.postgresql.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1084">postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>postgres primary name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1089">postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"150m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1093">postgresql.readReplicas.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of read replicas</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1098">postgresql.readReplicas.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1080">postgresql.replication.numSynchronousReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of synchronous replicas</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1077">postgresql.replication.synchronousCommit</a></div></td>
    <td><div><code>"off"</code></div></td>
    <td>synchronous_commit parameter</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1022">redis.auth.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable redis auth</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1025">redis.auth.sentinel</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable sentinel</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1008">redis.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>- enable Bitnami redis sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1014">redis.master.count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for master</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1018">redis.replica.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of replicas to be used for replica</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1289">vector.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Vector sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1293">vector.env[0]</a></div></td>
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
    <td><div><a href="./values.yaml#L974">controlCenter.env.default__endpoints__agreement_url</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"</code></div></td>
    <td>Hyperswitch terms and conditions url</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L977">controlCenter.env.default__endpoints__agreement_version</a></div></td>
    <td><div><code>"1.0.0"</code></div></td>
    <td>Agreement version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L968">controlCenter.env.default__endpoints__dss_certificate_url</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/certificates/PCI_DSS_v4-0_AOC_Juspay_2024.pdf"</code></div></td>
    <td>PCI DSS certificate url</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L971">controlCenter.env.default__endpoints__favicon_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Endpoints favicon url</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L981">controlCenter.env.default__endpoints__mixpanel_token</a></div></td>
    <td><div><code>"dd4da7f62941557e716fbc0a19f9cc7e"</code></div></td>
    <td>Mixpanel token</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L884">controlCenter.env.default__features__branding</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables customization of branding elements like logos, colors.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L881">controlCenter.env.default__features__email</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables user sign-in and sign-up using magic links instead of passwords. When enabled, users can request a magic link via email that logs them into their account or creates a new account if they are signing up.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L911">controlCenter.env.default__features__feedback</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the ability for users to provide direct product feedback from within the dashboard. When enabled, a feedback modal will be available in the UI that allows users to rate features, report bugs, and suggest improvements. Disabling this flag will remove the feedback modal and prevent collection of any user data.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L899">controlCenter.env.default__features__frm</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the Fraud and Risk Management (FRM) module within the dashboard. When enabled, this unlocks integrations with FRM players like Riskified and Signified. https://docs.hyperswitch.io/explore-hyperswitch/payment-flows-and-management/fraud-and-risk-management</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L914">controlCenter.env.default__features__generate_report</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the ability to generate detailed reports on payments, refunds, and disputes. When enabled, this allows users to pull reports covering the previous 6 months of transaction data. The reports can provide insights into trends, identify issues, and inform business decisions.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L908">controlCenter.env.default__features__is_live_mode</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the live mode - that the user is accessing. When enabled, it will show a visual indicator within the dashboard signaling whether the user is currently in a test environment or live production environment. In Live mode, current users are not allowed to sign up. Users must be created manually.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L902">controlCenter.env.default__features__mixpanel</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Controls the collection and transmission of anonymous usage data to Mixpanel for analytics. When enabled, the dashboard will automatically send information about user actions and events to Mixpanel without collecting any personally identifiable information via REST API.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L896">controlCenter.env.default__features__payout</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the payout functionality in the dashboard. When enabled, this allows users to configure payout profiles, manage recipient details, schedule disbursements, and process payout batches to pay out funds to third parties.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L890">controlCenter.env.default__features__quick_start</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the simplified onboarding flow for new users, where they connect to processors, configure payment routing and test a payment, all in one flow.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L893">controlCenter.env.default__features__recon</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables access to reconciliation capabilities in the Hyperswitch dashboard. When turned on, this unlocks the Reconciliation module that allows users to match payment transactions with bank/ledger entries for accounting purposes.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L905">controlCenter.env.default__features__sample_data</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the ability to load simulated sample data into the dashboard for preview purposes. When enabled, dummy transactions, analytics, and reporting data can be generated.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L887">controlCenter.env.default__features__surcharge</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Enables the ability to apply surcharges to payments. When enabled, you can create advanced rules based on payment parameters like amount, currency, and payment method to enforce surcharges as needed.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L919">controlCenter.env.default__features__test_live_toggle</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables users to toggle between test and live modes when signing in. When enabled, users will see an option during sign-in to actively switch between test and live environments.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L922">controlCenter.env.default__features__test_processors</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td>Allows enabling sandbox/test payment processors for testing purposes. When enabled, developers and testers can add test payment processors like Stripe Test or PayPal Test to trial payment flows without touching live transactions or making processor API calls.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L928">controlCenter.env.default__features__totp</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables totp will mandate 2fa for all users</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L925">controlCenter.env.default__features__user_journey_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Grants access to the user journey module within the analytics section of the dashboard. This feature provides comprehensive graphical representations of payment analytics, facilitating a deeper understanding of user behavior and usage patterns.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L987">controlCenter.env.default__theme__primary_color</a></div></td>
    <td><div><code>"#006DF9"</code></div></td>
    <td>Primary color for the theme</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L990">controlCenter.env.default__theme__primary_hover_color</a></div></td>
    <td><div><code>"#005ED6"</code></div></td>
    <td>Primary hover color for the theme</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L993">controlCenter.env.default__theme__sidebar_color</a></div></td>
    <td><div><code>"#242F48"</code></div></td>
    <td>Secondary color for the theme</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1002">controlCenter.env.mixpanelToken</a></div></td>
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
    <td><div><a href="./values.yaml#L293">server.analytics.clickhouse.database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse database name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L296">server.analytics.clickhouse.host</a></div></td>
    <td><div><code>"http://clickhouse:8123"</code></div></td>
    <td>Clickhouse host in http(s)://<URL>:<PORT> format</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L302">server.analytics.clickhouse.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Clickhouse password (optional)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L299">server.analytics.clickhouse.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L381">server.email.aws_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS region used by AWS SES</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L385">server.email.aws_ses.email_role_arn</a></div></td>
    <td><div><code>"arn:aws:iam::123456789012:role/SendEmailRole"</code></div></td>
    <td>The amazon resource name ( arn ) of the role which has permission to send emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L388">server.email.aws_ses.sts_role_session_name</a></div></td>
    <td><div><code>"SendEmailRole"</code></div></td>
    <td>An identifier for the assumed role session, used to uniquely identify a session.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L391">server.email.prod_intent_recipient_email</a></div></td>
    <td><div><code>"business@example.com"</code></div></td>
    <td>Recipient email for prod intent email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L394">server.email.recon_recipient_email</a></div></td>
    <td><div><code>"recon@example.com"</code></div></td>
    <td>Recipient email for recon request email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L397">server.email.sender_email</a></div></td>
    <td><div><code>"example@example.com"</code></div></td>
    <td>Sender email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L403">server.email.smtp.host</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Host of the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L408">server.email.smtp.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Password for the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L616">server.paze_decrypt_keys.paze_private_key</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY"</code></div></td>
    <td>Base 64 Encoded Private Key File cakey.pem generated for Paze -> Command to create private key: openssl req -newkey rsa:2048 -x509 -keyout cakey.pem -out cacert.pem -days 365</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L619">server.paze_decrypt_keys.paze_private_key_passphrase</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY_PASSPHRASE"</code></div></td>
    <td>PEM Passphrase used for generating Private Key File cakey.pem</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L167">server.secrets.admin_api_key</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>admin API key for admin authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L282">server.secrets.api_hash_key</a></div></td>
    <td><div><code>"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"</code></div></td>
    <td>API key hashing key.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L252">server.secrets.apple_pay_merchant_cert</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L255">server.secrets.apple_pay_merchant_cert_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generated by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L264">server.secrets.apple_pay_merchant_conf_merchant_cert</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L267">server.secrets.apple_pay_merchant_conf_merchant_cert_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generate by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L270">server.secrets.apple_pay_merchant_conf_merchant_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Refer to config.example.toml to learn how you can generate this value</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L258">server.secrets.apple_pay_ppc</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Payment Processing Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Payment Processing Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L261">server.secrets.apple_pay_ppc_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generated by Elliptic-curve prime256v1 curve. You can use `openssl ecparam -out private.key -name prime256v1 -genkey` to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L273">server.secrets.forex_api_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Api key for making request to foreign exchange Api, Follow https://github.com/juspay/hyperswitch/tree/main/crates/analytics#setting-up-forex-apis to get the forex api key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L276">server.secrets.forex_fallback_api_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Forex Api key for the fallback service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L170">server.secrets.jwt_secret</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>JWT secret used for user authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L285">server.secrets.keymanager</a></div></td>
    <td><div><code>{
  "ca": "sample_ca",
  "cert": "sample_cert"
}</code></div></td>
    <td>Encryption key used for encrypting data in user_authentication_methods table</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L186">server.secrets.kms_jwekey_vault_encryption_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the locker from locker-public-key.pub, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L199">server.secrets.kms_jwekey_vault_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>The private key for the tenant from tenant-private-key.pem, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L179">server.secrets.kms_key_id</a></div></td>
    <td><div><code>"kms_key_id"</code></div></td>
    <td>KMS key id for encryption and decryption</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L182">server.secrets.kms_key_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS KMS region</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L173">server.secrets.master_enc_key</a></div></td>
    <td><div><code>"471f22516724347bcca9c20c5fa88d9821c4604e63a6aceffd24605809c9237c"</code></div></td>
    <td>Master Encryption key used to encrypt merchant wise encryption key. Should be 32-byte long.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L279">server.secrets.pm_auth_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td># Payment method auth key used for authorization</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L176">server.secrets.recon_admin_api_key</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>Recon Admin API key for recon admin authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L249">server.secrets.redis_temp_locker_encryption_key</a></div></td>
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
    <td><div><a href="./values.yaml#L20">services.consumer.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-consumer:v1.116.0"</code></div></td>
    <td>Consumer image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L17">services.consumer.version</a></div></td>
    <td><div><code>"v1.116.0"</code></div></td>
    <td>Consumer version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L36">services.drainer.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-drainer:v1.116.0"</code></div></td>
    <td>Drainer image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L33">services.drainer.version</a></div></td>
    <td><div><code>"v1.116.0"</code></div></td>
    <td>Drainer version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L28">services.producer.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-producer:v1.116.0"</code></div></td>
    <td>Producer image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L25">services.producer.version</a></div></td>
    <td><div><code>"v1.116.0"</code></div></td>
    <td>Producer version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L12">services.router.host</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td>Router host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L9">services.router.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-router:v1.116.0"</code></div></td>
    <td>Router image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L6">services.router.version</a></div></td>
    <td><div><code>"v1.116.0"</code></div></td>
    <td>Router version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L46">services.sdk.host</a></div></td>
    <td><div><code>"http://localhost:9050"</code></div></td>
    <td>SDK host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L52">services.sdk.subversion</a></div></td>
    <td><div><code>"v1"</code></div></td>
    <td>SDK subversion</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L49">services.sdk.version</a></div></td>
    <td><div><code>"0.125.0"</code></div></td>
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
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L8">global.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L4">global.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L5">global.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1155">autoscaling.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1157">autoscaling.maxReplicas</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1156">autoscaling.minReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1158">autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1230">clickhouse.host</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1246">clickhouse.image.tag</a></div></td>
    <td><div><code>24.3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1234">clickhouse.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L878">controlCenter.env.binary</a></div></td>
    <td><div><code>"dashboard"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L978">controlCenter.env.default__endpoints__hypersense_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L983">controlCenter.env.default__endpoints__logo_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Endpoints logo url</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L984">controlCenter.env.default__endpoints__recon_iframe_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L929">controlCenter.env.default__features__authentication_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L930">controlCenter.env.default__features__compliance_certificate</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L931">controlCenter.env.default__features__configure_pmts</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L932">controlCenter.env.default__features__custom_webhook_headers</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L933">controlCenter.env.default__features__dev_alt_payment_methods</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L934">controlCenter.env.default__features__dev_click_to_pay</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L935">controlCenter.env.default__features__dev_debit_routing</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L936">controlCenter.env.default__features__dev_hypersense_v2_product</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L937">controlCenter.env.default__features__dev_intelligent_routing_v2</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L938">controlCenter.env.default__features__dev_modularity_v2</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L939">controlCenter.env.default__features__dev_recon_v2_product</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L940">controlCenter.env.default__features__dev_recovery_v2_product</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L941">controlCenter.env.default__features__dev_vault_v2_product</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L942">controlCenter.env.default__features__dev_webhooks</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L943">controlCenter.env.default__features__dispute_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L944">controlCenter.env.default__features__dispute_evidence_upload</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L945">controlCenter.env.default__features__down_time</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L946">controlCenter.env.default__features__force_cookies</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L947">controlCenter.env.default__features__global_search</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L948">controlCenter.env.default__features__global_search_filters</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L949">controlCenter.env.default__features__granularity</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L950">controlCenter.env.default__features__live_users_counter</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L951">controlCenter.env.default__features__maintainence_alert</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L952">controlCenter.env.default__features__new_analytics</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L953">controlCenter.env.default__features__new_analytics_filters</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L954">controlCenter.env.default__features__new_analytics_refunds</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L955">controlCenter.env.default__features__new_analytics_smart_retries</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L956">controlCenter.env.default__features__performance_monitor</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L957">controlCenter.env.default__features__pm_authentication_processor</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L958">controlCenter.env.default__features__recon_v2</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L916">controlCenter.env.default__features__system_metrics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the ability to load simulated sample data into the dashboard for preview purposes.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L959">controlCenter.env.default__features__tax_processors</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L962">controlCenter.env.default__features__tenant_user</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L960">controlCenter.env.default__features__threeds_authenticator</a></div></td>
    <td><div><code>"true"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L961">controlCenter.env.default__features__transaction_view</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L963">controlCenter.env.default__merchant_config__new_analytics__merchant_ids</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L964">controlCenter.env.default__merchant_config__new_analytics__org_ids</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L965">controlCenter.env.default__merchant_config__new_analytics__profile_ids</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L994">controlCenter.env.default__theme__sidebar_border_color</a></div></td>
    <td><div><code>"#ECEFF3"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L995">controlCenter.env.default__theme__sidebar_primary</a></div></td>
    <td><div><code>"#FCFCFD"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L996">controlCenter.env.default__theme__sidebar_primary_text_color</a></div></td>
    <td><div><code>"#1C6DEA"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L997">controlCenter.env.default__theme__sidebar_secondary</a></div></td>
    <td><div><code>"#FFFFFF"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L998">controlCenter.env.default__theme__sidebar_secondary_text_color</a></div></td>
    <td><div><code>"#525866"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L999">controlCenter.env.host</a></div></td>
    <td><div><code>"hyperswitch-control-center"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L843">controlCenter.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for the application</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1161">hyperswitch-card-vault.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1164">hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"docker.io/bitnami/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1226">initCH.checkCHisUp.image</a></div></td>
    <td><div><code>"docker.io/bitnami/clickhouse:24.3"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1227">initCH.checkCHisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1145">initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"docker.io/bitnami/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1146">initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1143">initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1149">initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1147">initDB.refs</a></div></td>
    <td><div><code>"tags"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1184">kafka.broker.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1179">kafka.controller.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1220">kafka.extraConfig</a></div></td>
    <td><div><code>"offsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1152">loadBalancer.targetSecurityGroup</a></div></td>
    <td><div><code>"loadBalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1058">postgresql.image.tag</a></div></td>
    <td><div><code>"16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1010">redis.image.tag</a></div></td>
    <td><div><code>"7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1048">redisMiscConfig.checkRedisIsUp.initContainer.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1049">redisMiscConfig.checkRedisIsUp.initContainer.image</a></div></td>
    <td><div><code>"docker.io/bitnami/redis:7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1050">redisMiscConfig.checkRedisIsUp.initContainer.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L312">server.analytics.forex_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L304">server.analytics.source</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>The Analytics source/strategy to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L307">server.analytics.sqlx.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L309">server.analytics.sqlx.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L311">server.analytics.sqlx.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L148">server.annotations</a></div></td>
    <td><div><code>{
  "deployment.kubernetes.io/revision": "1"
}</code></div></td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L315">server.applepay_merchant_configs.applepay_endpoint</a></div></td>
    <td><div><code>"https://apple-pay-gateway.apple.com/paymentservices/registerMerchant"</code></div></td>
    <td>Apple pay gateway merchant endpoint</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L318">server.cell_information.id</a></div></td>
    <td><div><code>"12345"</code></div></td>
    <td>Default CellID for Global Cell Information</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L162">server.chat.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L163">server.chat.hyperswitch_ai_host</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L323">server.clone_connector_allowlist.connector_names</a></div></td>
    <td><div><code>"stripe,adyen,paypal,checkout,braintree,cybersource,square,worldpay,klarna,noon,archipel"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L321">server.clone_connector_allowlist.merchant_ids</a></div></td>
    <td><div><code>"merchant_ids"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L326">server.connector_onboarding.paypal.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L329">server.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id</a></div></td>
    <td><div><code>"['merchant_id_1','merchant_id_2']"</code></div></td>
    <td>List of merchant ids for which the payment id should be sent as connector request id</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L334">server.connectors.hyperswitch_vault.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L336">server.connectors.unified_authentication_service</a></div></td>
    <td><div><code>{
  "base_url": "http://localhost:8080"
}</code></div></td>
    <td>Unified Authentication Service Configuration</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L338">server.connectors.unified_authentication_service.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td>base url to call unified authentication service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L360">server.cors.allowed_methods</a></div></td>
    <td><div><code>"GET,POST,PUT,DELETE"</code></div></td>
    <td>List of methods that are allowed</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L363">server.cors.max_age</a></div></td>
    <td><div><code>30</code></div></td>
    <td>Maximum time (in seconds) for which this CORS request may be cached.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L361">server.cors.origin</a></div></td>
    <td><div><code>"https://hyperswti"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L365">server.cors.wildcard_origin</a></div></td>
    <td><div><code>true</code></div></td>
    <td>If true, allows any origin to make requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L368">server.crm.crm_manager</a></div></td>
    <td><div><code>"hubspot_proxy"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L371">server.crm.hubspot_proxy.form_id</a></div></td>
    <td><div><code>"form_id"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L373">server.crm.hubspot_proxy.request_url</a></div></td>
    <td><div><code>"request_url"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L376">server.email.active_email_client</a></div></td>
    <td><div><code>"SMTP"</code></div></td>
    <td>The currently active email client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L378">server.email.allowed_unverified_days</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of days the api calls ( with jwt token ) can be made without verifying the email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L400">server.email.smtp.connection</a></div></td>
    <td><div><code>"plaintext"</code></div></td>
    <td>connection type to be used for the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L410">server.email.smtp.port</a></div></td>
    <td><div><code>"1025"</code></div></td>
    <td>Port of the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L412">server.email.smtp.timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>timeout for the smtp server connection</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L405">server.email.smtp.username</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Username for the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L415">server.encryption_management.encryption_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Encryption manager client to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L421">server.events.kafka.api_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-api-log-events"</code></div></td>
    <td>Kafka topic to be used for incoming api events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L423">server.events.kafka.attempt_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td>Kafka topic to be used for PaymentAttempt events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L425">server.events.kafka.audit_events_topic</a></div></td>
    <td><div><code>"hyperswitch-audit-events"</code></div></td>
    <td>Kafka topic to be used for Payment Audit events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L427">server.events.kafka.authentication_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-authentication-events"</code></div></td>
    <td>Kafka topic to be used for Authentication events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L428">server.events.kafka.brokers</a></div></td>
    <td><div><code>"['kafka0:29092']"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L430">server.events.kafka.connector_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-connector-events"</code></div></td>
    <td>Kafka topic to be used for connector api events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L432">server.events.kafka.consolidated_events_topic</a></div></td>
    <td><div><code>"hyperswitch-consolidated-events"</code></div></td>
    <td>Kafka topic to be used for Consolidated events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L434">server.events.kafka.dispute_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td>Kafka topic to be used for Dispute events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L436">server.events.kafka.fraud_check_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-fraud-check-events"</code></div></td>
    <td>Kafka topic to be used for Fraud Check events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L438">server.events.kafka.intent_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td>Kafka topic to be used for PaymentIntent events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L440">server.events.kafka.outgoing_webhook_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-webhook-events"</code></div></td>
    <td>Kafka topic to be used for outgoing webhook events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L442">server.events.kafka.payout_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payout-events"</code></div></td>
    <td>Kafka topic to be used for Payouts and PayoutAttempt events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L444">server.events.kafka.refund_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td>Kafka topic to be used for Refund events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L446">server.events.kafka.routing_logs_topic</a></div></td>
    <td><div><code>"topic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L418">server.events.source</a></div></td>
    <td><div><code>"kafka"</code></div></td>
    <td>The event sink to push events supports kafka or logs (stdout)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L449">server.forex_api.data_expiration_delay_in_seconds</a></div></td>
    <td><div><code>21600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L451">server.forex_api.redis_lock_timeout_in_seconds</a></div></td>
    <td><div><code>100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L453">server.forex_api.redis_ttl_in_seconds</a></div></td>
    <td><div><code>172800</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L462">server.generic_link.payment_method_collect.enabled_payment_methods.bank_transfer</a></div></td>
    <td><div><code>"ach,bacs,sepa"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L461">server.generic_link.payment_method_collect.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L463">server.generic_link.payment_method_collect.enabled_payment_methods.wallet</a></div></td>
    <td><div><code>"paypal,pix,venmo"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L457">server.generic_link.payment_method_collect.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L458">server.generic_link.payment_method_collect.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L459">server.generic_link.payment_method_collect.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L466">server.generic_link.payout_link.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L468">server.generic_link.payout_link.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L469">server.generic_link.payout_link.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L470">server.generic_link.payout_link.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L621">server.google_pay_decrypt_keys.google_pay_root_signing_keys</a></div></td>
    <td><div><code>"GOOGLE_PAY_ROOT_SIGNING_KEYS"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L474">server.grpc_client.dynamic_routing_client.host</a></div></td>
    <td><div><code>"localhost"</code></div></td>
    <td>Client Host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L476">server.grpc_client.dynamic_routing_client.port</a></div></td>
    <td><div><code>7000</code></div></td>
    <td>Client Port</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L478">server.grpc_client.dynamic_routing_client.service</a></div></td>
    <td><div><code>"dynamo"</code></div></td>
    <td>Client Service Name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L485">server.grpc_client.unified_connectors_client.connection_timeout</a></div></td>
    <td><div><code>"10"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L481">server.grpc_client.unified_connectors_client.host</a></div></td>
    <td><div><code>"localhost"</code></div></td>
    <td>Client Host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L483">server.grpc_client.unified_connectors_client.port</a></div></td>
    <td><div><code>8000</code></div></td>
    <td>Client Port</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L713">server.keymanager.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable or disable keymanager</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L715">server.keymanager.url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>KeyManager service URL</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L508">server.kv_config.soft_kill</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L507">server.kv_config.tls</a></div></td>
    <td><div><code>900</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L151">server.labels</a></div></td>
    <td><div><code>{
  "app": "hyperswitch-server"
}</code></div></td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L512">server.lock_settings.delay_between_retries_in_milliseconds</a></div></td>
    <td><div><code>500</code></div></td>
    <td>Delay between retries in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L514">server.lock_settings.redis_lock_expiry_seconds</a></div></td>
    <td><div><code>180</code></div></td>
    <td>Seconds before the redis lock expires</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L520">server.locker.host</a></div></td>
    <td><div><code>"http://hyperswitch-vault"</code></div></td>
    <td>Locker host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L522">server.locker.host_rs</a></div></td>
    <td><div><code>null</code></div></td>
    <td>Rust Locker host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L524">server.locker.locker_enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Boolean to enable or disable saving cards in locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L526">server.locker.locker_signing_key_id</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td>Key_id to sign basilisk hs locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L528">server.locker.mock_locker</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Emulate a locker locally using Postgres</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L530">server.locker.ttl_for_storage_in_secs</a></div></td>
    <td><div><code>220752000</code></div></td>
    <td>Time to live for storage entries in locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L533">server.log.console.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L535">server.log.console.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td>Log level for console logs, ERROR, WARN, INFO, DEBUG</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L536">server.log.console.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L538">server.log.file.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L539">server.log.file.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L540">server.log.file.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L556">server.log.telemetry.autoConfigureOtelEndpoint</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Enable this when using hyperswitch-stack with monitoring. Auto-configures endpoint as: <release-name>-opentelemetry-collector.<namespace>.svc.cluster.local:4317 Leave false for standalone deployments or when using external collectors.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L544">server.log.telemetry.bg_metrics_collection_interval_in_secs</a></div></td>
    <td><div><code>15</code></div></td>
    <td>Interval for collecting the metrics in background thread</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L552">server.log.telemetry.external_otel_collector_endpoint</a></div></td>
    <td><div><code>""</code></div></td>
    <td>URL for external OpenTelemetry Collector endpoint to send metrics and traces to. The OpenTelemetry Collector must have a gRPC OTLP receiver listening at this endpoint. The value of `external_otel_collector_endpoint` will be considered even if the `hyperswitch-monitoring` chart is enabled.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L546">server.log.telemetry.ignore_errors</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether to ignore errors during traces or metrics pipeline setup</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L548">server.log.telemetry.metrics_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether metrics are enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L558">server.log.telemetry.otel_exporter_otlp_timeout</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>timeout (in milliseconds) for sending metrics and traces</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L559">server.log.telemetry.route_to_trace</a></div></td>
    <td><div><code>"['*/confirm']"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L560">server.log.telemetry.sampling_rate</a></div></td>
    <td><div><code>0.1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L562">server.log.telemetry.traces_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether traces are enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L564">server.log.telemetry.use_xray_generator</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Set this to true for AWS X-ray compatible traces</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L572">server.master_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L574">server.master_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L576">server.master_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L568">server.merchant_id_auth.merchant_id_auth_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L578">server.multitenancy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L580">server.multitenancy.global_tenant.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L581">server.multitenancy.global_tenant.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L582">server.multitenancy.global_tenant.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L583">server.multitenancy.global_tenant.tenant_id</a></div></td>
    <td><div><code>"global"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L588">server.multitenancy.tenants.public.accounts_schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L586">server.multitenancy.tenants.public.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L590">server.multitenancy.tenants.public.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L589">server.multitenancy.tenants.public.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L587">server.multitenancy.tenants.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L592">server.multitenancy.tenants.public.user.control_center_url</a></div></td>
    <td><div><code>"http://localhost:9000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L355">server.network_tokenization_service.check_token_status_url</a></div></td>
    <td><div><code>"https://example.com/status"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L353">server.network_tokenization_service.delete_token_url</a></div></td>
    <td><div><code>"https://example.com/delete"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L343">server.network_tokenization_service.fetch_token_url</a></div></td>
    <td><div><code>"https://example.com/fetch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L341">server.network_tokenization_service.generate_token_url</a></div></td>
    <td><div><code>"https://example.com/generate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L351">server.network_tokenization_service.key_id</a></div></td>
    <td><div><code>"key_id"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L349">server.network_tokenization_service.private_key</a></div></td>
    <td><div><code>"private_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L347">server.network_tokenization_service.public_key</a></div></td>
    <td><div><code>"public_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L345">server.network_tokenization_service.token_service_api_key</a></div></td>
    <td><div><code>"api_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L357">server.network_tokenization_service.webhook_source_verification_key</a></div></td>
    <td><div><code>"placeholder_webhook_key"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L595">server.opensearch.auth.auth</a></div></td>
    <td><div><code>"basic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L597">server.opensearch.auth.password</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L598">server.opensearch.auth.region</a></div></td>
    <td><div><code>"eu-central-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L596">server.opensearch.auth.username</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L600">server.opensearch.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L599">server.opensearch.host</a></div></td>
    <td><div><code>"https://localhost:9200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L602">server.opensearch.indexes.disputes</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L603">server.opensearch.indexes.payment_attempts</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L604">server.opensearch.indexes.payment_intents</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L605">server.opensearch.indexes.refunds</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L606">server.opensearch.indexes.sessionizer_disputes</a></div></td>
    <td><div><code>"sessionizer-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L607">server.opensearch.indexes.sessionizer_payment_attempts</a></div></td>
    <td><div><code>"sessionizer-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L608">server.opensearch.indexes.sessionizer_payment_intents</a></div></td>
    <td><div><code>"sessionizer-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L609">server.opensearch.indexes.sessionizer_refunds</a></div></td>
    <td><div><code>"sessionizer-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L612">server.payment_method_auth.redis_expiry</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Redis expiry time in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L145">server.podAnnotations</a></div></td>
    <td><div><code>{
  "traffic_sidecar_istio_io_excludeOutboundIPRanges": "10.23.6.12/32"
}</code></div></td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L108">server.progressDeadlineSeconds</a></div></td>
    <td><div><code>600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L624">server.proxy.bypass_proxy_hosts</a></div></td>
    <td><div><code>"localhost, cluster.local"</code></div></td>
    <td>A comma-separated list of domains or IP addresses that should not use the proxy. Whitespace between entries would be ignored.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L625">server.proxy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L627">server.proxy.http_url</a></div></td>
    <td><div><code>"http://proxy_http_url"</code></div></td>
    <td>Outgoing proxy http URL to proxy the HTTP traffic</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L629">server.proxy.https_url</a></div></td>
    <td><div><code>"https://proxy_https_url"</code></div></td>
    <td>Outgoing proxy https URL to proxy the HTTPS traffic</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L633">server.redis.auto_pipeline</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Whether or not the client should automatically pipeline commands across tasks when possible.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L635">server.redis.cluster_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L637">server.redis.cluster_urls</a></div></td>
    <td><div><code>"['redis.cluster.uri-1:8080', 'redis.cluster.uri-2:4115']"</code></div></td>
    <td>List of redis cluster urls</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L639">server.redis.default_command_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>An optional timeout to apply to all commands. In seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L641">server.redis.default_hash_ttl</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Default TTL for hashes entries, in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L643">server.redis.default_ttl</a></div></td>
    <td><div><code>300</code></div></td>
    <td>Default TTL for entries, in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L645">server.redis.disable_auto_backpressure</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Whether or not to disable the automatic backpressure features when pipelining is enabled.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L646">server.redis.host</a></div></td>
    <td><div><code>"127.0.0.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L648">server.redis.max_feed_count</a></div></td>
    <td><div><code>200</code></div></td>
    <td>The maximum number of frames that will be fed to a socket before flushing.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L650">server.redis.max_in_flight_commands</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>The maximum number of in-flight commands (per connection) before backpressure will be applied.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L652">server.redis.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L653">server.redis.port</a></div></td>
    <td><div><code>6379</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L655">server.redis.reconnect_delay</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Delay between reconnection attempts, in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L657">server.redis.reconnect_max_attempts</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Maximum number of reconnection attempts to make before failing. Set to 0 to retry forever.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L659">server.redis.stream_read_count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Default number of entries to read from stream if not provided in stream read options</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L661">server.redis.unresponsive_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>An optional timeout for Unresponsive commands in seconds. This should be less than default_command_timeout.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L663">server.redis.use_legacy_version</a></div></td>
    <td><div><code>false</code></div></td>
    <td>RESP protocol for fred crate (set this to true if using RESPv2 or redis version < 6)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L667">server.replica_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L669">server.replica_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L671">server.replica_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L106">server.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for the application</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L682">server.report_download_config.authentication_function</a></div></td>
    <td><div><code>"report_download_config_authentication_function"</code></div></td>
    <td>Config to authentication function</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L674">server.report_download_config.dispute_function</a></div></td>
    <td><div><code>"report_download_config_dispute_function"</code></div></td>
    <td>Config to download dispute report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L676">server.report_download_config.payment_function</a></div></td>
    <td><div><code>"report_download_config_payment_function"</code></div></td>
    <td>Config to download payment report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L678">server.report_download_config.refund_function</a></div></td>
    <td><div><code>"report_download_config_refund_function"</code></div></td>
    <td>Config to download refund report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L680">server.report_download_config.region</a></div></td>
    <td><div><code>"report_download_config_region"</code></div></td>
    <td>Region of the bucket</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L684">server.run_env</a></div></td>
    <td><div><code>"sandbox"</code></div></td>
    <td>Processor URLs will be decided based on this config, Eg: sandbox or production</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L242">server.secrets.kms_connector_onboarding_paypal_client_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L244">server.secrets.kms_connector_onboarding_paypal_client_secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L246">server.secrets.kms_connector_onboarding_paypal_partner_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L231">server.secrets.kms_jwekey_rust_locker_encryption_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsn4glmrihAG7Vppqd3Hm\nRXZiGmuZW0J+NQt72453oSnGc6Sw1Fk/vY0WhQIn6/Ip1Xt6dnMyorI3b9RtfQNP\nDFND3/g7n2I9uMqEr6aYxg0pKw9UW3uBlzR5JzvMVnzEjIRfdtuqSlphdpAVuZPE\nFEN9kE/VasBIeaKmbYFZxmz4AN2IBBvqWCaqIQZOrTRzfGNhVBlX/O+Sv59cy6n6\nQEoYJ/Ww3R7cUlSrueQNlSubkoa8ihBcm9VA7Bdklrps7B17yzMTAgqhZPkLMIQQ\nDBI1vFDlSKrWHNXfm4WyAXJ8MXOl+ThNJdAoDw2wNJmfOrgaPQFiMfPZYgKl/2Gu\nYQIDAQAB\n-----END PUBLIC KEY-----\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L229">server.secrets.kms_jwekey_tunnel_private_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L690">server.secrets_management.hc_vault.token</a></div></td>
    <td><div><code>"vault_token"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L689">server.secrets_management.hc_vault.url</a></div></td>
    <td><div><code>"http://vault:8200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L687">server.secrets_management.secrets_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Secrets manager client to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L693">server.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L694">server.server.port</a></div></td>
    <td><div><code>8080</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L696">server.server.request_body_limit</a></div></td>
    <td><div><code>32768</code></div></td>
    <td>HTTP Request body limit. Defaults to 32kB</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L699">server.server.shutdown_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>For more details: https://actix.rs/docs/server/#graceful-shutdown</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L700">server.server.workers</a></div></td>
    <td><div><code>8</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L154">server.serviceAccountAnnotations</a></div></td>
    <td><div><code>{
  "eks.amazonaws.com/role-arn": "my-role-arn"
}</code></div></td>
    <td>service account annotations to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L112">server.strategy.rollingUpdate.maxSurge</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L113">server.strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L114">server.strategy.type</a></div></td>
    <td><div><code>"RollingUpdate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L143">server.terminationGracePeriodSeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td>The time kubernetes will wait after sending the termination signal to the pods</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L505">server.theme.email_config.background_color</a></div></td>
    <td><div><code>"#FFFFFF"</code></div></td>
    <td>Background color of email body</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L499">server.theme.email_config.entity_logo</a></div></td>
    <td><div><code>"https://example.com/logo.png"</code></div></td>
    <td>Logo URL of the entity to be used in emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L497">server.theme.email_config.entity_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td>Name of the entity to be showed in emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L501">server.theme.email_config.foreground_color</a></div></td>
    <td><div><code>"#000000"</code></div></td>
    <td>Foreground color of email text</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L503">server.theme.email_config.primary_color</a></div></td>
    <td><div><code>"#006DF9"</code></div></td>
    <td>Primary color of email body</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L494">server.theme.storage.aws_s3.bucket_name</a></div></td>
    <td><div><code>"bucket"</code></div></td>
    <td>AWS S3 bucket name for theme storage</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L492">server.theme.storage.aws_s3.region</a></div></td>
    <td><div><code>"bucket_region"</code></div></td>
    <td>AWS region where the S3 bucket for theme storage is located</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L489">server.theme.storage.file_storage_backend</a></div></td>
    <td><div><code>"aws_s3"</code></div></td>
    <td>Theme storage backend to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L702">server.user.base_url</a></div></td>
    <td><div><code>"http://localhost:9000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L707">server.user.force_cookies</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L703">server.user.force_two_factor_auth</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L704">server.user.password_validity_in_days</a></div></td>
    <td><div><code>"90"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L705">server.user.totp_issuer_name</a></div></td>
    <td><div><code>"Hyperswitch Sandbox"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L706">server.user.two_factor_auth_expiry_in_secs</a></div></td>
    <td><div><code>"300"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L709">server.user_auth_methods.encryption_key</a></div></td>
    <td><div><code>"A8EF32E029BC3342E54BF2E172A4D7AA43E8EF9D2C3A624A9F04E2EF79DC698F"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L14">services.consumer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L38">services.controlCenter.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L42">services.controlCenter.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-control-center:v1.37.3"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L40">services.controlCenter.version</a></div></td>
    <td><div><code>"v1.37.3"</code></div></td>
    <td>Control Center image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L30">services.drainer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L22">services.producer.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L3">services.router.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L11">hyperswitch-card-vault.backend</a></div></td>
    <td><div><code>"local"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L177">hyperswitch-card-vault.external.postgresql.config.database</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L173">hyperswitch-card-vault.external.postgresql.config.host</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L176">hyperswitch-card-vault.external.postgresql.config.password</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L174">hyperswitch-card-vault.external.postgresql.config.port</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L175">hyperswitch-card-vault.external.postgresql.config.username</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L171">hyperswitch-card-vault.external.postgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L184">hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"postgres:16-alpine3.19"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L185">hyperswitch-card-vault.initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L182">hyperswitch-card-vault.initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L187">hyperswitch-card-vault.initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L161">hyperswitch-card-vault.postgresql.architecture</a></div></td>
    <td><div><code>"standalone"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L160">hyperswitch-card-vault.postgresql.auth.database</a></div></td>
    <td><div><code>"locker-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L159">hyperswitch-card-vault.postgresql.auth.password</a></div></td>
    <td><div><code>"dummyPassword"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L158">hyperswitch-card-vault.postgresql.auth.username</a></div></td>
    <td><div><code>"db_user"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L155">hyperswitch-card-vault.postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L156">hyperswitch-card-vault.postgresql.nameOverride</a></div></td>
    <td><div><code>"locker-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L163">hyperswitch-card-vault.postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L167">hyperswitch-card-vault.postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L164">hyperswitch-card-vault.postgresql.primary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L133">hyperswitch-card-vault.secrets.api_client.identity</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L115">hyperswitch-card-vault.secrets.aws.key_id</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L116">hyperswitch-card-vault.secrets.aws.region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L110">hyperswitch-card-vault.secrets.database.password</a></div></td>
    <td><div><code>"dummyPassword"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L129">hyperswitch-card-vault.secrets.external_key_manager.cert</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L78">hyperswitch-card-vault.secrets.locker_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>To create this key pairs, follow the instructions provided here: </br> # Generating the private keys <pre>openssl genrsa -out locker-private-key.pem 2048</pre> <pre>openssl genrsa -out tenant-private-key.pem 2048</pre> # Generating the public keys </br> <pre>openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem</pre> <pre>openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem</pre> The private key for the locker from locker-private-key.pem</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L124">hyperswitch-card-vault.secrets.tls.certificate</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L125">hyperswitch-card-vault.secrets.tls.private_key</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L120">hyperswitch-card-vault.secrets.vault.token</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L32">hyperswitch-card-vault.server.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L16">hyperswitch-card-vault.server.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L53">hyperswitch-card-vault.server.apiClient.identity</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L56">hyperswitch-card-vault.server.awsKms.keyId</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L57">hyperswitch-card-vault.server.awsKms.region</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L50">hyperswitch-card-vault.server.externalKeyManager.cert</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L49">hyperswitch-card-vault.server.externalKeyManager.url</a></div></td>
    <td><div><code>"http://localhost:5000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L46">hyperswitch-card-vault.server.extra.env</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L20">hyperswitch-card-vault.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L24">hyperswitch-card-vault.server.image</a></div></td>
    <td><div><code>"docker.juspay.io/juspaydotin/hyperswitch-card-vault:v0.6.5-dev"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L29">hyperswitch-card-vault.server.pod.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L21">hyperswitch-card-vault.server.port</a></div></td>
    <td><div><code>"8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L60">hyperswitch-card-vault.server.vault.url</a></div></td>
    <td><div><code>"http://127.0.0.1:8200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L22">hyperswitch-card-vault.server.version</a></div></td>
    <td><div><code>"v0.6.5"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L138">hyperswitch-card-vault.tenant_secrets.public.master_key</a></div></td>
    <td><div><code>"8283d68fdbd89a78aef9bed8285ed1cd9310012f660eefbad865f20a3f3dd9498f06147da6a7d9b84677cafca95024990b3d2296fbafc55e10dd76df"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L141">hyperswitch-card-vault.tenant_secrets.public.public_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the tenant from tenant_secrets-public-public_key.pem</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L151">hyperswitch-card-vault.tenant_secrets.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L194">hyperswitch-card-vault.vaultKeysJob.checkVaultService.host</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L192">hyperswitch-card-vault.vaultKeysJob.checkVaultService.image</a></div></td>
    <td><div><code>"curlimages/curl:8.7.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L193">hyperswitch-card-vault.vaultKeysJob.checkVaultService.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L195">hyperswitch-card-vault.vaultKeysJob.checkVaultService.port</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L190">hyperswitch-card-vault.vaultKeysJob.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L197">hyperswitch-card-vault.vaultKeysJob.keys.key1</a></div></td>
    <td><div><code>"3c82773a6621feee3d5e0ce96654bf1f"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L198">hyperswitch-card-vault.vaultKeysJob.keys.key2</a></div></td>
    <td><div><code>"7de95dbbd5d020e6b2a44847b8942bf5"</code></div></td>
    <td></td>
  </tr>
</tbody>
</table>

