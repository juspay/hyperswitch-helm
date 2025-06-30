# hyperswitch-keymanager

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.8](https://img.shields.io/badge/AppVersion-0.1.8-informational?style=flat-square)

A Helm chart for deploying Hyperswitch Keymanager

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

The keymanager supports multi-tenant deployments:
```yaml
multitenancy:
  tenants:
    public:
      cache_prefix: "public"
      schema: "public"
    global:
      cache_prefix: "global"
      schema: "global"
```

### TLS/mTLS Configuration

To enable TLS/mTLS for the keymanager service:
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

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.enabled | bool | `false` | Enable autoscaling |
| backend | string | `"local"` | Backend selection: aws, vault, or local |
| external.postgresql.config.database | string | `"encryption_db"` | External PostgreSQL database name |
| external.postgresql.config.host | string | `"localhost"` | External PostgreSQL host |
| external.postgresql.config.password | string | `"db_pass"` | External PostgreSQL password |
| external.postgresql.config.port | int | `5432` | External PostgreSQL port |
| external.postgresql.config.username | string | `"db_user"` | External PostgreSQL username |
| external.postgresql.enable_ssl | bool | `false` | Enable SSL for external PostgreSQL |
| external.postgresql.enabled | bool | `false` | Enable external PostgreSQL |
| global.affinity | object | `{}` | Global node affinity |
| global.annotations | object | `{}` | Global annotations |
| global.image | string | `"docker.juspay.io/juspaydotin/hyperswitch-encryption-service:v0.1.8"` | Global image |
| initDB.checkPGisUp.image | string | `"postgres:16-alpine3.19"` | Image for PostgreSQL readiness check |
| initDB.checkPGisUp.maxAttempt | int | `30` | Maximum attempts for PostgreSQL readiness |
| initDB.enable | bool | `true` | Enable database migrations |
| initDB.migration.image | string | `"christophwurst/diesel-cli:latest"` | Image for database migrations |
| multitenancy.tenants.global.cache_prefix | string | `"global"` | Cache prefix for global tenant |
| multitenancy.tenants.global.schema | string | `"global"` | Database schema for global tenant |
| multitenancy.tenants.public.cache_prefix | string | `"public"` | Cache prefix for public tenant |
| multitenancy.tenants.public.schema | string | `"public"` | Database schema for public tenant |
| postgresql.architecture | string | `"standalone"` | PostgreSQL architecture |
| postgresql.auth.database | string | `"encryption_db"` | PostgreSQL database name |
| postgresql.auth.password | string | `"db_pass"` | PostgreSQL password |
| postgresql.auth.username | string | `"db_user"` | PostgreSQL username |
| postgresql.enabled | bool | `true` | Enable internal PostgreSQL |
| postgresql.nameOverride | string | `"keymanager-db"` | PostgreSQL name override |
| postgresql.primary.name | string | `""` | PostgreSQL primary name |
| postgresql.primary.resources.requests.cpu | string | `"100m"` | PostgreSQL CPU request |
| replicaCount | int | `1` | Number of replicas |
| secrets.access_token | string | `"secret123"` | Access token for API authentication |
| secrets.aws.key_id | string | `"sample_key_id"` | AWS KMS key ID (required when backend is 'aws') |
| secrets.aws.region | string | `"us-east-1"` | AWS KMS region |
| secrets.database.password | string | `"db_pass"` | Database password |
| secrets.database.root_ca | string | `""` | PostgreSQL SSL root certificate |
| secrets.hash_context | string | `"keymanager:hyperswitch"` | Hash context for key derivation |
| secrets.master_key | string | `"6d761d32f1b14ef34cf016d726b29b02b5cfce92a8959f1bfb65995c8100925e"` | Master encryption key (required when backend is 'local') |
| secrets.tls.ca | string | `"sample_cert"` | TLS CA certificate |
| secrets.tls.cert | string | `"sample_cert"` | TLS certificate |
| secrets.tls.key | string | `"sample_cert"` | TLS private key |
| secrets.vault.token | string | `""` | HashiCorp Vault token (required when backend is 'vault') |
| server.annotations | object | `{}` | Server annotations |
| server.image | string | `"docker.juspay.io/juspaydotin/hyperswitch-encryption-service:v0.1.8"` | Server image |

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
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/hyperswitch-keymanager"

external:
  postgresql:
    enabled: true
    config:
      host: "prod-postgres.example.com"
      port: 5432
      username: "keymanager_user"
      password: "encrypted-password"
      database: "keymanager_db"

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
      cache_prefix: "public"
      schema: "public"
    tenant1:
      cache_prefix: "tenant1"
      schema: "tenant1"
    tenant2:
      cache_prefix: "tenant2"
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

The Hyperswitch Key Manager can be used as an external key management service for the Card Vault:

```yaml
# In card-vault values.yaml
server:
  externalKeyManager:
    url: "https://keymanager-service:5000"

secrets:
  external_key_manager:
    cert: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
