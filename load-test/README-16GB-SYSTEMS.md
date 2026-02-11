# PostgreSQL vs YugabyteDB Performance Comparison - 16GB Systems Guide

This guide is specifically for running the performance comparison on systems with 16GB RAM.

## System Requirements

### Hardware
- **RAM**: 16GB minimum
- **CPU**: 8 cores minimum (recommended)
- **Disk**: 20GB free space

### Software
- Docker Desktop or Docker Engine
- kind (Kubernetes in Docker)
- kubectl
- Helm 3.x

## Quick Setup

### Step 1: Create Kind Cluster

```bash
kind create cluster --config=load-test/kind-cluster-lite.yaml
```

This creates a single-node Kind cluster with port mappings for Grafana (3000) and Prometheus (9090).

### Step 2: Verify Cluster

```bash
kubectl cluster-info --context kind-hyperswitch-comparison
kubectl get nodes
```

### Step 3: Deploy Comparison Environment

```bash
./load-test/deploy-comparison.sh --lightweight
```

The `--lightweight` flag reduces resource allocation to fit within 16GB:
- PostgreSQL: 500m CPU / 512MB RAM
- YugabyteDB: 500m CPU / 512MB RAM per pod (6 pods total)
- Monitoring: 1CPU / 2GB RAM

**Expected total usage**: ~6-8GB RAM, leaving ~8GB for Docker and OS overhead.

### Step 4: Access Grafana

```bash
kubectl port-forward -n hyperswitch-monitoring svc/hyperswitch-monitoring-grafana 3000:80
```

Open http://localhost:3000 (admin/admin) and navigate to the "PostgreSQL vs YugabyteDB Performance Comparison" dashboard.

## Resource Allocation (Lightweight Profile)

| Component | Pods | CPU (requests) | Memory (requests) | CPU (limits) | Memory (limits) |
|-----------|------|----------------|-------------------|--------------|----------------|
| **PostgreSQL** | 1 | 500m | 512Mi | 500m | 512Mi |
| **YugabyteDB Masters** | 3 | 500m | 512Mi | 500m | 512Mi |
| **YugabyteDB TServers** | 3 | 500m | 512Mi | 500m | 512Mi |
| **Hyperswitch PG Router** | 1 | 200m | 256Mi | 500m | 512Mi |
| **Hyperswitch YB Router** | 1 | 200m | 256Mi | 500m | 512Mi |
| **Redis (Shared)** | 1 | 100m | 64Mi | 200m | 256Mi |
| **Prometheus** | 1 | 50m | 256Mi | 500m | 1Gi |
| **Grafana** | 1 | 100m | 256Mi | 500m | 512Mi |
| **OTEL Collector** | 1 | 100m | 256Mi | 500m | 1Gi |
| **TOTAL** | **12** | **~3.4 cores** | **~3.5GB** | **~4.2 cores** | **~6GB** |

## Resource Guarantees

Each namespace has dedicated resource limits enforced by Kubernetes:

```bash
# View PostgreSQL namespace resources
kubectl describe namespace hyperswitch-pg

# View YugabyteDB namespace resources
kubectl describe namespace hyperswitch-yb
```

## Verification Commands

### Check Pod Resource Usage

```bash
# Overall cluster usage
kubectl top nodes

# Detailed pod usage by namespace
kubectl top pods -n hyperswitch-pg
kubectl top pods -n hyperswitch-yb
kubectl top pods -n hyperswitch-monitoring
```

### Verify Resource Limits

```bash
# PostgreSQL pod limits
kubectl get pod -n hyperswitch-pg -o jsonpath='{.items[*].spec.containers[*].resources}'

# YugabyteDB pod limits
kubectl get pod -n hyperswitch-yb -o jsonpath='{.items[*].spec.containers[*].resources}'
```

## Known Limitations (Lightweight Profile)

1. **Smaller Storage**: Only 5GB per YugabyteDB pod (vs 10GB standard)
2. **Reduced Performance**: Lower memory may affect benchmark results
3. **No Logs**: Loki is disabled to save memory
4. **Shorter Retention**: Prometheus keeps 7 days of data (vs 15 days standard)

## Troubleshooting

### Out of Memory Errors

If you see OOMKilled events:

```bash
# Check evicted pods
kubectl get pods -A | grep Evicted

# Check node capacity
kubectl describe node kind-control-plane | grep -A 10 "Allocated resources"
```

**Solution**: Close other applications to free up RAM.

### Slow Performance

The lightweight profile is designed for functionality testing, not performance benchmarks. Results may not reflect production behavior.

### YugabyteDB Not Starting

YugabyteDB requires ~1.5GB minimum per pod in production. With 512MB limits:

```bash
# Check pod events
kubectl describe pod -n hyperswitch-yb yugabyte-tserver-0

# Check logs
kubectl logs -n hyperswitch-yb yugabyte-tserver-0
```

**Solution**: Increase memory limits in `charts/incubator/yugabyte/values-lightweight.yaml`.

## Cleanup

```bash
# Remove all deployments
./load-test/cleanup-comparison.sh

# Delete Kind cluster
kind delete cluster --name hyperswitch-comparison

# Verify cleanup
docker ps -a | grep kind
```

## Switching Profiles

To switch from lightweight to standard profile (requires more RAM):

```bash
# Cleanup first
./load-test/cleanup-comparison.sh

# Deploy with standard profile
./load-test/deploy-comparison.sh
```

## Comparison with Standard Profile

| Aspect | Standard (24GB+) | Lightweight (16GB) |
|--------|------------------|---------------------|
| PostgreSQL Memory | 2GB | 512MB |
| YugabyteDB Memory (per pod) | 2GB | 512MB |
| Total Database Memory | 14GB | 3.5GB |
| Monitoring | Full (with Loki) | Minimal (no Loki) |
| Prometheus Retention | 15 days | 7 days |
| Data Retention | 30GB | 10GB |
| Benchmark Accuracy | High | Medium |
| Primary Use Case | Production testing | Development/testing |

## Best Practices for 16GB Systems

1. **Close unnecessary applications** before running tests
2. **Monitor Docker memory usage**: `docker stats`
3. **Run tests sequentially**, not simultaneously
4. **Keep load test duration shorter** to limit data growth
5. **Clean up frequently** between test runs

## Getting Help

For more detailed troubleshooting:
- Check `load-test/README-PG-YB-COMPARISON.md`
- Review pod logs: `kubectl logs -n <namespace> <pod>`
- Verify Helm releases: `helm list -A | grep hyperswitch`

## Related Files

- `load-test/kind-cluster-lite.yaml` - Kind cluster configuration
- `load-test/deploy-comparison.sh` - Deployment script with --lightweight flag
- `load-test/hyperswitch-*-lightweight.values.yaml` - Lightweight value files
- `charts/incubator/yugabyte/values-lightweight.yaml` - YugabyteDB lightweight config