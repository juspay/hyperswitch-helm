# hyperswitch-encryption-service

![Version: 0.1.12](https://img.shields.io/badge/Version-0.1.12-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.1.14](https://img.shields.io/badge/AppVersion-v0.1.14-informational?style=flat-square)

"application"
A Helm chart for deploying Hyperswitch encryption-service

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 15.5.38 |

## Configuration

### Backend Selection

The chart supports three backend options for encryption key management:
- `local` (default): Local master key encryption
- `aws`: AWS KMS for key encryption
- `vault`: HashiCorp Vault for key management

Set the backend using:
```yaml
backend: local  # or 'aws' or 'vault'
```

### Backend-Specific Configuration

#### AWS KMS Backend
When using AWS KMS (`backend: aws`), configure:
```yaml
backend: aws

secrets:
  aws:
    key_id: "your-kms-key-id"
    region: "us-east-1"

server:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
```

#### HashiCorp Vault Backend
When using HashiCorp Vault (`backend: vault`), configure:
```yaml
backend: vault

secrets:
  vault:
    token: "your-vault-token"
```

#### Local Backend
When using local encryption (`backend: local`), configure:
```yaml
backend: local

secrets:
  master_key: "your-64-character-hex-master-key"
```

### Multi-tenancy Configuration

The encryption service supports multi-tenant deployments:
```yaml
multitenancy:
  tenants:
    public:
      schema: "public"
    global:
      schema: "global"
```

### TLS/mTLS Configuration

To enable TLS/mTLS for the encryption service:
```yaml
secrets:
  tls:
    cert: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
    ca: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

### Database Configuration

The chart supports both internal (Bitnami PostgreSQL) and external PostgreSQL:

#### Internal PostgreSQL (default)
```yaml
postgresql:
  enabled: true
  auth:
    username: db_user
    password: your-secure-password
    database: encryption_db
```

#### External PostgreSQL
```yaml
postgresql:
  enabled: false

external:
  postgresql:
    enabled: true
    config:
      host: postgres.example.com
      port: 5432
      username: db_user
      password: your-secure-password
      database: encryption_db
    enable_ssl: false
```

#### PostgreSQL with SSL/TLS
```yaml
external:
  postgresql:
    enabled: true
    enable_ssl: true
    config:
      host: postgres.example.com
      port: 5432
      username: db_user
      password: your-secure-password
      database: encryption_db

secrets:
  database:
    root_ca: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

## Values
<h3>Encryption Service Secrets</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L53">configs.certs</a></div></td>
    <td><div><code>{
  "root_ca": "sample_cert",
  "tls_cert": "sample_cert",
  "tls_key": "sample_cert"
}</code></div></td>
    <td>TLS root CA, server certificate and private key used by the encryption service (see TLS/mTLS Configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L66">configs.database.root_ca</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Root CA for the PostgreSQL SSL/TLS connection (see Database Configuration with SSL/TLS)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L92">configs.secrets</a></div></td>
    <td><div><code>{
  "master_key": {
    "_secret": "6d761d32f1b14ef34cf016d726b29b02b5cfce92a8959f1bfb65995c8100925e"
  }
}</code></div></td>
    <td>Master key used for local (non-KMS/Vault) secrets encryption, 32-byte hex (see Backend Selection)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L134">externalPostgresql.config.password</a></div></td>
    <td><div><code>"db_pass"</code></div></td>
    <td>Password for the external PostgreSQL used by the encryption service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L116">postgresql.auth.password</a></div></td>
    <td><div><code>"db_pass"</code></div></td>
    <td>Password for the internal (Bitnami) PostgreSQL used by the encryption service</td>
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
    <td><div><a href="./values.yaml#L314">affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L40">annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L291">autoscaling.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L293">autoscaling.maxReplicas</a></div></td>
    <td><div><code>3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L292">autoscaling.minReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L294">autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L68">configs.cache.max_capacity</a></div></td>
    <td><div><code>10000</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L69">configs.cache.time_to_idle_secs</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L70">configs.cache.time_to_live_secs</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L58">configs.database.connect_timeout_secs</a></div></td>
    <td><div><code>5</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L59">configs.database.connection_acquire_timeout_secs</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L60">configs.database.idle_timeout_secs</a></div></td>
    <td><div><code>600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L61">configs.database.max_lifetime_secs</a></div></td>
    <td><div><code>1800</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L62">configs.database.min_idle</a></div></td>
    <td><div><code>2</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L63">configs.database.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L72">configs.log.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L73">configs.log.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L74">configs.log.log_level</a></div></td>
    <td><div><code>"debug"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L76">configs.metrics.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L80">configs.metrics.mode</a></div></td>
    <td><div><code>"prometheus"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L81">configs.metrics.port</a></div></td>
    <td><div><code>6128</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L85">configs.multitenancy.tenants.global.schema</a></div></td>
    <td><div><code>"global"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L87">configs.multitenancy.tenants.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L89">configs.pool_config.pool</a></div></td>
    <td><div><code>2</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L104">configs.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L103">configs.server.port</a></div></td>
    <td><div><code>5000</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L350">disableInternalSecrets</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L136">externalPostgresql.config.database</a></div></td>
    <td><div><code>"encryption_db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L129">externalPostgresql.config.host</a></div></td>
    <td><div><code>"localhost"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L135">externalPostgresql.config.plainpassword</a></div></td>
    <td><div><code>"db_pass"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L130">externalPostgresql.config.port</a></div></td>
    <td><div><code>5432</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L131">externalPostgresql.config.username</a></div></td>
    <td><div><code>"db_user"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L137">externalPostgresql.enable_ssl</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L127">externalPostgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L354">externalSecretsOperator.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L381">externalSecretsOperator.externalSecrets.secrets[0].creationPolicy</a></div></td>
    <td><div><code>"Owner"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L385">externalSecretsOperator.externalSecrets.secrets[0].dataFrom[0].extract.conversionStrategy</a></div></td>
    <td><div><code>"Default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L386">externalSecretsOperator.externalSecrets.secrets[0].dataFrom[0].extract.decodingStrategy</a></div></td>
    <td><div><code>"None"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L384">externalSecretsOperator.externalSecrets.secrets[0].dataFrom[0].extract.key</a></div></td>
    <td><div><code>"hyperswitch/encryption-service/secrets"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L387">externalSecretsOperator.externalSecrets.secrets[0].dataFrom[0].extract.metadataPolicy</a></div></td>
    <td><div><code>"None"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L378">externalSecretsOperator.externalSecrets.secrets[0].name</a></div></td>
    <td><div><code>"encryption-service-secrets"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L380">externalSecretsOperator.externalSecrets.secrets[0].refreshInterval</a></div></td>
    <td><div><code>"1h"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L379">externalSecretsOperator.externalSecrets.secrets[0].targetName</a></div></td>
    <td><div><code>"encryption-service-secrets"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L365">externalSecretsOperator.secretStore.name</a></div></td>
    <td><div><code>"encryption-service-secret-store"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L373">externalSecretsOperator.secretStore.provider.aws.auth.jwt.serviceAccountRef.name</a></div></td>
    <td><div><code>"encryption-service-eso-sa"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L369">externalSecretsOperator.secretStore.provider.aws.region</a></div></td>
    <td><div><code>"us-west-2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L368">externalSecretsOperator.secretStore.provider.aws.service</a></div></td>
    <td><div><code>"SecretsManager"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L359">externalSecretsOperator.serviceAccount.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L358">externalSecretsOperator.serviceAccount.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L360">externalSecretsOperator.serviceAccount.extraLabels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L361">externalSecretsOperator.serviceAccount.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L39">fullnameOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L10">global.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L9">global.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L8">global.imageRegistry</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L33">image.pullPolicy</a></div></td>
    <td><div><code>"IfNotPresent"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L28">image.registry</a></div></td>
    <td><div><code>"docker.juspay.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L29">image.repository</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-encryption-service"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L31">image.tag</a></div></td>
    <td><div><code>"v0.1.14"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L36">imagePullSecrets</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L212">ingress.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L211">ingress.className</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L210">ingress.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L216">ingress.hosts[0].host</a></div></td>
    <td><div><code>"hyperswitch-encryption-service.local"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L218">ingress.hosts[0].paths[0].path</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L219">ingress.hosts[0].paths[0].pathType</a></div></td>
    <td><div><code>"ImplementationSpecific"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L220">ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L144">initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"postgres:16-alpine3.19"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L143">initDB.checkPGisUp.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L145">initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L141">initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L148">initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L147">initDB.migration.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L336">istio.destinationRule.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L337">istio.destinationRule.trafficPolicy</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L318">istio.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L320">istio.virtualService.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L322">istio.virtualService.gateways</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L321">istio.virtualService.hosts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L324">istio.virtualService.http</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L277">livenessProbe.failureThreshold</a></div></td>
    <td><div><code>3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L272">livenessProbe.httpGet.path</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L273">livenessProbe.httpGet.port</a></div></td>
    <td><div><code>"http"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L274">livenessProbe.initialDelaySeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L275">livenessProbe.periodSeconds</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L278">livenessProbe.successThreshold</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L276">livenessProbe.timeoutSeconds</a></div></td>
    <td><div><code>5</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L38">nameOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L310">nodeSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L164">podAnnotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L167">podLabels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L169">podSecurityContext</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L118">postgresql.architecture</a></div></td>
    <td><div><code>"standalone"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L117">postgresql.auth.database</a></div></td>
    <td><div><code>"encryption_db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L113">postgresql.auth.username</a></div></td>
    <td><div><code>"db_user"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L108">postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L110">postgresql.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L111">postgresql.nameOverride</a></div></td>
    <td><div><code>"encryption-service-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L120">postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L123">postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L23">progressDeadlineSeconds</a></div></td>
    <td><div><code>600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L286">readinessProbe.failureThreshold</a></div></td>
    <td><div><code>3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L281">readinessProbe.httpGet.path</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L282">readinessProbe.httpGet.port</a></div></td>
    <td><div><code>"http"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L283">readinessProbe.initialDelaySeconds</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L284">readinessProbe.periodSeconds</a></div></td>
    <td><div><code>5</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L287">readinessProbe.successThreshold</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L285">readinessProbe.timeoutSeconds</a></div></td>
    <td><div><code>3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L13">replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L263">resources.limits.cpu</a></div></td>
    <td><div><code>"1000m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L264">resources.limits.memory</a></div></td>
    <td><div><code>"1Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L266">resources.requests.cpu</a></div></td>
    <td><div><code>"400m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L267">resources.requests.memory</a></div></td>
    <td><div><code>"400Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L172">securityContext</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L185">service.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L192">service.externalTrafficPolicy</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L194">service.internalTrafficPolicy</a></div></td>
    <td><div><code>"Cluster"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L190">service.loadBalancerClass</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L199">service.ports[0].name</a></div></td>
    <td><div><code>"https"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L200">service.ports[0].port</a></div></td>
    <td><div><code>443</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L202">service.ports[0].protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L201">service.ports[0].targetPort</a></div></td>
    <td><div><code>5000</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L203">service.ports[1].name</a></div></td>
    <td><div><code>"metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L204">service.ports[1].port</a></div></td>
    <td><div><code>6128</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L206">service.ports[1].protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L205">service.ports[1].targetPort</a></div></td>
    <td><div><code>6128</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L196">service.sessionAffinity</a></div></td>
    <td><div><code>"None"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L183">service.type</a></div></td>
    <td><div><code>"ClusterIP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L157">serviceAccount.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L155">serviceAccount.automount</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L153">serviceAccount.create</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L160">serviceAccount.name</a></div></td>
    <td><div><code>"encryption-service-role"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L257">serviceMonitor.basicAuth</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L232">serviceMonitor.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L243">serviceMonitor.interval</a></div></td>
    <td><div><code>"15s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L241">serviceMonitor.labels</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L255">serviceMonitor.metricRelabelings</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L238">serviceMonitor.namespace</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L247">serviceMonitor.path</a></div></td>
    <td><div><code>"/metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L235">serviceMonitor.portName</a></div></td>
    <td><div><code>"metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L253">serviceMonitor.relabelings</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L249">serviceMonitor.scheme</a></div></td>
    <td><div><code>"http"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L245">serviceMonitor.scrapeTimeout</a></div></td>
    <td><div><code>"30s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L259">serviceMonitor.targetLabels</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L251">serviceMonitor.tlsConfig</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L19">strategy.rollingUpdate.maxSurge</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L20">strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L17">strategy.type</a></div></td>
    <td><div><code>"RollingUpdate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L24">terminationGracePeriodSeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L312">tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L305">volumeMounts</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L298">volumes</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr>
</tbody>
</table>

## Examples

### Example 1: Local Development
```yaml
backend: local

secrets:
  access_token: "dev-access-token"
  hash_context: "keymanager:hyperswitch"
  master_key: "6d761d32f1b14ef34cf016d726b29b02b5cfce92a8959f1bfb65995c8100925e"

postgresql:
  enabled: true
  auth:
    password: "dev-password"
    database: "encryption_db"
```

### Example 2: Production with AWS KMS
```yaml
backend: aws

secrets:
  access_token: "secure-access-token"
  hash_context: "keymanager:hyperswitch"
  aws:
    key_id: "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    region: "us-east-1"
  database:
    password: "encrypted-password"

server:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/hyperswitch-encryption-service"

external:
  postgresql:
    enabled: true
    config:
      host: "prod-postgres.example.com"
      port: 5432
      username: "encryption_service_user"
      password: "encrypted-password"
      database: "encryption_db"

autoscaling:
  enabled: true
```

### Example 3: Production with HashiCorp Vault
```yaml
backend: vault

secrets:
  access_token: "secure-access-token"
  hash_context: "keymanager:hyperswitch"
  vault:
    token: "hvs.your-vault-token"

# Enable TLS
secrets:
  tls:
    cert: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
```

### Example 4: Multi-tenant Setup with mTLS
```yaml
backend: local

multitenancy:
  tenants:
    public:
      schema: "public"
    tenant1:
      schema: "tenant1"
    tenant2:
      schema: "tenant2"

# Enable mTLS
secrets:
  tls:
    cert: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
    ca: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

## Key Generation

### Generate Master Key
For local backend, generate a 32-byte (64 character hex) master key:
```bash
openssl rand -hex 32
```

### Generate Access Token
```bash
openssl rand -base64 32
```

### Generate TLS Certificates

```bash
# Generate CA certificate
openssl genrsa -out ca_key.pem 2048
openssl req -new -x509 -days 3650 -key ca_key.pem \
  -subj "/C=US/ST=CA/O=Cripta CA/CN=Cripta CA" -out ca_cert.pem

# Generate server certificate
openssl req -newkey rsa:2048 -nodes -sha256 -keyout rsa_sha256_key.pem \
  -subj "/C=US/ST=CA/O=Cripta/CN=localhost" -out server.csr

openssl x509 -req -sha256 -extfile <(printf "subjectAltName=DNS:localhost") -days 3650 \
  -CA ca_cert.pem -CAkey ca_key.pem -CAcreateserial \
  -in server.csr -out rsa_sha256_cert.pem

# Generate client certificate (for mTLS)
cat rsa_sha256_cert.pem rsa_sha256_key.pem > client.pem

# Clean up
rm ca_cert.srl server.csr
```

#### Using the certificates in values.yaml
```yaml
secrets:
  tls:
    cert: |
      # Contents of rsa_sha256_cert.pem
    key: |
      # Contents of rsa_sha256_key.pem
    ca: |
      # Contents of ca_cert.pem
```

## Integration with Card Vault

The Hyperswitch Encryption Service can be used as an external key management service for the Card Vault:

```yaml
# In card-vault values.yaml
server:
  externalKeyManager:
    url: "https://encryption-service:5000"

secrets:
  external_key_manager:
    cert: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
