# hyperswitch-card-vault

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

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

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backend | string | `"local"` |  |
| external.postgresql.config.database | string | `nil` |  |
| external.postgresql.config.host | string | `nil` |  |
| external.postgresql.config.password | string | `nil` |  |
| external.postgresql.config.port | string | `nil` |  |
| external.postgresql.config.username | string | `nil` |  |
| external.postgresql.enabled | bool | `false` |  |
| global.affinity | object | `{}` |  |
| global.annotations | object | `{}` |  |
| global.tolerations | list | `[]` |  |
| initDB.checkPGisUp.image | string | `"postgres:16-alpine3.19"` |  |
| initDB.checkPGisUp.maxAttempt | int | `30` |  |
| initDB.enable | bool | `true` |  |
| initDB.migration.image | string | `"christophwurst/diesel-cli:latest"` |  |
| postgresql.architecture | string | `"standalone"` |  |
| postgresql.auth.database | string | `"locker-db"` |  |
| postgresql.auth.password | string | `"dummyPassword"` |  |
| postgresql.auth.username | string | `"db_user"` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.nameOverride | string | `"locker-db"` |  |
| postgresql.primary.name | string | `""` |  |
| postgresql.primary.resources.requests.cpu | string | `"100m"` |  |
| postgresql.primary.tolerations | list | `[]` |  |
| secrets.api_client.identity | string | `""` |  |
| secrets.aws.key_id | string | `""` |  |
| secrets.aws.region | string | `"us-east-1"` |  |
| secrets.database.password | string | `"dummyPassword"` |  |
| secrets.external_key_manager.cert | string | `""` |  |
| secrets.locker_private_key | string | "-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----" | To create this key pairs, follow the instructions provided here: </br> # Generating the private keys <pre>openssl genrsa -out locker-private-key.pem 2048</pre> <pre>openssl genrsa -out tenant-private-key.pem 2048</pre> # Generating the public keys </br> <pre>openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem</pre> <pre>openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem</pre> The private key for the locker from locker-private-key.pem |
| secrets.tls.certificate | string | `""` |  |
| secrets.tls.private_key | string | `""` |  |
| secrets.vault.token | string | `""` |  |
| server.affinity | object | `{}` |  |
| server.annotations | object | `{}` |  |
| server.apiClient.identity | string | `""` |  |
| server.awsKms.keyId | string | `""` |  |
| server.awsKms.region | string | `""` |  |
| server.externalKeyManager.cert | string | `""` |  |
| server.externalKeyManager.url | string | `"http://localhost:5000"` |  |
| server.extra.env | object | `{}` |  |
| server.host | string | `"0.0.0.0"` |  |
| server.image | string | `"docker.juspay.io/juspaydotin/hyperswitch-card-vault:v0.6.5-dev"` |  |
| server.pod.annotations | object | `{}` |  |
| server.port | string | `"8080"` |  |
| server.vault.url | string | `"http://127.0.0.1:8200"` |  |
| server.version | string | `"v0.6.5"` |  |
| tenant_secrets.public.master_key | string | `"8283d68fdbd89a78aef9bed8285ed1cd9310012f660eefbad865f20a3f3dd9498f06147da6a7d9b84677cafca95024990b3d2296fbafc55e10dd76df"` |  |
| tenant_secrets.public.public_key | string | "-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----" | The public key for the tenant from tenant_secrets-public-public_key.pem |
| tenant_secrets.public.schema | string | `"public"` |  |
| vaultKeysJob.checkVaultService.host | string | `""` |  |
| vaultKeysJob.checkVaultService.image | string | `"curlimages/curl:8.7.1"` |  |
| vaultKeysJob.checkVaultService.maxAttempt | int | `30` |  |
| vaultKeysJob.checkVaultService.port | int | `80` |  |
| vaultKeysJob.enabled | bool | `true` |  |
| vaultKeysJob.keys.key1 | string | `"3c82773a6621feee3d5e0ce96654bf1f"` |  |
| vaultKeysJob.keys.key2 | string | `"7de95dbbd5d020e6b2a44847b8942bf5"` |  |

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
