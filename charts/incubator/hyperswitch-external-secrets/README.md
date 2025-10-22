# Hyperswitch External Secrets Chart

This chart deploys External Secrets resources for Hyperswitch applications, enabling integration with external secret managers like AWS Secrets Manager, HashiCorp Vault, etc.

## Prerequisites

### External Secrets Operator

The External Secrets Operator must be installed before deploying this chart:

```bash
# Add the External Secrets Operator repository
helm repo add external-secrets https://charts.external-secrets.io

# Install the External Secrets Operator
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets-system --create-namespace
```

## Installation

```bash
# Install the hyperswitch-external-secrets chart
helm install hyperswitch-ext-secrets ./charts/incubator/hyperswitch-external-secrets \
  -n hyperswitch --create-namespace
```

## Configuration

### Basic Configuration

The chart creates external secrets with a simple configuration structure:

```yaml
externalSecrets:
  secrets:
    # Main Hyperswitch application secrets
    hyperswitch-secrets:
      enabled: true
      secretName: "hyperswitch-secrets"
      namespace: ""  # Uses release namespace if empty
      remotePath: "hyperswitch/application"
      mappings:
        admin_api_key: "ROUTER__SECRETS__ADMIN_API_KEY"
        jwt_secret: "ROUTER__SECRETS__JWT_SECRET"
        # ... more mappings

    # Add custom secrets easily
    my-custom-secret:
      enabled: true
      secretName: "my-secret"
      namespace: "my-namespace"
      remotePath: "my/remote/path"
      mappings:
        my_key: "MY_SECRET_KEY"
```

### ClusterSecretStore Configuration

Configure your external secret manager:

```yaml
clusterSecretStore:
  provider: "aws"  # or "vault"

  aws:
    region: "us-west-2"
    service: "SecretsManager"
    auth:
      jwt:
        serviceAccountRef:
          name: ""  # Uses chart's service account if empty
          namespace: ""  # Uses release namespace if empty
```

## Integration with Hyperswitch App Chart

Use the created external secrets in the hyperswitch-app chart:

```yaml
# In hyperswitch-app values.yaml
configs:
  secrets:
    admin_api_key:
      _secretRef:
        name: hyperswitch-secrets
        key: ROUTER__SECRETS__ADMIN_API_KEY

externalPostgresql:
  primary:
    auth:
      password:
        _secretRef:
          name: external-postgresql
          key: primaryPassword
```

## Adding New Secrets

To add new external secrets, simply add entries to the `externalSecrets.secrets` map:

```yaml
externalSecrets:
  secrets:
    monitoring-tools:
      enabled: true
      secretName: "monitoring-credentials"
      namespace: "monitoring"
      remotePath: "hyperswitch/monitoring"
      mappings:
        grafana_password: "GRAFANA_ADMIN_PASSWORD"
        prometheus_token: "PROMETHEUS_API_TOKEN"
```

No template modifications required!