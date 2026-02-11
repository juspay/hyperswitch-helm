# PostgreSQL vs YugabyteDB Performance Comparison

This directory contains configuration files and documentation for comparing the performance of hyperswitch with PostgreSQL vs YugabyteDB databases.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Kubernetes Cluster                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                    hyperswitch-pg Namespace                         │     │
│  │  hyperswitch-app (Instance 1) ───────┐                               │     │
│  │                                      │ (OTEL → port 14317)         │     │
│  │                                      ▼                               │     │
│  │  PostgreSQL (1CPU/2GB)                                         │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                    hyperswitch-yb Namespace                         │     │
│  │  hyperswitch-app (Instance 2) ───────┐                               │     │
│  │                                      │ (OTEL → port 14318)         │     │
│  │                                      ▼                               │     │
│  │  YugabyteDB (RF=3, 1CPU/2GB)                                    │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                  hyperswitch-shared Namespace                        │     │
│  │  Redis (shared between both instances)                              │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │               hyperswitch-monitoring Namespace                       │     │
│  │  OTEL Collector ────▶ Prometheus ────▶ Grafana                      │     │
│  │  Dual Receivers:                                                │     │
│  │    - Port 14317 → source_app=router_pg                            │     │
│  │    - Port 14318 → source_app=router_yb                            │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Resource Allocations

Both databases are configured with identical resources for fair comparison:

| Component | CPU | Memory |
|-----------|-----|--------|
| PostgreSQL | 1 core | 2GB |
| YugabyteDB | 1 core (per tserver) | 2GB (per tserver) |
| YugabyteDB RF | 3 | 3 |

## Deployment Instructions

### Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- Helm 3.x installed
- kubectl configured for your cluster
- At least 20GB of free disk space

### Step 1: Create Namespaces

```bash
kubectl create namespace hyperswitch-shared
kubectl create namespace hyperswitch-pg
kubectl create namespace hyperswitch-yb
kubectl create namespace hyperswitch-monitoring
kubectl create namespace hyperswitch-loadtest
```

### Step 2: Deploy Shared Infrastructure (Redis)

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install hyperswitch-shared \
  charts/incubator/hyperswitch-app \
  --namespace hyperswitch-shared \
  --values load-test/hyperswitch-shared.values.yaml \
  --wait
```

### Step 3: Deploy PostgreSQL Instance

```bash
helm upgrade --install hyperswitch-pg \
  charts/incubator/hyperswitch-app \
  --namespace hyperswitch-pg \
  --values load-test/hyperswitch-pg.values.yaml \
  --wait
```

Wait for PostgreSQL to be ready:
```bash
kubectl rollout status statefulset/hyperswitch-pg-postgresql -n hyperswitch-pg
```

Initialize the database:
```bash
kubectl exec -n hyperswitch-pg hyperswitch-pg-postgresql-0 -- \
  psql -U postgres -c "CREATE DATABASE hyperswitch;"
```

Run database migrations:
```bash
kubectl exec -n hyperswitch-pg -it hyperswitch-pg-router-0 -- /app/scripts/init_db.sh
```

### Step 4: Deploy YugabyteDB

```bash
helm upgrade --install yugabyte \
  charts/incubator/yugabyte \
  --namespace hyperswitch-yb \
  --values charts/incubator/yugabyte/values.yaml \
  --wait
```

Wait for YugabyteDB to be ready (this may take several minutes):
```bash
kubectl wait --for=condition=ready pod -l app=yugabyte,component=tserver -n hyperswitch-yb --timeout=600s
```

Create database:
```bash
kubectl exec -n hyperswitch-yb yugabyte-tserver-0 -- \
  ysqlsh -h yugabyte-tserver-0.yugabyte-tserver.hyperswitch-yb.svc.cluster.local -c "CREATE DATABASE hyperswitch;"
```

### Step 5: Deploy YugabyteDB Instance of hyperswitch-app

```bash
helm upgrade --install hyperswitch-yb \
  charts/incubator/hyperswitch-app \
  --namespace hyperswitch-yb \
  --values load-test/hyperswitch-yb.values.yaml \
  --wait
```

### Step 6: Deploy Monitoring Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add opentelemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

helm upgrade --install hyperswitch-monitoring \
  charts/incubator/hyperswitch-monitoring \
  --namespace hyperswitch-monitoring \
  --values load-test/hyperswitch-monitoring.values.yaml \
  --wait
```

