# hyperswitch-control-center

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.37.4](https://img.shields.io/badge/AppVersion-v1.37.4-informational?style=flat-square)

A dashboard for Hyperswitch Service

## Deploy Control Center on Kubernetes using Helm

This chart deploys the Hyperswitch Control Center dashboard as a standalone service.

### Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- Running Hyperswitch Router service (for API communication)

## Installation

### Step 1 - Add Helm Repository

```bash
helm repo add hyperswitch https://juspay.github.io/hyperswitch-helm
helm repo update
```

### Step 2 - Create Namespace (Optional)

```bash
kubectl create namespace hyperswitch
```

### Step 3 - Configure Dependencies

Update the values.yaml to point to your Hyperswitch Router and SDK endpoints:

```yaml
dependencies:
  router:
    host: "http://your-hyperswitch-router:8080"
  sdk:
    host: "http://your-hyperswitch-sdk:9050"
```

### Step 4 - Install Control Center

```bash
helm install control-center hyperswitch/hyperswitch-control-center -n hyperswitch
```

## Configuration

### Router Connection

The Control Center requires connection to a Hyperswitch Router instance:

```yaml
dependencies:
  router:
    host: "http://hyperswitch-router.hyperswitch.svc.cluster.local:8080"
```

### Feature Flags

Enable or disable Control Center features:

```yaml
config:
  default:
    features:
      email: "true"
      branding: "false"
      analytics: "true"
      # ... other features
```

### Access Control

Configure ingress for external access:

```yaml
ingress:
  enabled: true
  hosts:
    - host: control-center.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
```

### Istio Configuration

For Istio service mesh integration:

```yaml
istio:
  enabled: true
  virtualService:
    enabled: true
    hosts:
      - control-center.yourdomain.com
    gateways:
      - istio-system/gateway
    http:
      - name: "control-center-routes"
        match:
          - uri:
              prefix: /
```

## Post-Deployment Verification

After deployment, verify the Control Center is working:

### Health Check
- Access the Control Center dashboard
- Verify connection to Router API

### Functionality Check
- Sign up/Sign in functionality
- Create API keys
- Configure payment processors

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| config.default.endpoints.agreement_url | string | `"https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"` |  |
| config.default.endpoints.agreement_version | string | `"1.0.0"` |  |
| config.default.endpoints.dss_certificate_url | string | `"https://app.hyperswitch.io/certificates/PCI_DSS_v4-0_AOC_Juspay_2024.pdf"` |  |
| config.default.endpoints.favicon_url | string | `""` |  |
| config.default.endpoints.hypersense_url | string | `""` |  |
| config.default.endpoints.logo_url | string | `""` |  |
| config.default.endpoints.mixpanel_token | string | `"dd4da7f62941557e716fbc0a19f9cc7e"` |  |
| config.default.endpoints.recon_iframe_url | string | `""` |  |
| config.default.features.authentication_analytics | string | `"false"` |  |
| config.default.features.branding | string | `"false"` |  |
| config.default.features.compliance_certificate | string | `"true"` |  |
| config.default.features.configure_pmts | string | `"true"` |  |
| config.default.features.custom_webhook_headers | string | `"false"` |  |
| config.default.features.dev_alt_payment_methods | bool | `false` |  |
| config.default.features.dev_click_to_pay | string | `"true"` |  |
| config.default.features.dev_debit_routing | bool | `false` |  |
| config.default.features.dev_hypersense_v2_product | bool | `false` |  |
| config.default.features.dev_intelligent_routing_v2 | bool | `false` |  |
| config.default.features.dev_modularity_v2 | bool | `false` |  |
| config.default.features.dev_recon_v2_product | bool | `false` |  |
| config.default.features.dev_recovery_v2_product | bool | `false` |  |
| config.default.features.dev_vault_v2_product | bool | `false` |  |
| config.default.features.dev_webhooks | bool | `false` |  |
| config.default.features.dispute_analytics | string | `"false"` |  |
| config.default.features.dispute_evidence_upload | string | `"false"` |  |
| config.default.features.down_time | bool | `false` |  |
| config.default.features.email | string | `"true"` |  |
| config.default.features.feedback | string | `"false"` |  |
| config.default.features.force_cookies | bool | `false` |  |
| config.default.features.frm | string | `"true"` |  |
| config.default.features.generate_report | string | `"true"` |  |
| config.default.features.global_search | string | `"true"` |  |
| config.default.features.global_search_filters | bool | `false` |  |
| config.default.features.granularity | bool | `false` |  |
| config.default.features.is_live_mode | string | `"false"` |  |
| config.default.features.live_users_counter | string | `"false"` |  |
| config.default.features.maintainence_alert | string | `""` |  |
| config.default.features.mixpanel | string | `"false"` |  |
| config.default.features.new_analytics | string | `"true"` |  |
| config.default.features.new_analytics_filters | string | `"true"` |  |
| config.default.features.new_analytics_refunds | string | `"true"` |  |
| config.default.features.new_analytics_smart_retries | string | `"true"` |  |
| config.default.features.payout | string | `"true"` |  |
| config.default.features.performance_monitor | string | `"true"` |  |
| config.default.features.pm_authentication_processor | string | `"true"` |  |
| config.default.features.quick_start | string | `"true"` |  |
| config.default.features.recon | string | `"true"` |  |
| config.default.features.recon_v2 | bool | `false` |  |
| config.default.features.sample_data | string | `"true"` |  |
| config.default.features.surcharge | string | `"true"` |  |
| config.default.features.system_metrics | string | `"false"` |  |
| config.default.features.tax_processors | string | `"true"` |  |
| config.default.features.tenant_user | string | `"true"` |  |
| config.default.features.test_live_toggle | string | `"false"` |  |
| config.default.features.test_processors | string | `"true"` |  |
| config.default.features.threeds_authenticator | string | `"true"` |  |
| config.default.features.totp | string | `"false"` |  |
| config.default.features.transaction_view | bool | `true` |  |
| config.default.features.user_journey_analytics | string | `"false"` |  |
| config.default.merchant_config.new_analytics.merchant_ids | list | `[]` |  |
| config.default.merchant_config.new_analytics.org_ids | list | `[]` |  |
| config.default.merchant_config.new_analytics.profile_ids | list | `[]` |  |
| config.default.theme.primary_color | string | `"#006DF9"` |  |
| config.default.theme.primary_hover_color | string | `"#005ED6"` |  |
| config.default.theme.sidebar_border_color | string | `"#ECEFF3"` |  |
| config.default.theme.sidebar_color | string | `"#242F48"` |  |
| config.default.theme.sidebar_primary | string | `"#FCFCFD"` |  |
| config.default.theme.sidebar_primary_text_color | string | `"#1C6DEA"` |  |
| config.default.theme.sidebar_secondary | string | `"#FFFFFF"` |  |
| config.default.theme.sidebar_secondary_text_color | string | `"#525866"` |  |
| config.mixpanelToken | string | `"dd4da7f62941557e716fbc0a19f9cc7e"` |  |
| dependencies.clickhouse.enabled | bool | `false` |  |
| dependencies.router.host | string | `"http://localhost:8080"` |  |
| dependencies.sdk.fullUrlOverride | string | `""` |  |
| dependencies.sdk.host | string | `"http://localhost:9050"` |  |
| dependencies.sdk.subversion | string | `"v1"` |  |
| dependencies.sdk.version | string | `"0.126.0"` |  |
| extraEnvVars | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| global.imageRegistry | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `"docker.juspay.io"` |  |
| image.repository | string | `"juspaydotin/hyperswitch-control-center"` |  |
| image.tag | string | `"v1.37.4"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
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
| progressDeadlineSeconds | int | `600` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| replicaCount | int | `1` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"100Mi"` |  |
| securityContext.privileged | bool | `false` |  |
| service.port | int | `9000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| strategy.rollingUpdate.maxSurge | int | `1` |  |
| strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| terminationGracePeriodSeconds | int | `30` |  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |

## Examples

### Example 1: Basic Installation

```yaml
dependencies:
  router:
    host: "http://hyperswitch-router:8080"

config:
  default:
    features:
      email: "true"
      analytics: "true"
```

### Example 2: Production with Ingress

```yaml
dependencies:
  router:
    host: "http://hyperswitch-router.hyperswitch.svc.cluster.local:8080"

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: control-center.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: control-center-tls
      hosts:
        - control-center.yourdomain.com

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Example 3: With Istio Service Mesh

```yaml
dependencies:
  router:
    host: "http://hyperswitch-router.hyperswitch.svc.cluster.local:8080"

istio:
  enabled: true
  virtualService:
    enabled: true
    hosts:
      - control-center.yourdomain.com
    gateways:
      - istio-system/gateway
    http:
      - name: "control-center-routes"
        match:
          - uri:
              prefix: /
        timeout: 30s
        retries:
          attempts: 3
          perTryTimeout: 10s
```

## Support

For issues and questions:
- Documentation: https://docs.hyperswitch.io
- GitHub Issues: https://github.com/juspay/hyperswitch-helm/issues
- Community: Join our community discussions

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)