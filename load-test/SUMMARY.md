# Implementation Summary: Selective Service Deployment & PG vs YB Comparison

## Overview

This implementation enables two key capabilities for the hyperswitch-helm chart:

1. **Selective Service Deployment**: Ability to deploy only required services
2. **PostgreSQL vs YugabyteDB Performance Comparison**: Fair comparison framework

## Quick Start

### Deploy the Comparison Environment

**For systems with 16GB RAM:**
```bash
./load-test/deploy-comparison.sh --lightweight
```

**For systems with 24GB+ RAM:**
```bash
./load-test/deploy-comparison.sh
```

This single command deploys:
- 5 namespaces (shared, pg, yb, monitoring, loadtest)
- PostgreSQL instance (500m CPU/512MB RAM for lightweight, 1CPU/2GB for standard)
- YugabyteDB cluster with RF=3 (500m CPU/512MB per pod for lightweight, 1CPU/2GB for standard)
- Shared Redis infrastructure
- Monitoring stack with dual OTEL receivers
- Grafana comparison dashboard

**Resource Requirements:**
| Profile | PostgreSQL | YugabyteDB (6 pods) | Monitoring/App | Total |
|---------|------------|-------------------|----------------|-------|
| Standard | 1CPU/2GB | 6CPU/12GB | 1.5CPU/3GB | ~20GB |
| Lightweight | 500m/512MB | 3CPU/3GB | 1CPU/2GB | ~6GB |

**Create Kind cluster for 16GB systems:**
```bash
kind create cluster --config=load-test/kind-cluster-lite.yaml
```

### Access Dashboards

```bash
# Grafana
kubectl port-forward -n hyperswitch-monitoring svc/hyperswitch-monitoring-grafana 3000:80
# Open: http://localhost:3000 (admin/admin)

# Prometheus
kubectl port-forward -n hyperswitch-monitoring svc/prometheus-operated 9090:9090
# Open: http://localhost:9090
```

### Cleanup

```bash
./load-test/cleanup-comparison.sh
kind delete cluster --name hyperswitch-comparison
```

### View Help

```bash
./load-test/deploy-comparison.sh --help
```

## File Structure

```
hyperswitch-helm/
├── charts/incubator/yugabyte/           # New: YugabyteDB Helm chart
│   ├── Chart.yaml
│   ├── values.yaml                      # RF=3, 1CPU/2GB
│   ├── templates/
│   │   ├── _helpers.tpl
│   │   ├── statefulset-master.yaml      # 3 masters
│   │   ├── statefulset-tserver.yaml     # 3 tservers
│   │   ├── service-master.yaml
│   │   └── service-tserver.yaml
│   └── .helmignore
│
└── load-test/                           # Comparison configuration
    ├── hyperswitch-pg.values.yaml       # PG instance, OTEL :14317
    ├── hyperswitch-yb.values.yaml       # YB instance, OTEL :14318
    ├── hyperswitch-shared.values.yaml   # Redis only
    ├── hyperswitch-monitoring.values.yaml
    │                                   # Dual OTEL receivers
    ├── dashboards/
    │   └── pg-yb-comparison.json       # Grafana dashboard
    ├── deploy-comparison.sh            # Automated deployment
    ├── cleanup-comparison.sh           # Automated cleanup
    └── README-PG-YB-COMPARISON.md      # Full documentation
```

## Deployment Profiles

The comparison environment supports two deployment profiles:

### Standard Profile (24GB+ RAM)
- Full resource allocation for production-like testing
- PostgreSQL: 1CPU/2GB
- YugabyteDB: 1CPU/2GB per pod (6 pods total with RF=3)
- Monitoring: 1.5CPU/3GB (includes Loki for logs)
- Command: `./load-test/deploy-comparison.sh`

### Lightweight Profile (16GB RAM)
- Reduced resources for development/testing
- PostgreSQL: 500m CPU / 512MB RAM
- YugabyteDB: 500m CPU / 512MB RAM per pod (6 pods total with RF=3)
- Monitoring: 1CPU/2GB (Loki disabled)
- Command: `./load-test/deploy-comparison.sh --lightweight`

## Architecture Highlights

### Metric Differentiation Strategy

The OTEL Collector uses **dual receivers** on separate ports with processors:

