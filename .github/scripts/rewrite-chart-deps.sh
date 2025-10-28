#!/bin/bash
set -euo pipefail

# Script to rewrite Chart.yaml dependencies from file:// to https:// references
# This allows local development with file:// while publishing with https://

CHART_DIR="${1:-}"
HELM_REPO_URL="${2:-https://juspay.github.io/hyperswitch-helm}"

if [[ -z "$CHART_DIR" ]]; then
  echo "Usage: $0 <chart-directory> [helm-repo-url]"
  echo "Example: $0 charts/incubator/hyperswitch-stack https://juspay.github.io/hyperswitch-helm"
  exit 1
fi

CHART_YAML="${CHART_DIR}/Chart.yaml"

if [[ ! -f "$CHART_YAML" ]]; then
  echo "Error: Chart.yaml not found at ${CHART_YAML}"
  exit 1
fi

echo "Processing ${CHART_YAML}..."

# Create a backup
cp "${CHART_YAML}" "${CHART_YAML}.backup"

# Use yq to rewrite file:// dependencies to https://
# This only rewrites local hyperswitch charts, not external dependencies
yq eval '
  (.dependencies[] | select(.repository | test("^file://.*/(hyperswitch-.*)$")) | .repository) = "'${HELM_REPO_URL}'"
' -i "${CHART_YAML}"

echo "✓ Rewritten dependencies in ${CHART_YAML}"
echo ""
echo "Changed dependencies:"
diff "${CHART_YAML}.backup" "${CHART_YAML}" || true
echo ""
