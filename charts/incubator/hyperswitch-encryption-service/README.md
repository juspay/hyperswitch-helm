# hyperswitch-encryption-service

![Version: 0.1.7](https://img.shields.io/badge/Version-0.1.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.1.12](https://img.shields.io/badge/AppVersion-v0.1.12-informational?style=flat-square)

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
      cache_prefix: "public"
      schema: "public"
    global:
      cache_prefix: "global"
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

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `3` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| configs.certs.root_ca | string | `"sample_cert"` |  |
| configs.certs.tls_cert | string | `"sample_cert"` |  |
| configs.certs.tls_key | string | `"sample_cert"` |  |
| configs.database.min_idle | int | `2` |  |
| configs.database.pool_size | int | `5` |  |
| configs.database.root_ca | string | `""` |  |
| configs.log.log_format | string | `"json"` |  |
| configs.log.log_level | string | `"debug"` |  |
| configs.metrics_server.host | string | `"0.0.0.0"` |  |
| configs.metrics_server.port | int | `6128` |  |
| configs.multitenancy.tenants.global.cache_prefix | string | `"global"` |  |
| configs.multitenancy.tenants.global.schema | string | `"global"` |  |
| configs.multitenancy.tenants.public.cache_prefix | string | `"public"` |  |
| configs.multitenancy.tenants.public.schema | string | `"public"` |  |
| configs.pool_config.pool | int | `2` |  |
| configs.secrets.access_token._secret | string | `"secret123"` |  |
| configs.secrets.hash_context._secret | string | `"encryption-service:hyperswitch"` |  |
| configs.secrets.master_key._secret | string | `"6d761d32f1b14ef34cf016d726b29b02b5cfce92a8959f1bfb65995c8100925e"` |  |
| configs.server.host | string | `"0.0.0.0"` |  |
| configs.server.port | int | `5000` |  |
| disableInternalSecrets | bool | `false` |  |
| externalPostgresql.config.database | string | `"encryption_db"` |  |
| externalPostgresql.config.host | string | `"localhost"` |  |
| externalPostgresql.config.password | string | `"db_pass"` |  |
| externalPostgresql.config.plainpassword | string | `"db_pass"` |  |
| externalPostgresql.config.port | int | `5432` |  |
| externalPostgresql.config.username | string | `"db_user"` |  |
| externalPostgresql.enable_ssl | bool | `false` |  |
| externalPostgresql.enabled | bool | `false` |  |
| externalSecretsOperator.enabled | bool | `false` |  |
| externalSecretsOperator.externalSecrets.secrets[0].creationPolicy | string | `"Owner"` |  |
| externalSecretsOperator.externalSecrets.secrets[0].dataFrom[0].extract.conversionStrategy | string | `"Default"` |  |
| externalSecretsOperator.externalSecrets.secrets[0].dataFrom[0].extract.decodingStrategy | string | `"None"` |  |
| externalSecretsOperator.externalSecrets.secrets[0].dataFrom[0].extract.key | string | `"hyperswitch/encryption-service/secrets"` |  |
| externalSecretsOperator.externalSecrets.secrets[0].dataFrom[0].extract.metadataPolicy | string | `"None"` |  |
| externalSecretsOperator.externalSecrets.secrets[0].name | string | `"encryption-service-secrets"` |  |
| externalSecretsOperator.externalSecrets.secrets[0].refreshInterval | string | `"1h"` |  |
| externalSecretsOperator.externalSecrets.secrets[0].targetName | string | `"encryption-service-secrets"` |  |
| externalSecretsOperator.secretStore.name | string | `"encryption-service-secret-store"` |  |
| externalSecretsOperator.secretStore.provider.aws.auth.jwt.serviceAccountRef.name | string | `"encryption-service-eso-sa"` |  |
| externalSecretsOperator.secretStore.provider.aws.region | string | `"us-west-2"` |  |
| externalSecretsOperator.secretStore.provider.aws.service | string | `"SecretsManager"` |  |
| externalSecretsOperator.serviceAccount.annotations | object | `{}` |  |
| externalSecretsOperator.serviceAccount.create | bool | `true` |  |
| externalSecretsOperator.serviceAccount.extraLabels | object | `{}` |  |
| externalSecretsOperator.serviceAccount.name | string | `""` |  |
| fullnameOverride | string | `""` |  |
| global.affinity | object | `{}` |  |
| global.annotations | object | `{}` |  |
| global.imageRegistry | string | `nil` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `"docker.juspay.io"` |  |
| image.repository | string | `"juspaydotin/hyperswitch-encryption-service"` |  |
| image.tag | string | `"v0.1.11"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"hyperswitch-encryption-service.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| initDB.checkPGisUp.image | string | `"postgres:16-alpine3.19"` |  |
| initDB.checkPGisUp.imageRegistry | string | `"docker.io"` |  |
| initDB.checkPGisUp.maxAttempt | int | `30` |  |
| initDB.enable | bool | `true` |  |
| initDB.migration.image | string | `"christophwurst/diesel-cli:latest"` |  |
| initDB.migration.imageRegistry | string | `"docker.io"` |  |
| istio.destinationRule.enabled | bool | `false` |  |
| istio.destinationRule.trafficPolicy | object | `{}` |  |
| istio.enabled | bool | `false` |  |
| istio.virtualService.enabled | bool | `false` |  |
| istio.virtualService.gateways | list | `[]` |  |
| istio.virtualService.hosts | list | `[]` |  |
| istio.virtualService.http | list | `[]` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgresql.architecture | string | `"standalone"` |  |
| postgresql.auth.database | string | `"encryption_db"` |  |
| postgresql.auth.password | string | `"db_pass"` |  |
| postgresql.auth.username | string | `"db_user"` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.image.repository | string | `"bitnamilegacy/postgresql"` |  |
| postgresql.nameOverride | string | `"encryption-service-db"` |  |
| postgresql.primary.name | string | `""` |  |
| postgresql.primary.resources.requests.cpu | string | `"100m"` |  |
| progressDeadlineSeconds | int | `600` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"1000m"` |  |
| resources.limits.memory | string | `"1Gi"` |  |
| resources.requests.cpu | string | `"400m"` |  |
| resources.requests.memory | string | `"400Mi"` |  |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.externalTrafficPolicy | string | `""` |  |
| service.internalTrafficPolicy | string | `"Cluster"` |  |
| service.loadBalancerClass | string | `""` |  |
| service.ports[0].name | string | `"https"` |  |
| service.ports[0].port | int | `443` |  |
| service.ports[0].protocol | string | `"TCP"` |  |
| service.ports[0].targetPort | int | `5000` |  |
| service.ports[1].name | string | `"metrics"` |  |
| service.ports[1].port | int | `6128` |  |
| service.ports[1].protocol | string | `"TCP"` |  |
| service.ports[1].targetPort | int | `6128` |  |
| service.sessionAffinity | string | `"None"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"encryption-service-role"` |  |
| serviceMonitor.basicAuth | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"15s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| serviceMonitor.metricRelabelings | list | `[]` |  |
| serviceMonitor.namespace | string | `""` |  |
| serviceMonitor.path | string | `"/metrics"` |  |
| serviceMonitor.portName | string | `"metrics"` |  |
| serviceMonitor.relabelings | list | `[]` |  |
| serviceMonitor.scheme | string | `"http"` |  |
| serviceMonitor.scrapeTimeout | string | `"30s"` |  |
| serviceMonitor.targetLabels | list | `[]` |  |
| serviceMonitor.tlsConfig | object | `{}` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| terminationGracePeriodSeconds | int | `30` |  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |

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