```
hyperswitch-pg instance  --> OTEL Port 14317 --> processor adds source_app="router_pg"
                                                     |
                                                     v
                                                 Prometheus

hyperswitch-yb instance  --> OTEL Port 14318 --> processor adds source_app="router_yb"
                                                     |
                                                     v
                                                 Prometheus
```

All metrics from both instances are labeled with `source_app`:
- `router_pg` for PostgreSQL instance
- `router_yb` for YugabyteDB instance

### Fair Comparison Conditions

| Condition | Configuration |
|-----------|---------------|
| Database CPU | 1 core (both) |
| Database Memory | 2GB (both) |
| YugabyteDB RF | 3 |
| Shared Cache | Redis (same for both) |
| Isolation | Dedicated namespaces |
| Monitoring | Single Prometheus instance |

## Key Features

### 1. Selective Service Deployment

Each value file demonstrates how to disable/enable services:

```yaml
# Disable embedded services
postgresql:
  enabled: false
kafka:
  enabled: false
clickhouse:
  enabled: false

# Enable only required service
services:
  router:
    enabled: true
  consumer:
    enabled: false
  producer:
    enabled: false
```

### 2. OTEL-Based Telemetry

- **Dual receivers**: Separate ports (14317/14318) for PG/YB instances
- **Processor labels**: Automatically adds `source_app` attribute
- **Centralized collection**: All metrics flow to single Prometheus
- **Comparison queries**: Easy filtering by `source_app`

### 3. Grafana Dashboard

The pre-built dashboard includes:
- API Latency (P95/P99) comparison
- Throughput (requests/sec) comparison
- Database query performance
- Resource utilization (CPU/Memory)
- Real-time 5-second refresh

## Monitoring Queries

### API Performance
```promql
# Latency comparison
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{source_app=~"router_pg|router_yb"}[5m])) by (le, source_app))

# Throughput comparison
sum(rate(http_requests_total{source_app=~"router_pg|router_yb"}[1m])) by (source_app)
```

### Database Performance
```promql
# Query latency
avg(rate(db_query_duration_seconds_sum{source_app=~"router_pg|router_yb"}[5m])) by (source_app)

# Query rate
sum(rate(db_query_count{source_app=~"router_pg|router_yb"}[1m])) by (source_app)
```

## Customization

### Adjust Resource Allocations

Edit the respective value files:

```yaml
# In hyperswitch-pg.values.yaml or charts/incubator/yugabyte/values.yaml
resources:
  requests:
    cpu: "1"
    memory: "2Gi"
  limits:
    cpu: "1"
    memory: "2Gi"
```

### Change OTEL Ports

Update both files to match:

```yaml
# hyperswitch-pg.values.yaml
otel_exporter_otlp_endpoint: 'otel-collector.hyperswitch-monitoring.svc.cluster.local:14317'

# hyperswitch-monitoring.values.yaml
receivers:
  otlp/pg:
    protocols:
      grpc:
        endpoint: 0.0.0.0:14317
```

## Troubleshooting

### Common Issues

1. **YugabyteDB slow to start**
   - Expected: Takes 5-10 minutes for cluster initialization
   - Check: `kubectl get pods -n hyperswitch-yb`

2. **Metrics not appearing**
   - Check OTEL collector logs: `kubectl logs -n hyperswitch-monitoring hyperswitch-monitoring-opentelemetry-collector`
   - Verify service connectivity: `kubectl exec -n hyperswitch-pg hyperswitch-pg-router-0 -- nc -zv otel-collector.hyperswitch-monitoring.svc.cluster.local 14317`

3. **Dashboard not loading**
   - Verify configmap exists: `kubectl get cm pg-yb-dashboard -n hyperswitch-monitoring`
   - Check Grafana sidecar logs for dashboard loading issues

## Next Steps

1. **Run load tests**: Use Locust or similar tool to generate traffic
2. **Monitor metrics**: Watch Grafana dashboard during load test
3. **Analyze results**: Compare latency, throughput, and resource usage
4. **Document findings**: Record performance characteristics of each database

## Support

For issues or questions:
- Check `load-test/README-PG-YB-COMPARISON.md` for detailed troubleshooting
- Review logs from relevant pods in each namespace
- Verify Helm releases: `helm list -A | grep hyperswitch`