Import the comparison dashboard:
```bash
kubectl create configmap pg-yb-dashboard \
  --namespace hyperswitch-monitoring \
  --from-file=load-test/dashboards/pg-yb-comparison.json
kubectl label configmap pg-yb-dashboard \
  --namespace hyperswitch-monitoring \
  grafana_dashboard="1"
```

Access Grafana:
```bash
kubectl port-forward -n hyperswitch-monitoring svc/prometheus-operated 9090:9090 &
kubectl port-forward -n hyperswitch-monitoring svc/hyperswitch-monitoring-grafana 3000:80 &
echo "Grafana: http://localhost:3000 (admin/admin)"
```

### Step 7: Run Load Tests

```bash
cd load-test
python load_test.py
```

## Configuration Files

| File | Purpose |
|------|---------|
| `hyperswitch-pg.values.yaml` | hyperswitch-app connected to PostgreSQL, OTEL on port 14317 |
| `hyperswitch-yb.values.yaml` | hyperswitch-app connected to YugabyteDB, OTEL on port 14318 |
| `hyperswitch-shared.values.yaml` | Shared Redis infrastructure |
| `hyperswitch-monitoring.values.yaml` | Monitoring with dual OTEL receivers |
| `dashboards/pg-yb-comparison.json` | Grafana dashboard for comparison |
| `charts/incubator/yugabyte/` | YugabyteDB Helm chart |

## Metrics and Labels

All metrics are labeled with `source_app`:
- `source_app=router_pg` - PostgreSQL instance metrics
- `source_app=router_yb` - YugabyteDB instance metrics

### Key Metrics to Monitor

1. **API Performance**
   - Latency P95/P99: `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{source_app=~"router_pg|router_yb"}[5m])) by (le, source_app))`
   - Throughput: `sum(rate(http_requests_total{source_app=~"router_pg|router_yb"}[1m])) by (source_app)`

2. **Database Performance**
   - Query latency: `avg(db_query_duration_seconds{source_app=~"router_pg|router_yb"})`
   - Query rate: `sum(rate(db_query_count{source_app=~"router_pg|router_yb"}[1m])) by (source_app)`

3. **Resource Utilization**
   - CPU: `avg(rate(container_cpu_usage_seconds_total{namespace=~"hyperswitch-(pg|yb)"}[5m])) * 100`
   - Memory: `avg(container_memory_working_set_bytes{namespace=~"hyperswitch-(pg|yb)"})`

## Troubleshooting

### PostgreSQL not ready
```bash
kubectl logs -n hyperswitch-pg hyperswitch-pg-postgresql-0
kubectl get pods -n hyperswitch-pg
```

### YugabyteDB not ready
```bash
kubectl logs -n hyperswitch-yb yugabyte-master-0
kubectl logs -n hyperswitch-yb yugabyte-tserver-0
kubectl get pods -n hyperswitch-yb
```

### OTEL metrics not appearing
```bash
kubectl logs -n hyperswitch-monitoring hyperswitch-monitoring-opentelemetry-collector
kubectl get svc -n hyperswitch-monitoring
```

### Router connection errors
```bash
kubectl logs -n hyperswitch-pg hyperswitch-pg-router-0
kubectl logs -n hyperswitch-yb hyperswitch-yb-router-0
```

## Cleanup

```bash
helm uninstall hyperswitch-pg -n hyperswitch-pg
helm uninstall hyperswitch-yb -n hyperswitch-yb
helm uninstall hyperswitch-shared -n hyperswitch-shared
helm uninstall hyperswitch-monitoring -n hyperswitch-monitoring
helm uninstall yugabyte -n hyperswitch-yb

kubectl delete namespace hyperswitch-pg
kubectl delete namespace hyperswitch-yb
kubectl delete namespace hyperswitch-shared
kubectl delete namespace hyperswitch-monitoring
kubectl delete namespace hyperswitch-loadtest

kubectl delete pvc --all -n hyperswitch-pg
kubectl delete pvc --all -n hyperswitch-yb
kubectl delete pvc --all -n hyperswitch-monitoring
```

## Analysis

After running the load tests, review the Grafana dashboard to compare:

1. **API Response Times** - Compare P50, P95, P99 latencies
2. **Throughput** - Requests per second handled by each instance
3. **Database Query Performance** - Average query latency and throughput
4. **Resource Utilization** - CPU and memory consumption
5. **Error Rates** - Failed requests and database errors

The fair comparison is ensured by:
- Identical CPU/memory allocations for both databases
- Same application configuration
- Shared Redis to eliminate cache differences
- Dedicated namespaces to avoid resource contention
- Same load test hitting both instances equally