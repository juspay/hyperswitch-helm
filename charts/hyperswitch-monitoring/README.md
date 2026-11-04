# hyperswitch-monitoring

Monitoring stack for Hyperswitch including VictoriaMetrics, Loki, Alloy, and Grafana

![Version: 0.2.1](https://img.shields.io/badge/Version-0.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

## Overview

The Hyperswitch Monitoring stack provides comprehensive observability for your Hyperswitch deployment. It includes:

- **VictoriaMetrics**: Metrics collection and storage (`vmsingle` by default; set `victoria-metrics-k8s-stack.vmcluster.enabled: true` for a sharded cluster instead)
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation system
- **Grafana Alloy**: Log collection agent
- **OpenTelemetry Collector**: Traces and metrics collection

As of 0.2.0, this replaced kube-prometheus-stack and Promtail (see CHANGELOG.md).

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
| https://grafana.github.io/helm-charts | alloy | 1.4.0 |
| https://grafana.github.io/helm-charts | loki | 6.46.0 |
| https://open-telemetry.github.io/opentelemetry-helm-charts | opentelemetry-collector | 0.139.0 |
| https://victoriametrics.github.io/helm-charts | victoria-metrics-k8s-stack | 0.71.1 |

## Values
<h3>Other Values</h3>
<table>

<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>

<tbody><tr>
    <td><div><a href="./values.yaml#L269">alloy.alloy.configMap.content</a></div></td>
    <td><div><code>"discovery.kubernetes \"pods\" {\n  role = \"pod\"\n}\n\ndiscovery.relabel \"pods\" {\n  targets = discovery.kubernetes.pods.targets\n  rule {\n    source_labels = [\"__meta_kubernetes_pod_container_name\"]\n    target_label  = \"container\"\n  }\n  rule {\n    source_labels = [\"__meta_kubernetes_namespace\"]\n    target_label  = \"namespace\"\n  }\n  rule {\n    source_labels = [\"__meta_kubernetes_pod_name\"]\n    target_label  = \"pod\"\n  }\n}\n\nloki.source.kubernetes \"pods\" {\n  targets    = discovery.relabel.pods.output\n  forward_to = [loki.write.default.receiver]\n}\n\nloki.write \"default\" {\n  endpoint {\n    url = \"http://loki:3100/loki/api/v1/push\"\n  }\n}\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L305">alloy.alloy.resources.limits.cpu</a></div></td>
    <td><div><code>"250m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L306">alloy.alloy.resources.limits.memory</a></div></td>
    <td><div><code>"256Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L302">alloy.alloy.resources.requests.cpu</a></div></td>
    <td><div><code>"50m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L303">alloy.alloy.resources.requests.memory</a></div></td>
    <td><div><code>"128Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L266">alloy.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L9">global.image.registry</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L6">global.imageRegistry</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L13">global.labels.stack</a></div></td>
    <td><div><code>"hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L11">global.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L326">grafana.ingress.annotations."alb.ingress.kubernetes.io/backend-protocol"</a></div></td>
    <td><div><code>"HTTP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L327">grafana.ingress.annotations."alb.ingress.kubernetes.io/backend-protocol-version"</a></div></td>
    <td><div><code>"HTTP1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L328">grafana.ingress.annotations."alb.ingress.kubernetes.io/group.name"</a></div></td>
    <td><div><code>"hyperswitch-monitoring-alb-ingress-group"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L329">grafana.ingress.annotations."alb.ingress.kubernetes.io/ip-address-type"</a></div></td>
    <td><div><code>"ipv4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L330">grafana.ingress.annotations."alb.ingress.kubernetes.io/listen-ports"</a></div></td>
    <td><div><code>"[{\"HTTP\": 80}]"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L331">grafana.ingress.annotations."alb.ingress.kubernetes.io/load-balancer-name"</a></div></td>
    <td><div><code>"hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L332">grafana.ingress.annotations."alb.ingress.kubernetes.io/scheme"</a></div></td>
    <td><div><code>"internet-facing"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L333">grafana.ingress.annotations."alb.ingress.kubernetes.io/security-groups"</a></div></td>
    <td><div><code>"loadbalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L334">grafana.ingress.annotations."alb.ingress.kubernetes.io/tags"</a></div></td>
    <td><div><code>"stack=hyperswitch-monitoring"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L335">grafana.ingress.annotations."alb.ingress.kubernetes.io/target-type"</a></div></td>
    <td><div><code>"ip"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L323">grafana.ingress.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L337">grafana.ingress.hosts[0].host</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L339">grafana.ingress.hosts[0].paths[0].path</a></div></td>
    <td><div><code>"/"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L340">grafana.ingress.hosts[0].paths[0].pathType</a></div></td>
    <td><div><code>"Prefix"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L324">grafana.ingress.ingressClassName</a></div></td>
    <td><div><code>"alb"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L341">grafana.ingress.tls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L345">loadBalancer.targetSecurityGroup</a></div></td>
    <td><div><code>"loadbalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L76">loki.backend.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L82">loki.chunksCache.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L53">loki.deploymentMode</a></div></td>
    <td><div><code>"SingleBinary"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L17">loki.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L18">loki.fullnameOverride</a></div></td>
    <td><div><code>"loki"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L78">loki.gateway.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L21">loki.global.image.registry</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L25">loki.loki.auth_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L32">loki.loki.commonConfig.replication_factor</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L50">loki.loki.limits_config.ingestion_burst_size_mb</a></div></td>
    <td><div><code>20</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L49">loki.loki.limits_config.ingestion_rate_mb</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L48">loki.loki.limits_config.retention_period</a></div></td>
    <td><div><code>"168h"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L39">loki.loki.schemaConfig.configs[0].from</a></div></td>
    <td><div><code>"2024-01-01"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L45">loki.loki.schemaConfig.configs[0].index.period</a></div></td>
    <td><div><code>"24h"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L44">loki.loki.schemaConfig.configs[0].index.prefix</a></div></td>
    <td><div><code>"index_"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L41">loki.loki.schemaConfig.configs[0].object_store</a></div></td>
    <td><div><code>"filesystem"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L42">loki.loki.schemaConfig.configs[0].schema</a></div></td>
    <td><div><code>"v13"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L40">loki.loki.schemaConfig.configs[0].store</a></div></td>
    <td><div><code>"tsdb"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L29">loki.loki.server.grpc_listen_port</a></div></td>
    <td><div><code>9095</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L28">loki.loki.server.http_listen_port</a></div></td>
    <td><div><code>3100</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L35">loki.loki.storage.type</a></div></td>
    <td><div><code>"filesystem"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L72">loki.read.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L84">loki.resultsCache.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L60">loki.singleBinary.persistence.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L61">loki.singleBinary.persistence.size</a></div></td>
    <td><div><code>"10Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L56">loki.singleBinary.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L67">loki.singleBinary.resources.limits.cpu</a></div></td>
    <td><div><code>"500m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L68">loki.singleBinary.resources.limits.memory</a></div></td>
    <td><div><code>"512Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L64">loki.singleBinary.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L65">loki.singleBinary.resources.requests.memory</a></div></td>
    <td><div><code>"256Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L58">loki.singleBinary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L74">loki.write.replicas</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L163">opentelemetry-collector.affinity</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L126">opentelemetry-collector.alternateConfig.exporters.debug.verbosity</a></div></td>
    <td><div><code>"detailed"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L128">opentelemetry-collector.alternateConfig.exporters.otlphttp.metrics_endpoint</a></div></td>
    <td><div><code>"http://vmagent-victoria-metrics:8429/opentelemetry/v1/metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L130">opentelemetry-collector.alternateConfig.exporters.otlphttp.tls.insecure</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L134">opentelemetry-collector.alternateConfig.extensions.health_check.endpoint</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:13133"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L109">opentelemetry-collector.alternateConfig.processors.batch</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L111">opentelemetry-collector.alternateConfig.processors.memory_limiter.check_interval</a></div></td>
    <td><div><code>"5s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L112">opentelemetry-collector.alternateConfig.processors.memory_limiter.limit_percentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L113">opentelemetry-collector.alternateConfig.processors.memory_limiter.spike_limit_percentage</a></div></td>
    <td><div><code>25</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L117">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].context</a></div></td>
    <td><div><code>"datapoint"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L119">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[0]</a></div></td>
    <td><div><code>"set(attributes[\"source_namespace\"], resource.attributes[\"k8s.namespace.name\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L120">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[1]</a></div></td>
    <td><div><code>"set(attributes[\"source_pod\"], resource.attributes[\"k8s.pod.name\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L121">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[2]</a></div></td>
    <td><div><code>"set(attributes[\"source_app\"], resource.attributes[\"app\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L122">opentelemetry-collector.alternateConfig.processors.transform.metric_statements[0].statements[3]</a></div></td>
    <td><div><code>"set(attributes[\"source_version\"], resource.attributes[\"version\"])"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L106">opentelemetry-collector.alternateConfig.receivers.otlp.protocols.grpc.endpoint</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:4317"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L145">opentelemetry-collector.alternateConfig.service.extensions[0]</a></div></td>
    <td><div><code>"health_check"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L155">opentelemetry-collector.alternateConfig.service.pipelines.metrics.exporters[0]</a></div></td>
    <td><div><code>"otlphttp"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L151">opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[0]</a></div></td>
    <td><div><code>"memory_limiter"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L152">opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[1]</a></div></td>
    <td><div><code>"transform"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L153">opentelemetry-collector.alternateConfig.service.pipelines.metrics.processors[2]</a></div></td>
    <td><div><code>"batch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L149">opentelemetry-collector.alternateConfig.service.pipelines.metrics.receivers[0]</a></div></td>
    <td><div><code>"otlp"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L140">opentelemetry-collector.alternateConfig.service.telemetry.logs.encoding</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L139">opentelemetry-collector.alternateConfig.service.telemetry.logs.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L143">opentelemetry-collector.alternateConfig.service.telemetry.metrics.address</a></div></td>
    <td><div><code>"${env:MY_POD_IP}:8888"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L142">opentelemetry-collector.alternateConfig.service.telemetry.metrics.level</a></div></td>
    <td><div><code>"detailed"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L88">opentelemetry-collector.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L158">opentelemetry-collector.image.repository</a></div></td>
    <td><div><code>"otel/opentelemetry-collector-contrib"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L159">opentelemetry-collector.image.tag</a></div></td>
    <td><div><code>"0.139.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L90">opentelemetry-collector.mode</a></div></td>
    <td><div><code>"deployment"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L93">opentelemetry-collector.namespaceOverride</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L161">opentelemetry-collector.nodeSelector</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L178">opentelemetry-collector.ports.hs-metrics.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L182">opentelemetry-collector.ports.jaeger-compact.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L186">opentelemetry-collector.ports.jaeger-grpc.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L184">opentelemetry-collector.ports.jaeger-thrift.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L174">opentelemetry-collector.ports.otel-metrics.containerPort</a></div></td>
    <td><div><code>8888</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L173">opentelemetry-collector.ports.otel-metrics.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L176">opentelemetry-collector.ports.otel-metrics.protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L175">opentelemetry-collector.ports.otel-metrics.servicePort</a></div></td>
    <td><div><code>8888</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L180">opentelemetry-collector.ports.otlp-http.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L171">opentelemetry-collector.ports.otlp.appProtocol</a></div></td>
    <td><div><code>"grpc"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L168">opentelemetry-collector.ports.otlp.containerPort</a></div></td>
    <td><div><code>4317</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L167">opentelemetry-collector.ports.otlp.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L170">opentelemetry-collector.ports.otlp.protocol</a></div></td>
    <td><div><code>"TCP"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L169">opentelemetry-collector.ports.otlp.servicePort</a></div></td>
    <td><div><code>4317</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L188">opentelemetry-collector.ports.zipkin.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L97">opentelemetry-collector.presets.kubernetesAttributes.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L99">opentelemetry-collector.presets.kubernetesAttributes.extractAllPodAnnotations</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L98">opentelemetry-collector.presets.kubernetesAttributes.extractAllPodLabels</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L200">opentelemetry-collector.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L194">opentelemetry-collector.resources.limits.cpu</a></div></td>
    <td><div><code>"1500m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L195">opentelemetry-collector.resources.limits.memory</a></div></td>
    <td><div><code>"4Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L197">opentelemetry-collector.resources.requests.cpu</a></div></td>
    <td><div><code>"250m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L198">opentelemetry-collector.resources.requests.memory</a></div></td>
    <td><div><code>"512Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L203">opentelemetry-collector.serviceMonitor.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L206">opentelemetry-collector.serviceMonitor.metricsEndpoints[0].honorLabels</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L207">opentelemetry-collector.serviceMonitor.metricsEndpoints[0].interval</a></div></td>
    <td><div><code>"30s"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L208">opentelemetry-collector.serviceMonitor.metricsEndpoints[0].path</a></div></td>
    <td><div><code>"/metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L205">opentelemetry-collector.serviceMonitor.metricsEndpoints[0].port</a></div></td>
    <td><div><code>"otel-metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L162">opentelemetry-collector.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L312">postgresql.external</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L318">postgresql.primary.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L314">postgresql.primary.host</a></div></td>
    <td><div><code>"postgresql"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L317">postgresql.primary.password</a></div></td>
    <td><div><code>"ZGJwYXNzd29yZDEx"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L315">postgresql.primary.port</a></div></td>
    <td><div><code>5432</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L316">postgresql.primary.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L224">victoria-metrics-k8s-stack.alertmanager.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L211">victoria-metrics-k8s-stack.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L212">victoria-metrics-k8s-stack.fullnameOverride</a></div></td>
    <td><div><code>"victoria-metrics"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L221">victoria-metrics-k8s-stack.grafana.additionalDataSources</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L216">victoria-metrics-k8s-stack.grafana.adminPassword</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L215">victoria-metrics-k8s-stack.grafana.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L218">victoria-metrics-k8s-stack.grafana.image.tag</a></div></td>
    <td><div><code>"10.0.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L220">victoria-metrics-k8s-stack.grafana.plugins[0]</a></div></td>
    <td><div><code>"volkovlabs-variable-panel"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L228">victoria-metrics-k8s-stack.kube-state-metrics.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L230">victoria-metrics-k8s-stack.prometheus-node-exporter.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L254">victoria-metrics-k8s-stack.vmagent.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L256">victoria-metrics-k8s-stack.vmagent.spec.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L262">victoria-metrics-k8s-stack.vmagent.spec.resources.limits.cpu</a></div></td>
    <td><div><code>"250m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L263">victoria-metrics-k8s-stack.vmagent.spec.resources.limits.memory</a></div></td>
    <td><div><code>"512Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L259">victoria-metrics-k8s-stack.vmagent.spec.resources.requests.cpu</a></div></td>
    <td><div><code>"50m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L260">victoria-metrics-k8s-stack.vmagent.spec.resources.requests.memory</a></div></td>
    <td><div><code>"128Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L226">victoria-metrics-k8s-stack.vmalert.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L251">victoria-metrics-k8s-stack.vmcluster.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L233">victoria-metrics-k8s-stack.vmsingle.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L247">victoria-metrics-k8s-stack.vmsingle.spec.resources.limits.cpu</a></div></td>
    <td><div><code>"1000m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L248">victoria-metrics-k8s-stack.vmsingle.spec.resources.limits.memory</a></div></td>
    <td><div><code>"2Gi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L244">victoria-metrics-k8s-stack.vmsingle.spec.resources.requests.cpu</a></div></td>
    <td><div><code>"250m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L245">victoria-metrics-k8s-stack.vmsingle.spec.resources.requests.memory</a></div></td>
    <td><div><code>"512Mi"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L235">victoria-metrics-k8s-stack.vmsingle.spec.retentionPeriod</a></div></td>
    <td><div><code>"14"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L241">victoria-metrics-k8s-stack.vmsingle.spec.storage.volumeClaimTemplate.spec.resources.requests.storage</a></div></td>
    <td><div><code>"20Gi"</code></div></td>
    <td></td>
  </tr>
</tbody>
</table>

