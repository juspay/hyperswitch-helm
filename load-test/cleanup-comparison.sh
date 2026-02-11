#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Cleaning up PostgreSQL vs YugabyteDB Comparison Environment ===${NC}"

# Function to safely uninstall Helm release
safe_uninstall() {
  local namespace=$1
  local release=$2
  if helm list -n "$namespace" -q | grep -q "^${release}$"; then
    echo "Uninstalling $release from namespace $namespace..."
    helm uninstall "$release" -n "$namespace" 2>/dev/null || true
  fi
}

# Function to safely delete namespace
safe_delete_namespace() {
  local namespace=$1
  if kubectl get namespace "$namespace" >/dev/null 2>&1; then
    echo "Deleting namespace $namespace..."
    kubectl delete namespace "$namespace" --timeout=60s 2>/dev/null || {
      echo "Force deleting namespace $namespace..."
      kubectl get namespace "$namespace" -o json | \
        sed 's/"kubernetes"/"k8s"/g' | \
        kubectl replace --raw /api/v1/namespaces/"$namespace"/finalize -f - 2>/dev/null || true
    }
  fi
}

echo -e "\n${YELLOW}Step 1: Uninstalling Helm releases...${NC}"
safe_uninstall hyperswitch-pg hyperswitch-pg
safe_uninstall hyperswitch-yb hyperswitch-yb
safe_uninstall hyperswitch-shared hyperswitch-shared-redis
safe_uninstall hyperswitch-monitoring hyperswitch-monitoring
safe_uninstall yugabyte hyperswitch-yb

echo -e "\n${YELLOW}Step 2: Deleting Persistent Volume Claims...${NC}"
kubectl delete pvc --all -n hyperswitch-pg --ignore-not-found=true
kubectl delete pvc --all -n hyperswitch-yb --ignore-not-found=true
kubectl delete pvc --all -n hyperswitch-monitoring --ignore-not-found=true
kubectl delete pvc --all -n hyperswitch-shared --ignore-not-found=true

echo -e "\n${YELLOW}Step 3: Deleting namespaces...${NC}"
safe_delete_namespace hyperswitch-pg
safe_delete_namespace hyperswitch-yb
safe_delete_namespace hyperswitch-shared
safe_delete_namespace hyperswitch-monitoring
safe_delete_namespace hyperswitch-loadtest

echo -e "\n${GREEN}=== Cleanup Complete! ===${NC}"

# Optional: Remove orphaned PVs
read -p "Do you want to delete orphaned Persistent Volumes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "\n${YELLOW}Deleting orphaned Persistent Volumes...${NC}"
  kubectl get pv -o json | \
    jq -r '.items[] | select(.spec.claimRef.namespace == "hyperswitch-pg" or .spec.claimRef.namespace == "hyperswitch-yb" or .spec.claimRef.namespace == "hyperswitch-monitoring" or .spec.claimRef.namespace == "hyperswitch-shared") | .metadata.name' | \
    while read pv; do
      if [ -n "$pv" ]; then
        kubectl delete pv "$pv" --ignore-not-found=true 2>/dev/null || true
      fi
    done
fi

echo -e "\n${YELLOW}Remaining Hyperswitch resources (if any):${NC}"
kubectl get all,pvc,pv -A | grep hyperswitch || echo "No hyperswitch resources found."

echo -e "\n${GREEN}Done!${NC}"