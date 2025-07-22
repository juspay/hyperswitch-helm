# hyperswitch-ucs

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

A Helm chart for Hyperswitch UCS Service

## TL;DR

```bash
helm repo add hyperswitch https://juspay.github.io/hyperswitch-helm/
helm install hyperswitch-ucs hyperswitch/hyperswitch-ucs
```

## Introduction

This chart deploys the Hyperswitch UCS (Unified Connector Service) on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `hyperswitch-ucs`:

```bash
helm install hyperswitch-ucs ./charts/incubator/hyperswitch-ucs -n hyperswitch --create-namespace
```

## Uninstalling the Chart

To uninstall/delete the `hyperswitch-ucs` deployment:

```bash
helm uninstall hyperswitch-ucs -n hyperswitch
```

## Configuration

The following table lists the configurable parameters of the hyperswitch-ucs chart and their default values.

## Values

### Connector Service

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling configuration |
| autoscaling.enabled | bool | `false` | Enable autoscaling |
| autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| fullnameOverride | string | `""` | Override the full name of the chart |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/juspay/connector-service","tag":"main-b1487cb"}` | Container image configuration |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/juspay/connector-service"` | Docker image repository |
| image.tag | string | `"main-b1487cb"` | Image tag to use |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"hyperswitch-ucs.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress configuration |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress resource |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress |
| ingress.enabled | bool | `false` | Enable ingress controller resource |
| ingress.hosts | list | `[{"host":"hyperswitch-ucs.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | An array with hostname(s) to be covered with the ingress record |
| ingress.tls | list | `[]` | TLS configuration for hostname(s) to be covered with this ingress record |
| livenessProbe | object | `{"failureThreshold":3,"grpc":{"port":8000,"service":"grpc.health.v1.Health"},"initialDelaySeconds":90,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":10}` | Liveness probe configuration |
| livenessProbe.failureThreshold | int | `3` | Number of failures before pod is restarted |
| livenessProbe.grpc | object | `{"port":8000,"service":"grpc.health.v1.Health"}` | gRPC health check configuration |
| livenessProbe.grpc.port | int | `8000` | gRPC port for health check |
| livenessProbe.grpc.service | string | `"grpc.health.v1.Health"` | gRPC service name for health check |
| livenessProbe.initialDelaySeconds | int | `90` | Initial delay before probe starts |
| livenessProbe.periodSeconds | int | `30` | How often to perform the probe |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| livenessProbe.timeoutSeconds | int | `10` | Number of seconds after which the probe times out |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pod |
| podSecurityContext | object | `{}` | Pod security context |
| readinessProbe | object | `{"failureThreshold":5,"grpc":{"port":8000,"service":"grpc.health.v1.Health"},"initialDelaySeconds":30,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":5}` | Readiness probe configuration |
| readinessProbe.failureThreshold | int | `5` | Number of failures before pod is marked unready |
| readinessProbe.grpc | object | `{"port":8000,"service":"grpc.health.v1.Health"}` | gRPC health check configuration |
| readinessProbe.grpc.port | int | `8000` | gRPC port for health check |
| readinessProbe.grpc.service | string | `"grpc.health.v1.Health"` | gRPC service name for health check |
| readinessProbe.initialDelaySeconds | int | `30` | Initial delay before probe starts |
| readinessProbe.periodSeconds | int | `30` | How often to perform the probe |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| readinessProbe.timeoutSeconds | int | `5` | Number of seconds after which the probe times out |
| replicaCount | int | `1` | Number of replicas for the UCS deployment |
| resources | object | `{"limits":{"cpu":"1000m","memory":"1000Mi"},"requests":{"cpu":"400m","memory":"400Mi"}}` | Resource limits and requests for the UCS containers |
| resources.limits | object | `{"cpu":"1000m","memory":"1000Mi"}` | Resource limits |
| resources.limits.cpu | string | `"1000m"` | CPU limit |
| resources.limits.memory | string | `"1000Mi"` | Memory limit |
| resources.requests | object | `{"cpu":"400m","memory":"400Mi"}` | Resource requests |
| resources.requests.cpu | string | `"400m"` | CPU request |
| resources.requests.memory | string | `"400Mi"` | Memory request |
| securityContext | object | `{}` | Container security context |
| service | object | `{"grpc":{"port":8000,"targetPort":8000},"metrics":{"port":8080,"targetPort":8080},"type":"ClusterIP"}` | Service configuration |
| service.grpc | object | `{"port":8000,"targetPort":8000}` | gRPC service configuration |
| service.grpc.port | int | `8000` | gRPC service port |
| service.grpc.targetPort | int | `8000` | gRPC container port |
| service.metrics | object | `{"port":8080,"targetPort":8080}` | Metrics service configuration |
| service.metrics.port | int | `8080` | Metrics service port |
| service.metrics.targetPort | int | `8080` | Metrics container port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |

### Connector Service Configurations

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.connectors.adyen.base_url | string | `"https://{{merchant_endpoint_prefix}}-checkout-live.adyenpayments.com/checkout/"` | Adyen base URL |
| config.connectors.adyen.dispute_base_url | string | `"https://{{merchant_endpoint_prefix}}-ca-live.adyen.com/"` | Adyen dispute base URL |
| config.connectors.authorizedotnet.base_url | string | `"https://api.authorize.net/xml/v1/request.api/"` | Authorize.net base URL |
| config.connectors.checkout.base_url | string | `"https://api.checkout.com/"` | Checkout base URL |
| config.connectors.elavon.base_url | string | `"https://api.convergepay.com/VirtualMerchant/"` | Elavon base URL |
| config.connectors.fiserv.base_url | string | `"https://cert.api.fiservapps.com/"` | Fiserv base URL |
| config.connectors.razorpay.base_url | string | `"https://api.razorpay.com/"` | Razorpay base URL |
| config.connectors.razorpayv2.base_url | string | `"https://api.razorpay.com/"` | Razorpay v2 base URL |
| config.connectors.xendit.base_url | string | `"https://api.xendit.co/"` | Xendit base URL |
| config.log.console.enabled | bool | `true` | Enable console logging |
| config.log.console.level | string | `"DEBUG"` | Log level (DEBUG, INFO, WARN, ERROR) |
| config.log.console.log_format | string | `"json"` | Log format (json, text) |
| config.metrics.host | string | `"0.0.0.0"` | Metrics server host address |
| config.metrics.port | int | `8080` | Metrics server port |
| config.proxy.bypass_proxy_urls | list | `["localhost","local"]` | URLs to bypass proxy |
| config.proxy.http_url | string | `"http_proxy"` | HTTP proxy URL |
| config.proxy.https_url | string | `"https_proxy"` | HTTPS proxy URL |
| config.proxy.idle_pool_connection_timeout | int | `90` | Idle pool connection timeout |
| config.server.host | string | `"0.0.0.0"` | Server host address |
| config.server.port | int | `8000` | Server port |
| config.server.type | string | `"grpc"` | Server type |

### Example Configuration

#### Running without proxy (for local development)

```yaml
# values-local.yaml
env:
  - name: CS__PROXY__HTTPS_URL
    value: ""
  - name: CS__PROXY__HTTP_URL
    value: ""
  - name: CS__PROXY__BYPASS_PROXY_URLS
    value: ""
```

```bash
helm install hyperswitch-ucs ./charts/incubator/hyperswitch-ucs -f values-local.yaml -n hyperswitch
```

#### Running with custom resource limits

```yaml
# values-production.yaml
replicaCount: 3

resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 1000m
    memory: 1Gi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

## Service Details

The chart deploys two services:
- **gRPC Service** (port 8000): Main gRPC service endpoint
- **Metrics Service** (port 8080): Prometheus metrics endpoint

### Health Checks

The deployment includes both liveness and readiness probes using gRPC health checks:
- Liveness probe: Ensures the container is running
- Readiness probe: Ensures the service is ready to accept traffic

### Monitoring

Prometheus metrics are exposed on port 8080 at `/metrics` endpoint. Metrics include:
- `GRPC_SERVER_REQUESTS_TOTAL`: Total number of gRPC requests
- `GRPC_SERVER_REQUESTS_SUCCESSFUL`: Number of successful requests
- `GRPC_SERVER_REQUEST_LATENCY`: Request latency histogram

## Troubleshooting

### Check pod status
```bash
kubectl get pods -l app.kubernetes.io/name=hyperswitch-ucs -n hyperswitch
kubectl describe pod -l app.kubernetes.io/name=hyperswitch-ucs -n hyperswitch
```

### Check logs
```bash
kubectl logs -l app.kubernetes.io/name=hyperswitch-ucs -n hyperswitch
```

### Test metrics endpoint
```bash
kubectl port-forward svc/hyperswitch-ucs 8080:8080 -n hyperswitch
curl http://localhost:8080/metrics
```

### Test gRPC health endpoint
```bash
kubectl port-forward svc/hyperswitch-ucs 8000:8000 -n hyperswitch
grpcurl -plaintext localhost:8000 grpc.health.v1.Health/Check
```

