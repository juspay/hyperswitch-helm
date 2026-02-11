#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
LIGHTWEIGHT=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --lightweight)
      LIGHTWEIGHT=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--lightweight]"
      echo ""
      echo "Options:"
      echo "  --lightweight    Deploy with reduced resources for 16GB systems"
      echo "  --help, -h       Show this help message"
      echo ""
      echo "Profiles:"
      echo "  Standard (default): PostgreSQL 1CPU/2GB, YugabyteDB 1CPU/2GB (requires ~20GB RAM)"
      echo "  Lightweight:       PostgreSQL 500m/512MB, YugabyteDB 500m/512MB (requires ~6GB RAM)"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

echo -e "${GREEN}=== PostgreSQL vs YugabyteDB Performance Comparison Deployment ===${NC}"

if [ "$LIGHTWEIGHT" = true ]; then
  echo -e "${BLUE}Profile: Lightweight (reduced resources for 16GB systems)${NC}"
  echo -e "${BLUE}Resources: PostgreSQL/YugabyteDB = 500m CPU / 512MB RAM per pod${NC}"
else
  echo -e "${BLUE}Profile: Standard (full resources)${NC}"
  echo -e "${BLUE}Resources: PostgreSQL/YugabyteDB = 1 CPU / 2GB RAM per pod${NC}"
fi

# Prerequisites check
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl not found. Please install kubectl.${NC}"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo -e "${RED}helm not found. Please install Helm 3.x.${NC}"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Build chart dependencies
echo -e "\n${YELLOW}Setting up Helm repositories and building chart dependencies...${NC}"
helm repo add bitnami https://charts.bitnami.com/bitnami > /dev/null 2>&1 || true
helm repo add codecentric https://codecentric.github.io/helm-charts > /dev/null 2>&1 || true
helm repo add vector https://helm.vector.dev > /dev/null 2>&1 || true
helm repo update > /dev/null 2>&1 || true

cd "$PROJECT_ROOT/charts/incubator/hyperswitch-app"
helm dependency build
cd "$PROJECT_ROOT"

# Determine which value files to use based on profile
if [ "$LIGHTWEIGHT" = true ]; then
  PG_VALUES="$SCRIPT_DIR/hyperswitch-pg-lightweight.values.yaml"
  YB_VALUES="$SCRIPT_DIR/hyperswitch-yb-lightweight.values.yaml"
  MONITORING_VALUES="$SCRIPT_DIR/hyperswitch-monitoring-lightweight.values.yaml"
  YUGABYTE_VALUES="$PROJECT_ROOT/charts/incubator/yugabyte/values-lightweight.yaml"
else
  PG_VALUES="$SCRIPT_DIR/hyperswitch-pg.values.yaml"
  YB_VALUES="$SCRIPT_DIR/hyperswitch-yb.values.yaml"
  MONITORING_VALUES="$SCRIPT_DIR/hyperswitch-monitoring.values.yaml"
  YUGABYTE_VALUES="$PROJECT_ROOT/charts/incubator/yugabyte/values.yaml"
fi

# Step 1: Create namespaces
echo -e "\n${YELLOW}Step 1: Creating namespaces...${NC}"
kubectl create namespace hyperswitch-shared --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace hyperswitch-pg --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace hyperswitch-yb --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace hyperswitch-monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace hyperswitch-loadtest --dry-run=client -o yaml | kubectl apply -f -

# Step 2: Deploy shared infrastructure (Redis)
echo -e "\n${YELLOW}Step 2: Deploying shared Redis infrastructure...${NC}"
helm repo add bitnami https://charts.bitnami.com/bitnami > /dev/null 2>&1 || true
helm repo update > /dev/null 2>&1 || true

# Determine Redis resources based on profile
if [ "$LIGHTWEIGHT" = true ]; then
  REDIS_REQUESTS_MEMORY="64Mi"
  REDIS_REQUESTS_CPU="100m"
  REDIS_LIMITS_MEMORY="256Mi"
  REDIS_LIMITS_CPU="200m"
else
  REDIS_REQUESTS_MEMORY="250Mi"
  REDIS_REQUESTS_CPU="100m"
  REDIS_LIMITS_MEMORY="512Mi"
  REDIS_LIMITS_CPU="500m"
fi

helm upgrade --install hyperswitch-shared-redis \
  bitnami/redis \
  --namespace hyperswitch-shared \
  --set architecture=standalone \
  --set auth.enabled=false \
  --set master.persistence.enabled=false \
  --set replica.replicaCount=0 \
  --set master.resources.requests.memory="${REDIS_REQUESTS_MEMORY}" \
  --set master.resources.requests.cpu="${REDIS_REQUESTS_CPU}" \
  --set master.resources.limits.memory="${REDIS_LIMITS_MEMORY}" \
  --set master.resources.limits.cpu="${REDIS_LIMITS_CPU}" \
  --wait --timeout 15m || echo -e "${YELLOW}Warning: Redis deployment had issues, continuing...${NC}"

# Step 3: Deploy PostgreSQL instance
echo -e "\n${YELLOW}Step 3: Deploying PostgreSQL instance...${NC}"
helm upgrade --install hyperswitch-pg \
  "$PROJECT_ROOT/charts/incubator/hyperswitch-app" \
  --namespace hyperswitch-pg \
  --values "$PG_VALUES" \
  --wait --timeout 20m || echo -e "${YELLOW}Warning: PostgreSQL deployment timed out, continuing...${NC}"

