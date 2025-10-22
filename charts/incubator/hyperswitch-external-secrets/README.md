# Hyperswitch External Secrets Chart

This Helm chart manages Hyperswitch application secrets using the [External Secrets Operator (ESO)](https://external-secrets.io/). It creates `ExternalSecret` resources that fetch secrets from external secret stores (AWS Secrets Manager, HashiCorp Vault, etc.) and create Kubernetes secrets that can be consumed by the Hyperswitch application.

## Prerequisites

- Kubernetes cluster with External Secrets Operator installed
- External secret store (AWS Secrets Manager, HashiCorp Vault, etc.)
- Proper RBAC/authentication configured for accessing the external secret store

## Integration with Hyperswitch-App Chart

This chart is designed to work seamlessly with the `hyperswitch-app` chart. It creates secrets that align with the `_secretRef` patterns supported by the hyperswitch-app chart's helper functions.

### Architecture

```
┌─────────────────────────┐    ┌────────────────────────┐    ┌──────────────────────┐
│   External Secret       │    │  External Secrets      │    │   Hyperswitch App    │
│   Store (AWS/Vault)     │◄───┤  Operator              │◄───┤   Chart              │
│                         │    │                        │    │                      │
│  • Application secrets  │    │  • ClusterSecretStore  │    │  • Uses _secretRef   │
│  • Database passwords   │    │  • ExternalSecret      │    │  • References K8s    │
│  • API keys             │    │  • Creates K8s secrets │    │    secrets           │
└─────────────────────────┘    └────────────────────────┘    └──────────────────────┘
```

### Integration Steps

#### 1. Deploy External Secrets Chart

```bash
# Install external-secrets chart first
helm install hyperswitch-eso ./charts/incubator/hyperswitch-external-secrets \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::ACCOUNT:role/hyperswitch-eso-role" \
  --set clusterSecretStore.aws.region="us-west-2"
```

#### 2. Configure Hyperswitch-App to Use External Secrets

Instead of using `_secret` patterns in hyperswitch-app values.yaml:

```yaml
# OLD: Using local secrets (not recommended for production)
configs:
  secrets:
    admin_api_key:
      _secret: test_admin
```

Use `_secretRef` patterns that reference the secrets created by this chart:

```yaml
# NEW: Using external secrets (recommended for production)
configs:
  secrets:
    admin_api_key:
      _secretRef:
        name: hyperswitch-secrets    # Created by external-secrets chart
        key: ROUTER__SECRETS__ADMIN_API_KEY
```

#### 3. Deploy Hyperswitch-App Chart

```bash
helm install hyperswitch ./charts/incubator/hyperswitch-app \
  -f values-with-external-secrets.yaml
```

## Configuration

### ClusterSecretStore Configuration

The chart creates a `ClusterSecretStore` that defines how to connect to your external secret store:

```yaml
clusterSecretStore:
  provider: "aws"  # or "vault", "azure", "gcp"
  aws:
    region: "us-west-2"
    service: "SecretsManager"
    auth:
      jwt:
        serviceAccountRef:
          name: "hyperswitch-eso-sa"
          namespace: "hyperswitch"
```

### Secret Mappings

The `secretMappings` section defines which secrets to fetch from the external store and how to map them to Kubernetes secret keys:

```yaml
secretMappings:
  hyperswitchSecrets:
    # External store key -> Kubernetes secret key
    admin_api_key: "ROUTER__SECRETS__ADMIN_API_KEY"
    jwt_secret: "ROUTER__SECRETS__JWT_SECRET"
    # ... more mappings
```

### Supported Secret Categories

This chart fetches all secrets required by the Hyperswitch application:

- **Core Application Secrets**: admin_api_key, jwt_secret, master_enc_key
- **API Keys**: hash_key, forex_api_key, pm_auth_key
- **Apple Pay Certificates**: merchant_cert, merchant_cert_key, ppc, ppc_key
- **Connector Secrets**: paypal_client_id, paypal_client_secret
- **Email Configuration**: smtp_username, smtp_password
- **Encryption Keys**: vault_encryption_key, rust_locker_encryption_key
- **Database Passwords**: analytics_clickhouse_password, analytics_sqlx_password
- **And many more...**

## Examples

### AWS Secrets Manager Setup

1. Create secrets in AWS Secrets Manager:
```json
{
  "admin_api_key": "your-admin-key",
  "jwt_secret": "your-jwt-secret",
  "master_enc_key": "your-encryption-key"
}
```

2. Configure the chart:
```yaml
clusterSecretStore:
  provider: "aws"
  aws:
    region: "us-west-2"
    service: "SecretsManager"

externalSecrets:
  hyperswitchSecrets:
    remotePath: "hyperswitch/application"
```

### Vault Setup

1. Store secrets in Vault:
```bash
vault kv put secret/hyperswitch/application \
  admin_api_key="your-admin-key" \
  jwt_secret="your-jwt-secret"
```

2. Configure the chart:
```yaml
clusterSecretStore:
  provider: "vault"
  vault:
    server: "https://vault.example.com"
    path: "hyperswitch"
    auth:
      jwt:
        role: "hyperswitch-role"
```

## Security Considerations

1. **RBAC**: Ensure proper RBAC is configured for the External Secrets Operator service account
2. **IAM/Auth**: Configure appropriate IAM roles (AWS) or authentication methods (Vault)
3. **Network Policies**: Restrict network access to external secret stores
4. **Secret Rotation**: Configure automatic secret rotation in your external secret store
5. **Monitoring**: Monitor ExternalSecret resource status and sync health

## Troubleshooting

### Check ExternalSecret Status
```bash
kubectl get externalsecret hyperswitch-secrets -o yaml
kubectl describe externalsecret hyperswitch-secrets
```

### Check ClusterSecretStore Status
```bash
kubectl get clustersecretstore hyperswitch-cluster-secret-store -o yaml
```

### Verify Created Secrets
```bash
kubectl get secrets hyperswitch-secrets
kubectl describe secret hyperswitch-secrets
```

### Common Issues

1. **Authentication Failures**: Check IAM roles/policies or Vault authentication
2. **Network Connectivity**: Verify External Secrets Operator can reach the external store
3. **Secret Path Issues**: Ensure the `remotePath` matches your external store structure
4. **RBAC Issues**: Verify the service account has proper permissions

## Values Reference

See [values.yaml](./values.yaml) for complete configuration options and [values-integration-example.yaml](./values-integration-example.yaml) for integration examples.