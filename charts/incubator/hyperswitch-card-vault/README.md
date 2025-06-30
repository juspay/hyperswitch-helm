# hyperswitch-card-vault

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

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

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backend | string | `"local"` | Backend selection for secrets management: local, aws, or vault |
| external.postgresql.config.database | string | `nil` | External PostgreSQL database name |
| external.postgresql.config.host | string | `nil` | External PostgreSQL host |
| external.postgresql.config.password | string | `nil` | External PostgreSQL password |
| external.postgresql.config.port | string | `nil` | External PostgreSQL port |
| external.postgresql.config.username | string | `nil` | External PostgreSQL username |
| external.postgresql.enabled | bool | `false` | Enable external PostgreSQL |
| global.affinity | object | `{}` | Global node affinity |
| global.annotations | object | `{}` | Global annotations |
| global.tolerations | list | `[]` | Global tolerations |
| initDB.checkPGisUp.image | string | `"postgres:16-alpine3.19"` | Image for PostgreSQL readiness check |
| initDB.checkPGisUp.maxAttempt | int | `30` | Maximum attempts for PostgreSQL readiness |
| initDB.enable | bool | `true` | Enable database migrations |
| initDB.migration.image | string | `"christophwurst/diesel-cli:latest"` | Image for database migrations |
| postgresql.architecture | string | `"standalone"` | PostgreSQL architecture |
| postgresql.auth.database | string | `"locker-db"` | PostgreSQL database name |
| postgresql.auth.password | string | `"dummyPassword"` | PostgreSQL password |
| postgresql.auth.username | string | `"db_user"` | PostgreSQL username |
| postgresql.enabled | bool | `true` | Enable internal PostgreSQL |
| postgresql.nameOverride | string | `"locker-db"` | PostgreSQL name override |
| postgresql.primary.name | string | `""` | PostgreSQL primary name |
| postgresql.primary.resources.requests.cpu | string | `"100m"` | PostgreSQL CPU request |
| postgresql.primary.tolerations | list | `[]` | PostgreSQL tolerations |
| secrets.api_client.identity | string | `""` | API client mTLS identity certificate |
| secrets.aws.key_id | string | `""` | AWS KMS key ID (required when backend is 'aws') |
| secrets.aws.region | string | `"us-east-1"` | AWS KMS region |
| secrets.database.password | string | `"dummyPassword"` | Database password |
| secrets.external_key_manager.cert | string | `""` | External key manager mTLS certificate |
| secrets.locker_private_key | string | See values.yaml | Locker private key for JWE/JWS |
| secrets.tls.certificate | string | `""` | TLS certificate for the server |
| secrets.tls.private_key | string | `""` | TLS private key for the server |
| secrets.vault.token | string | `""` | HashiCorp Vault token (required when backend is 'vault') |
| server.affinity | object | `{}` | Server node affinity |
| server.annotations | object | `{}` | Server annotations |
| server.externalKeyManager.url | string | `"http://localhost:5000"` | External key manager URL |
| server.extra.env | object | `{}` | Extra environment variables |
| server.host | string | `"0.0.0.0"` | Server host |
| server.image | string | `"docker.juspay.io/juspaydotin/hyperswitch-card-vault:v0.6.5-dev"` | Server image |
| server.pod.annotations | object | `{}` | Pod annotations |
| server.port | string | `"8080"` | Server port |
| server.vault.url | string | `"http://127.0.0.1:8200"` | HashiCorp Vault URL |
| server.version | string | `"v0.6.5"` | Server version |
| tenant_secrets.public.master_key | string | See values.yaml | Master encryption key for tenant |
| tenant_secrets.public.public_key | string | See values.yaml | Tenant's public key |
| tenant_secrets.public.schema | string | `"public"` | Database schema for tenant |
| vaultKeysJob.checkVaultService.host | string | `""` | Vault service host for readiness check |
| vaultKeysJob.checkVaultService.image | string | `"curlimages/curl:8.7.1"` | Image for vault readiness check |
| vaultKeysJob.checkVaultService.maxAttempt | int | `30` | Maximum attempts for vault readiness |
| vaultKeysJob.checkVaultService.port | int | `80` | Vault service port |
| vaultKeysJob.enabled | bool | `true` | Enable vault keys initialization job |
| vaultKeysJob.keys.key1 | string | `"3c82773a6621feee3d5e0ce96654bf1f"` | First vault key |
| vaultKeysJob.keys.key2 | string | `"7de95dbbd5d020e6b2a44847b8942bf5"` | Second vault key |

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
