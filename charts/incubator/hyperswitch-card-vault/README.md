# hyperswitch-card-vault

![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.7.0](https://img.shields.io/badge/AppVersion-0.7.0-informational?style=flat-square)

"application"
A Helm chart for creating Hyperswitch Card Vault

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 15.5.38 |

## Configuration

### Backend Selection

The chart supports three backend options for secrets management:
- `local` (default): No encryption for secrets
- `aws`: AWS KMS for secrets encryption
- `vault`: HashiCorp Vault for secrets management

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

server:
  vault:
    url: "http://vault.example.com:8200"
```

### TLS Configuration

To enable TLS for the card vault server:
```yaml
secrets:
  tls:
    certificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
    private_key: |
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
```

### External Key Manager with mTLS

To enable mTLS for external key manager:
```yaml
server:
  externalKeyManager:
    url: "https://keymanager.example.com:5000"

secrets:
  external_key_manager:
    cert: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
  api_client:
    identity: |
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
    database: locker-db
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
      database: locker-db
```

## Values
<h3>Card Vault Secrets</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L180">postgresql.auth.password</a></div></td>
    <td><div><code>"dummyPassword"</code></div></td>
    <td>Password for the internal (Bitnami) PostgreSQL used by the card vault</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L145">secrets.api_client</a></div></td>
    <td><div><code>{
  "identity": ""
}</code></div></td>
    <td>API client mTLS identity (required when server.externalKeyManager.mode is "enabled_with_mtls")</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L123">secrets.aws</a></div></td>
    <td><div><code>{
  "key_id": "",
  "region": "us-east-1"
}</code></div></td>
    <td>AWS KMS key id used to encrypt/decrypt secrets (required when backend: aws)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L117">secrets.database</a></div></td>
    <td><div><code>{
  "password": "dummyPassword"
}</code></div></td>
    <td>Database password for the card vault's PostgreSQL connection</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L140">secrets.external_key_manager</a></div></td>
    <td><div><code>{
  "caCert": ""
}</code></div></td>
    <td>External key manager mTLS CA certificate (required when server.externalKeyManager.mode is "enabled_with_mtls")</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L85">secrets.locker_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>To create this key pairs, follow the instructions provided here: </br> # Generating the private keys <pre>openssl genrsa -out locker-private-key.pem 2048</pre> <pre>openssl genrsa -out tenant-private-key.pem 2048</pre> # Generating the public keys </br> <pre>openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem</pre> <pre>openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem</pre> The private key for the locker from locker-private-key.pem</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L134">secrets.tls</a></div></td>
    <td><div><code>{
  "certificate": "",
  "private_key": ""
}</code></div></td>
    <td>TLS/mTLS certificate and private key for the card vault server (optional)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L129">secrets.vault</a></div></td>
    <td><div><code>{
  "token": ""
}</code></div></td>
    <td>HashiCorp Vault authentication token (required when backend: vault)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L153">tenant_secrets.public.master_key</a></div></td>
    <td><div><code>"8283d68fdbd89a78aef9bed8285ed1cd9310012f660eefbad865f20a3f3dd9498f06147da6a7d9b84677cafca95024990b3d2296fbafc55e10dd76df"</code></div></td>
    <td>Master key used to unlock/derive the tenant's encryption keys</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L157">tenant_secrets.public.public_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the tenant from tenant_secrets-public-public_key.pem</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L222">vaultKeysJob.keys</a></div></td>
    <td><div><code>{
  "key1": "3c82773a6621feee3d5e0ce96654bf1f",
  "key2": "7de95dbbd5d020e6b2a44847b8942bf5"
}</code></div></td>
    <td>Two custodian keys used to unlock the locker after deployment (see Post-Deployment steps)</td>
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
    <td><div><a href="./values.yaml#L15">backend</a></div></td>
    <td><div><code>"local"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L198">external.postgresql.config.database</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L194">external.postgresql.config.host</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L197">external.postgresql.config.password</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L195">external.postgresql.config.port</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L196">external.postgresql.config.username</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L192">external.postgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L12">global.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L8">global.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L5">global.imageRegistry</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L9">global.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L206">initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"postgres:16-alpine3.19"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L205">initDB.checkPGisUp.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L207">initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L203">initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L210">initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L209">initDB.migration.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L182">postgresql.architecture</a></div></td>
    <td><div><code>"standalone"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L181">postgresql.auth.database</a></div></td>
    <td><div><code>"locker-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L177">postgresql.auth.username</a></div></td>
    <td><div><code>"db_user"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L171">postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L173">postgresql.image.repository</a></div></td>
    <td><div><code>"bitnamilegacy/postgresql"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L174">postgresql.image.tag</a></div></td>
    <td><div><code>"16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L175">postgresql.nameOverride</a></div></td>
    <td><div><code>"locker-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L184">postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L188">postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L185">postgresql.primary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L37">server.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L20">server.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L62">server.awsKms.keyId</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L63">server.awsKms.region</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L58">server.external_key_manager.mode</a></div></td>
    <td><div><code>"disabled"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L59">server.external_key_manager.url</a></div></td>
    <td><div><code>"http://localhost:5000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L51">server.extra.env</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L24">server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L29">server.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-card-vault:v0.7.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L28">server.imageRegistry</a></div></td>
    <td><div><code>"docker.juspay.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L34">server.pod.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L25">server.port</a></div></td>
    <td><div><code>"8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L66">server.vault.url</a></div></td>
    <td><div><code>"http://127.0.0.1:8200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L26">server.version</a></div></td>
    <td><div><code>"v0.7.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L167">tenant_secrets.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L218">vaultKeysJob.checkVaultService.host</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L216">vaultKeysJob.checkVaultService.image</a></div></td>
    <td><div><code>"curlimages/curl:8.7.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L215">vaultKeysJob.checkVaultService.imageRegistry</a></div></td>
    <td><div><code>"docker.io"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L217">vaultKeysJob.checkVaultService.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L219">vaultKeysJob.checkVaultService.port</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L213">vaultKeysJob.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr>
</tbody>
</table>

## Examples

### Example 1: Local Development
```yaml
backend: local

postgresql:
  enabled: true
  auth:
    password: "dev-password"

tenant_secrets:
  public:
    master_key: "your-master-key"
    public_key: |
      -----BEGIN PUBLIC KEY-----
      ...
      -----END PUBLIC KEY-----
```

### Example 2: Production with AWS KMS
```yaml
backend: aws

secrets:
  aws:
    key_id: "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    region: "us-east-1"
  database:
    password: "encrypted-password"

server:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/hyperswitch-card-vault"

external:
  postgresql:
    enabled: true
    config:
      host: "prod-postgres.example.com"
      port: 5432
      username: "vault_user"
      password: "encrypted-password"
      database: "card_vault"
```

### Example 3: Production with HashiCorp Vault
```yaml
backend: vault

secrets:
  vault:
    token: "hvs.your-vault-token"

server:
  vault:
    url: "https://vault.example.com:8200"

# Enable TLS
secrets:
  tls:
    certificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
    private_key: |
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
```

## Key Generation

### Generate Master Key
```bash
cargo install --git https://github.com/juspay/hyperswitch-card-vault --root . && \
./bin/utils master-key && \
rm ./bin/utils && rmdir ./bin
```

### Generate Key Pairs
```bash
# Generate private keys
openssl genrsa -out locker-private-key.pem 2048
openssl genrsa -out tenant-private-key.pem 2048

# Generate public keys
openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem
openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
