#!/bin/bash
set -euo pipefail

# Script to prepare charts for release by:
# 1. Rewriting file:// dependencies to https:// (for charts that depend on other local charts)
# 2. Building dependencies using local file:// references first
# 3. Then rewriting to https:// for the final package

CHARTS_DIR="${1:-charts/incubator}"
HELM_REPO_URL="${2:-https://juspay.github.io/hyperswitch-helm}"
WORK_DIR="${3:-.chart-prep}"

echo "================================================"
echo "Preparing charts for release"
echo "================================================"
echo "Charts directory: ${CHARTS_DIR}"
echo "Helm repo URL: ${HELM_REPO_URL}"
echo "Working directory: ${WORK_DIR}"
echo ""

# Create working directory
mkdir -p "${WORK_DIR}"

# List of charts that have local hyperswitch dependencies
# These need special handling
CHARTS_WITH_LOCAL_DEPS=(
  "hyperswitch-stack"
  # Add more charts here if needed
)

# Step 1: Build ALL chart dependencies using current (file://) references
echo "Step 1: Building chart dependencies with local references..."
echo "============================================================="
for chart_path in "${CHARTS_DIR}"/*; do
  if [[ -f "${chart_path}/Chart.yaml" ]]; then
    chart_name=$(basename "${chart_path}")
    echo "→ Building dependencies for ${chart_name}..."

    # Update dependencies using file:// references
    helm dependency update "${chart_path}" || {
      echo "Warning: Failed to update dependencies for ${chart_name}"
    }
  fi
done
echo ""

# Step 2: Copy charts to working directory and rewrite dependencies
echo "Step 2: Preparing charts with rewritten dependencies..."
echo "========================================================"
for chart_path in "${CHARTS_DIR}"/*; do
  if [[ -f "${chart_path}/Chart.yaml" ]]; then
    chart_name=$(basename "${chart_path}")
    echo "→ Processing ${chart_name}..."

    # Copy chart to working directory
    cp -r "${chart_path}" "${WORK_DIR}/"

    # Check if this chart needs dependency rewriting
    if printf '%s\n' "${CHARTS_WITH_LOCAL_DEPS[@]}" | grep -q "^${chart_name}$"; then
      echo "  ✓ Chart has local dependencies, rewriting to ${HELM_REPO_URL}..."

      # Rewrite file:// to https:// for hyperswitch charts
      yq eval '
        (.dependencies[] |
          select(.repository | test("^file://.*/(hyperswitch-.*)$")) |
          .repository
        ) = "'${HELM_REPO_URL}'"
      ' -i "${WORK_DIR}/${chart_name}/Chart.yaml"

      echo "  ✓ Dependencies rewritten"
    else
      echo "  ○ No local hyperswitch dependencies to rewrite"
    fi
  fi
done
echo ""

echo "================================================"
echo "✓ Charts prepared in ${WORK_DIR}"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. The prepared charts are in ${WORK_DIR}/"
echo "  2. Dependencies are already built (charts/*/charts/ directories)"
echo "  3. Chart.yaml files have been rewritten to use ${HELM_REPO_URL}"
echo "  4. You can now package these charts with 'helm package'"
echo ""
