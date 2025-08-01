# hyperswitch-monitoring

Monitoring stack for Hyperswitch including Prometheus, Loki, Promtail, and Grafana

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

## Overview

The Hyperswitch Monitoring stack provides comprehensive observability for your Hyperswitch deployment. It includes:

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation system
- **Promtail**: Log collection agent
- **OpenTelemetry Collector**: Traces and metrics collection

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for Prometheus and Loki storage)
- Recommended resources: 4 CPU cores and 8GB RAM

## Custom Dashboards

The monitoring stack includes two custom dashboards:

1. **Payments Dashboard** (`payments-dashboard.json`):
   - Payment success/failure rates
   - Payment processing latencies
   - Payment volume by processor
   - Error rate trends

2. **Pod Usage Dashboard** (`pod-usage-dashboard.json`):
   - CPU and memory usage per pod
   - Network I/O metrics
   - Pod restart counts
   - Resource limits vs actual usage

## Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://grafana.github.io/helm-charts | loki | 6.16.0 |
| https://grafana.github.io/helm-charts | promtail | 6.16.0 |
| https://open-telemetry.github.io/opentelemetry-helm-charts | opentelemetry-collector | 0.120.0 |
| https://prometheus-community.github.io/helm-charts | kube-prometheus-stack | 65.1.1 |

## Values
<h3>Other Values</h3>
<table>

<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>

