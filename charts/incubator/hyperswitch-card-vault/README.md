# hyperswitch-card-vault

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for creating Hyperswitch Card Vault

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 13.2.27 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
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
| postgresql.enabled | bool | `true` |  |
| postgresql.global.postgresql.auth.architecture | string | `"standalone"` |  |
| postgresql.global.postgresql.auth.database | string | `"locker-db"` |  |
| postgresql.global.postgresql.auth.password | string | `"V2tkS1ptTkhSbnBqZDI4OUNnPT0K"` |  |
| postgresql.global.postgresql.auth.username | string | `"db_user"` |  |
| postgresql.nameOverride | string | `"locker-db"` |  |
| postgresql.primary.name | string | `""` |  |
| postgresql.primary.resources.requests.cpu | string | `"100m"` |  |
| postgresql.primary.tolerations | list | `[]` |  |
| server.affinity | object | `{}` |  |
| server.annotations | object | `{}` |  |
| server.extra.env | object | `{}` |  |
| server.image | string | `"docker.juspay.io/juspaydotin/hyperswitch-card-vault:v0.4.0"` |  |
| server.pod.annotations | object | `{}` |  |
| server.secrets.locker_private_key | string | "-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----" | To create this key pairs, follow the instructions provided here: </br> # Generating the private keys <pre>openssl genrsa -out locker-private-key.pem 2048</pre> <pre>openssl genrsa -out tenant-private-key.pem 2048</pre> # Generating the public keys </br> <pre>openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem</pre> <pre>openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem</pre> The private key for the locker from locker-private-key.pem |
| server.secrets.master_key | string | "master_key" | Optionally, you can run </br> <pre>cargo install --git https://github.com/juspay/hyperswitch-card-vault --root . && ./bin/utils master-key && rm ./bin/utils && rmdir ./bin</pre> |
| server.secrets.tenant_public_key | string | "-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----" | The public key for the tenant from tenant-public-key.pem |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
