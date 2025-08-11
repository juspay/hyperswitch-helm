# hyperswitch-istio

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Overview

This Helm chart packages:
- Istio base CRDs (istio-base)
- Istio control plane (istiod)
- Istio ingress gateway
- Hyperswitch-specific Istio configurations (Gateway, VirtualService, DestinationRule)
- ALB Ingress configuration for AWS environments

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- kubectl configured to access your cluster

## Installation

### Local Development

For local development with default Docker Hub images:

```bash
# Add Istio repository (if not already added)
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# Update chart dependencies
helm dependency update ./hyperswitch-istio

# Install the chart
helm install hyperswitch-istio ./hyperswitch-istio \
  --namespace istio-system \
  --create-namespace
```

### Production Deployment (with Private ECR)

For production deployments using private ECR repositories:

```bash
# Update dependencies
helm dependency update ./hyperswitch-istio

# Install with custom values
helm install hyperswitch-istio ./hyperswitch-istio \
  --namespace istio-system \
  --create-namespace \
  --set istiod.global.hub="123456789.dkr.ecr.us-east-1.amazonaws.com/istio" \
  --set istiod.global.tag="1.25.0" \
  --set istiod.pilot.nodeSelector.node-type=memory-optimized \
  --set istio-gateway.global.hub="123456789.dkr.ecr.us-east-1.amazonaws.com/istio" \
  --set istio-gateway.global.tag="1.25.0" \
  --set istio-gateway.nodeSelector.node-type=memory-optimized
```

**Note**: Make sure your ECR repository contains the required Istio images:
- `istio/pilot:1.25.0` (for istiod)
- `istio/proxyv2:1.25.0` (for gateway and sidecars)

### Using a Custom Values File

Create a `custom-values.yaml` file:

```yaml
# Production overrides
istiod:
  global:
    hub: "123456789.dkr.ecr.us-east-1.amazonaws.com/istio"
    tag: "1.25.0"
  pilot:
    nodeSelector:
      node-type: memory-optimized

istio-gateway:
  global:
    hub: "123456789.dkr.ecr.us-east-1.amazonaws.com/istio"
    tag: "1.25.0"
  nodeSelector:
    node-type: memory-optimized

# ALB Ingress annotations
ingress:
  annotations:
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/security-groups: sg-xxxxxxxxx
    alb.ingress.kubernetes.io/subnets: subnet-xxx,subnet-yyy
```

Then install:

```bash
helm install hyperswitch-istio ./hyperswitch-istio \
  --namespace istio-system \
  --create-namespace \
  -f custom-values.yaml
```

## Uninstallation

To uninstall the chart:

```bash
helm uninstall hyperswitch-istio -n istio-system
```

Note: This will remove all Istio components. If you have other applications using Istio, consider carefully before uninstalling.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://istio-release.storage.googleapis.com/charts | istio-base(base) | 1.25.0 |
| https://istio-release.storage.googleapis.com/charts | istio-gateway(gateway) | 1.25.0 |
| https://istio-release.storage.googleapis.com/charts | istiod | 1.25.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| hyperswitchControlCenter.version | string | `"v1o37o1"` |  |
| hyperswitchServer.version | string | `"v1o114o0"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `"alb"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.hosts.paths[0].name | string | `"istio-ingressgateway"` |  |
| ingress.hosts.paths[0].path | string | `"/"` |  |
| ingress.hosts.paths[0].pathType | string | `"Prefix"` |  |
| ingress.hosts.paths[0].port | int | `80` |  |
| ingress.hosts.paths[1].name | string | `"istio-ingressgateway"` |  |
| ingress.hosts.paths[1].path | string | `"/healthz/ready"` |  |
| ingress.hosts.paths[1].pathType | string | `"Prefix"` |  |
| ingress.hosts.paths[1].port | int | `15021` |  |
| ingress.tls | list | `[]` |  |
| istio-base.defaultRevision | string | `"default"` |  |
| istio-base.enabled | bool | `true` |  |
| istio-gateway.enabled | bool | `true` |  |
| istio-gateway.global.hub | string | `"docker.io/istio"` |  |
| istio-gateway.global.tag | string | `"1.25.0"` |  |
| istio-gateway.name | string | `"istio-ingressgateway"` |  |
| istio-gateway.nodeSelector | object | `{}` |  |
| istio-gateway.service.type | string | `"ClusterIP"` |  |
| istiod.enabled | bool | `true` |  |
| istiod.global.hub | string | `"docker.io/istio"` |  |
| istiod.global.tag | string | `"1.25.0"` |  |
| istiod.pilot.nodeSelector | object | `{}` |  |
| livenessProbe.httpGet.path | string | `"/"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| namespace | string | `"hyperswitch"` |  |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| replicaCount | int | `1` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |

## Troubleshooting

### Check Istio Installation

```bash
# Check if all Istio components are running
kubectl get pods -n istio-system

# Check CRDs
kubectl get crd | grep istio

# Check services
kubectl get svc -n istio-system
```

### Verify Gateway Configuration

```bash
# Check gateway
kubectl get gateway -n istio-system

# Check virtual services
kubectl get virtualservice -A

# Check destination rules
kubectl get destinationrule -A
```

### Debug Ingress Issues

```bash
# Check ingress
kubectl get ingress -n istio-system

# Describe ingress for events
kubectl describe ingress hyperswitch-istio-app-alb-ingress -n istio-system
```