<tbody><tr>
    <td><div><a href="./values.yaml#L8">global.labels.stack</a></div></td>
    <td><div><code>"hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L6">global.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L371">grafana.ingress.annotations."alb.ingress.kubernetes.io/backend-protocol"</a></div></td>
    <td><div><code>"HTTP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L372">grafana.ingress.annotations."alb.ingress.kubernetes.io/backend-protocol-version"</a></div></td>
    <td><div><code>"HTTP1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L373">grafana.ingress.annotations."alb.ingress.kubernetes.io/group.name"</a></div></td>
    <td><div><code>"hyperswitch-monitoring-alb-ingress-group"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L374">grafana.ingress.annotations."alb.ingress.kubernetes.io/ip-address-type"</a></div></td>
    <td><div><code>"ipv4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L375">grafana.ingress.annotations."alb.ingress.kubernetes.io/listen-ports"</a></div></td>
    <td><div><code>"[{\"HTTP\": 80}]"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L376">grafana.ingress.annotations."alb.ingress.kubernetes.io/load-balancer-name"</a></div></td>
    <td><div><code>"hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L377">grafana.ingress.annotations."alb.ingress.kubernetes.io/scheme"</a></div></td>
    <td><div><code>"internet-facing"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L378">grafana.ingress.annotations."alb.ingress.kubernetes.io/security-groups"</a></div></td>
    <td><div><code>"loadbalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L379">grafana.ingress.annotations."alb.ingress.kubernetes.io/tags"</a></div></td>
    <td><div><code>"stack=hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L380">grafana.ingress.annotations."alb.ingress.kubernetes.io/target-type"</a></div></td>
    <td><div><code>"ip"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L368">grafana.ingress.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L382">grafana.ingress.hosts[0].host</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L384">grafana.ingress.hosts[0].paths[0].path</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L385">grafana.ingress.hosts[0].paths[0].pathType</a></div></td>
    <td><div><code>"Prefix"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L369">grafana.ingress.ingressClassName</a></div></td>
    <td><div><code>"alb"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L386">grafana.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L23">kube-prometheus-stack.alertmanager.alertmanagerSpec.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L20">kube-prometheus-stack.alertmanager.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L12">kube-prometheus-stack.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L105">kube-prometheus-stack.grafana.additionalDataSources</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L88">kube-prometheus-stack.grafana.adminPassword</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L102">kube-prometheus-stack.grafana.defaultDatasourceEnabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L87">kube-prometheus-stack.grafana.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L95">kube-prometheus-stack.grafana.image.tag</a></div></td>
    <td><div><code>"10.0.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L99">kube-prometheus-stack.grafana.plugins[0]</a></div></td>
    <td><div><code>"volkovlabs-variable-panel"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L110">kube-prometheus-stack.grafana.prometheus.datasource.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L125">kube-prometheus-stack.grafana.sidecar.dashboards.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L126">kube-prometheus-stack.grafana.sidecar.dashboards.label</a></div></td>
    <td><div><code>"grafana_dashboard"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L127">kube-prometheus-stack.grafana.sidecar.dashboards.labelValue</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L132">kube-prometheus-stack.grafana.sidecar.dashboards.provider.allowUiUpdates</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L129">kube-prometheus-stack.grafana.sidecar.dashboards.searchNamespace</a></div></td>
    <td><div><code>"ALL"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L121">kube-prometheus-stack.grafana.sidecar.datasources.defaultDatasourceEnabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L115">kube-prometheus-stack.grafana.sidecar.datasources.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L116">kube-prometheus-stack.grafana.sidecar.datasources.label</a></div></td>
    <td><div><code>"grafana_datasource"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L117">kube-prometheus-stack.grafana.sidecar.datasources.labelValue</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L119">kube-prometheus-stack.grafana.sidecar.datasources.searchNamespace</a></div></td>
    <td><div><code>"{{ .Release.Namespace }}"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L123">kube-prometheus-stack.grafana.sidecar.datasources.skipTlsVerify</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L91">kube-prometheus-stack.grafana.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L27">kube-prometheus-stack.prometheus.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L61">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].job_name</a></div></td>
    <td><div><code>"kubernetes-pods"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L63">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].kubernetes_sd_configs[0].role</a></div></td>
    <td><div><code>"pod"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L66">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[0].action</a></div></td>
    <td><div><code>"keep"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L67">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[0].regex</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L65">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[0].source_labels[0]</a></div></td>
    <td><div><code>"__meta_kubernetes_pod_annotation_prometheus_io_scrape"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L69">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[1].action</a></div></td>
    <td><div><code>"replace"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L71">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[1].regex</a></div></td>
    <td><div><code>"(.+)"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L68">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[1].source_labels[0]</a></div></td>
    <td><div><code>"__meta_kubernetes_pod_annotation_prometheus_io_path"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L70">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[1].target_label</a></div></td>
    <td><div><code>"__metrics_path__"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L73">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].action</a></div></td>
    <td><div><code>"replace"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L75">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].regex</a></div></td>
    <td><div><code>"([^:]+)(?::\\d+)?;(\\d+)"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L76">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].replacement</a></div></td>
    <td><div><code>"$1:$2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L72">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].source_labels[0]</a></div></td>
    <td><div><code>"__address__"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L72">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].source_labels[1]</a></div></td>
    <td><div><code>"__meta_kubernetes_pod_annotation_prometheus_io_port"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L74">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[0].relabel_configs[2].target_label</a></div></td>
    <td><div><code>"__address__"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L78">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[1].job_name</a></div></td>
    <td><div><code>"kubernetes-nodes"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L80">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[1].kubernetes_sd_configs[0].role</a></div></td>
    <td><div><code>"node"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L82">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[1].relabel_configs[0].action</a></div></td>
    <td><div><code>"labelmap"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L83">kube-prometheus-stack.prometheus.prometheusSpec.additionalScrapeConfigs[1].relabel_configs[0].regex</a></div></td>
    <td><div><code>"__meta_kubernetes_node_label_(.+)"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L39">kube-prometheus-stack.prometheus.prometheusSpec.resources.limits.cpu</a></div></td>
    <td><div><code>"500m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L38">kube-prometheus-stack.prometheus.prometheusSpec.resources.limits.memory</a></div></td>
    <td><div><code>"1Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L36">kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.cpu</a></div></td>
    <td><div><code>"50m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L35">kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.memory</a></div></td>
    <td><div><code>"256Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L42">kube-prometheus-stack.prometheus.prometheusSpec.retention</a></div></td>
    <td><div><code>"30d"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L48">kube-prometheus-stack.prometheus.prometheusSpec.serviceMonitorNamespaceSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L45">kube-prometheus-stack.prometheus.prometheusSpec.serviceMonitorSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L54">kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]</a></div></td>
    <td><div><code>"ReadWriteOnce"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L57">kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage</a></div></td>
    <td><div><code>"50Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L30">kube-prometheus-stack.prometheus.prometheusSpec.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L17">kube-prometheus-stack.prometheusOperator.admissionWebhooks.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L390">loadBalancer.targetSecurityGroup</a></div></td>
    <td><div><code>"loadbalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L193">loki.backend.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L199">loki.chunksCache.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L170">loki.deploymentMode</a></div></td>
    <td><div><code>"SingleBinary"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L137">loki.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L138">loki.fullnameOverride</a></div></td>
    <td><div><code>"loki"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L195">loki.gateway.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L142">loki.loki.auth_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L149">loki.loki.commonConfig.replication_factor</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L167">loki.loki.limits_config.ingestion_burst_size_mb</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L166">loki.loki.limits_config.ingestion_rate_mb</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L165">loki.loki.limits_config.retention_period</a></div></td>
    <td><div><code>"168h"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L156">loki.loki.schemaConfig.configs[0].from</a></div></td>
    <td><div><code>"2024-01-01"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L162">loki.loki.schemaConfig.configs[0].index.period</a></div></td>
    <td><div><code>"24h"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L161">loki.loki.schemaConfig.configs[0].index.prefix</a></div></td>
    <td><div><code>"index_"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L158">loki.loki.schemaConfig.configs[0].object_store</a></div></td>
    <td><div><code>"filesystem"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L159">loki.loki.schemaConfig.configs[0].schema</a></div></td>
    <td><div><code>"v13"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L157">loki.loki.schemaConfig.configs[0].store</a></div></td>
    <td><div><code>"tsdb"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L146">loki.loki.server.grpc_listen_port</a></div></td>
    <td><div><code>9095</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L145">loki.loki.server.http_listen_port</a></div></td>
    <td><div><code>3100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L152">loki.loki.storage.type</a></div></td>
    <td><div><code>"filesystem"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L189">loki.read.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L201">loki.resultsCache.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L177">loki.singleBinary.persistence.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L178">loki.singleBinary.persistence.size</a></div></td>
    <td><div><code>"10Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L173">loki.singleBinary.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L184">loki.singleBinary.resources.limits.cpu</a></div></td>
    <td><div><code>"500m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L185">loki.singleBinary.resources.limits.memory</a></div></td>
    <td><div><code>"512Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L181">loki.singleBinary.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L182">loki.singleBinary.resources.requests.memory</a></div></td>
    <td><div><code>"256Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L175">loki.singleBinary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L191">loki.write.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L299">opentelemetry-collector.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L264">opentelemetry-collector.alternateConfig.exporters.debug.verbosity</a></div></td>
    <td><div><code>"detailed"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L266">opentelemetry-collector.alternateConfig.exporters.prometheus.endpoint</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:9898"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L270">opentelemetry-collector.alternateConfig.extensions.health_check.endpoint</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:13133"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L247">opentelemetry-collector.alternateConfig.processors.batch</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L249">opentelemetry-collector.alternateConfig.processors.memory_limiter.check_interval</a></div></td>
    <td><div><code>"5s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L250">opentelemetry-collector.alternateConfig.processors.memory_limiter.limit_percentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L251">opentelemetry-collector.alternateConfig.processors.memory_limiter.spike_limit_percentage</a></div></td>
    <td><div><code>25</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L255">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].context</a></div></td>
    <td><div><code>"datapoint"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L257">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[0]</a></div></td>
    <td><div><code>"set(attributes[\"source_namespace\"], resource.attributes[\"k8s.namespace.name\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L258">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[1]</a></div></td>
    <td><div><code>"set(attributes[\"source_pod\"], resource.attributes[\"k8s.pod.name\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L259">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[2]</a></div></td>
    <td><div><code>"set(attributes[\"source_app\"], resource.attributes[\"app\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L260">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[3]</a></div></td>
    <td><div><code>"set(attributes[\"source_version\"], resource.attributes[\"version\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L244">opentelemetry-collector.alternateConfig.receivers.otlp.protocols.grpc.endpoint</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:4317"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L281">opentelemetry-collector.alternateConfig.service.extensions[0]</a></div></td>
    <td><div><code>"health_check"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L291">opentelemetry-collector.alternateConfig.service.pipelines.metrics.exporters[0]</a></div></td>
    <td><div><code>"prometheus"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L287">opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[0]</a></div></td>
    <td><div><code>"memory_limiter"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L288">opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[1]</a></div></td>
    <td><div><code>"transform"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L289">opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[2]</a></div></td>
    <td><div><code>"batch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L285">opentelemetry-collector.alternateConfig.service.pipelines.metrics.receivers[0]</a></div></td>
    <td><div><code>"otlp"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L276">opentelemetry-collector.alternateConfig.service.telemetry.logs.encoding</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L275">opentelemetry-collector.alternateConfig.service.telemetry.logs.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L279">opentelemetry-collector.alternateConfig.service.telemetry.metrics.address</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:8888"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L278">opentelemetry-collector.alternateConfig.service.telemetry.metrics.level</a></div></td>
    <td><div><code>"detailed"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L226">opentelemetry-collector.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L294">opentelemetry-collector.image.repository</a></div></td>
    <td><div><code>"docker.io/otel/opentelemetry-collector-contrib"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L295">opentelemetry-collector.image.tag</a></div></td>
    <td><div><code>"0.122.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L228">opentelemetry-collector.mode</a></div></td>
    <td><div><code>"deployment"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L231">opentelemetry-collector.namespaceOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L297">opentelemetry-collector.nodeSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L315">opentelemetry-collector.ports.hs-metrics.containerPort</a></div></td>
    <td><div><code>9898</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L314">opentelemetry-collector.ports.hs-metrics.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L317">opentelemetry-collector.ports.hs-metrics.protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L316">opentelemetry-collector.ports.hs-metrics.servicePort</a></div></td>
    <td><div><code>9898</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L321">opentelemetry-collector.ports.jaeger-compact.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L325">opentelemetry-collector.ports.jaeger-grpc.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L323">opentelemetry-collector.ports.jaeger-thrift.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L310">opentelemetry-collector.ports.otel-metrics.containerPort</a></div></td>
    <td><div><code>8888</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L309">opentelemetry-collector.ports.otel-metrics.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L312">opentelemetry-collector.ports.otel-metrics.protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L311">opentelemetry-collector.ports.otel-metrics.servicePort</a></div></td>
    <td><div><code>8888</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L319">opentelemetry-collector.ports.otlp-http.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L307">opentelemetry-collector.ports.otlp.appProtocol</a></div></td>
    <td><div><code>"grpc"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L304">opentelemetry-collector.ports.otlp.containerPort</a></div></td>
    <td><div><code>4317</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L303">opentelemetry-collector.ports.otlp.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L306">opentelemetry-collector.ports.otlp.protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L305">opentelemetry-collector.ports.otlp.servicePort</a></div></td>
    <td><div><code>4317</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L327">opentelemetry-collector.ports.zipkin.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L235">opentelemetry-collector.presets.kubernetesAttributes.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L237">opentelemetry-collector.presets.kubernetesAttributes.extractAllPodAnnotations</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L236">opentelemetry-collector.presets.kubernetesAttributes.extractAllPodLabels</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L339">opentelemetry-collector.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L333">opentelemetry-collector.resources.limits.cpu</a></div></td>
    <td><div><code>"1500m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L334">opentelemetry-collector.resources.limits.memory</a></div></td>
    <td><div><code>"4Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L336">opentelemetry-collector.resources.requests.cpu</a></div></td>
    <td><div><code>"250m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L337">opentelemetry-collector.resources.requests.memory</a></div></td>
    <td><div><code>"512Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L342">opentelemetry-collector.serviceMonitor.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L345">opentelemetry-collector.serviceMonitor.metricsEndpoints[0].honorLabels</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L346">opentelemetry-collector.serviceMonitor.metricsEndpoints[0].interval</a></div></td>
    <td><div><code>"30s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L347">opentelemetry-collector.serviceMonitor.metricsEndpoints[0].path</a></div></td>
    <td><div><code>"/metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L344">opentelemetry-collector.serviceMonitor.metricsEndpoints[0].port</a></div></td>
    <td><div><code>"otel-metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L349">opentelemetry-collector.serviceMonitor.metricsEndpoints[1].honorLabels</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L350">opentelemetry-collector.serviceMonitor.metricsEndpoints[1].interval</a></div></td>
    <td><div><code>"15s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L351">opentelemetry-collector.serviceMonitor.metricsEndpoints[1].path</a></div></td>
    <td><div><code>"/metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L348">opentelemetry-collector.serviceMonitor.metricsEndpoints[1].port</a></div></td>
    <td><div><code>"hs-metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L298">opentelemetry-collector.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L357">postgresql.external</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L363">postgresql.primary.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L359">postgresql.primary.host</a></div></td>
    <td><div><code>"postgresql"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L362">postgresql.primary.password</a></div></td>
    <td><div><code>"ZGJwYXNzd29yZDEx"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L360">postgresql.primary.port</a></div></td>
    <td><div><code>5432</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L361">postgresql.primary.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L212">promtail.config.clients[0].url</a></div></td>
    <td><div><code>"http://loki:3100/loki/api/v1/push"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L220">promtail.config.snippets.extraRelabelConfigs[0].action</a></div></td>
    <td><div><code>"keep"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L221">promtail.config.snippets.extraRelabelConfigs[0].regex</a></div></td>
    <td><div><code>"hyperswitch-.*"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L222">promtail.config.snippets.extraRelabelConfigs[0].source_labels[0]</a></div></td>
    <td><div><code>"__meta_kubernetes_pod_label_app"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L216">promtail.config.snippets.pipelineStages[0].cri</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L205">promtail.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L208">promtail.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr>
</tbody>
</table>