# Wait for PostgreSQL to be ready
echo -e "\n${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
kubectl rollout status statefulset/hyperswitch-pg-postgresql -n hyperswitch-pg --timeout=600s || echo -e "${YELLOW}Warning: PostgreSQL rollout timed out, continuing...${NC}"

# Initialize PostgreSQL database
echo -e "\n${YELLOW}Initializing PostgreSQL database...${NC}"
kubectl exec -n hyperswitch-pg hyperswitch-pg-postgresql-0 -- \
  psql -U postgres -c "CREATE DATABASE hyperswitch;" 2>/dev/null || echo "Database may already exist"

# Step 4: Deploy YugabyteDB
echo -e "\n${YELLOW}Step 4: Deploying YugabyteDB (this may take several minutes)...${NC}"
helm upgrade --install yugabyte \
  "$PROJECT_ROOT/charts/incubator/yugabyte" \
  --namespace hyperswitch-yb \
  --values "$YUGABYTE_VALUES" \
  --wait --timeout 20m || echo -e "${YELLOW}Warning: YugabyteDB deployment timed out, continuing...${NC}"

# Wait for YugabyteDB to be ready
echo -e "\n${YELLOW}Waiting for YugabyteDB to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=yugabyte,component=tserver -n hyperswitch-yb --timeout=900s || echo -e "${YELLOW}Warning: YugabyteDB pods not ready yet, continuing...${NC}"

# Create YugabyteDB database
echo -e "\n${YELLOW}Creating YugabyteDB database...${NC}"
kubectl exec -n hyperswitch-yb yugabyte-tserver-0 -- \
  ysqlsh -h yugabyte-tserver-0.yugabyte-tserver.hyperswitch-yb.svc.cluster.local -c "CREATE DATABASE hyperswitch;" 2>/dev/null || echo -e "${YELLOW}Database creation may have failed, continuing...${NC}"

# Step 5: Deploy YugabyteDB instance of hyperswitch-app
echo -e "\n${YELLOW}Step 5: Deploying hyperswitch-app with YugabyteDB...${NC}"
helm upgrade --install hyperswitch-yb \
  "$PROJECT_ROOT/charts/incubator/hyperswitch-app" \
  --namespace hyperswitch-yb \
  --values "$YB_VALUES" \
  --wait --timeout 20m || echo -e "${YELLOW}Warning: Hyperswitch YB deployment timed out, continuing...${NC}"

# Step 6: Deploy monitoring stack
echo -e "\n${YELLOW}Step 6: Deploying monitoring stack...${NC}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo add opentelemetry https://open-telemetry.github.io/opentelemetry-helm-charts 2>/dev/null || true
helm repo update > /dev/null 2>&1 || true

helm upgrade --install hyperswitch-monitoring \
  "$PROJECT_ROOT/charts/incubator/hyperswitch-monitoring" \
  --namespace hyperswitch-monitoring \
  --values "$MONITORING_VALUES" \
  --wait --timeout 15m || echo -e "${YELLOW}Warning: Monitoring deployment had issues${NC}"

# Import Grafana dashboard
echo -e "\n${YELLOW}Importing Grafana comparison dashboard...${NC}"
kubectl create configmap pg-yb-dashboard \
  --namespace hyperswitch-monitoring \
  --from-file="$SCRIPT_DIR/dashboards/pg-yb-comparison.json" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl label configmap pg-yb-dashboard \
  --namespace hyperswitch-monitoring \
  grafana_dashboard="1" --overwrite

# Step 7: Display status and access information
echo -e "\n${GREEN}=== Deployment Complete! ===${NC}"
echo -e "\n${YELLOW}Pod Status:${NC}"
kubectl get pods -n hyperswitch-pg
echo ""
kubectl get pods -n hyperswitch-yb
echo ""
kubectl get pods -n hyperswitch-monitoring

echo -e "\n${YELLOW}To access Grafana:${NC}"
echo "kubectl port-forward -n hyperswitch-monitoring svc/hyperswitch-monitoring-grafana 3000:80"
echo "Then open: http://localhost:3000 (admin/admin)"

echo -e "\n${YELLOW}To access Prometheus:${NC}"
echo "kubectl port-forward -n hyperswitch-monitoring svc/prometheus-operated 9090:9090"
echo "Then open: http://localhost:9090"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Verify all pods are running: kubectl get pods -A | grep hyperswitch"
echo "2. Access Grafana and open the 'PostgreSQL vs YugabyteDB Performance Comparison' dashboard"
echo "3. Run load tests: cd load-test && python load_test.py"
echo "4. Monitor metrics in Grafana"

if [ "$LIGHTWEIGHT" = true ]; then
  echo ""
  echo -e "${BLUE}Lightweight profile deployed - reduced resource consumption:${NC}"
  echo -e "${BLUE}- PostgreSQL: 500m CPU / 512MB RAM${NC}"
  echo -e "${BLUE}- YugabyteDB: 500m CPU / 512MB RAM (per pod, 6 pods total)${NC}"
  echo -e "${BLUE}- Estimated total: ~3-5GB RAM + ~4-5GB for monitoring/app${NC}"
fi

echo -e "\n${YELLOW}To cleanup:${NC}"
echo "./load-test/cleanup-comparison.sh"