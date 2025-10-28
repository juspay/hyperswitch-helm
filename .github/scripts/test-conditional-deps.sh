#!/bin/bash
set -euo pipefail

# Test script to demonstrate the conditional dependency approach
# This simulates what the workflow does

CHARTS_DIR="charts/incubator"
TEST_CHART="hyperswitch-stack"
HELM_REPO_URL="https://juspay.github.io/hyperswitch-helm"

echo "================================================"
echo "Testing Conditional Dependency Approach"
echo "================================================"
echo ""

echo "Step 1: Show current Chart.yaml (should have file:// refs)"
echo "==========================================================="
echo "Dependencies in ${TEST_CHART}/Chart.yaml:"
yq eval '.dependencies[] | select(.repository | test("hyperswitch")) | {"name": .name, "version": .version, "repository": .repository}' "${CHARTS_DIR}/${TEST_CHART}/Chart.yaml"
echo ""

echo "Step 2: Build dependencies with local file:// references"
echo "=========================================================="
echo "Running: helm dependency update ${CHARTS_DIR}/${TEST_CHART}"
helm dependency update "${CHARTS_DIR}/${TEST_CHART}"
echo "✓ Dependencies built successfully"
echo ""

echo "Step 3: Check what was downloaded"
echo "=================================="
ls -lh "${CHARTS_DIR}/${TEST_CHART}/charts/"
echo ""

echo "Step 4: Create a backup and rewrite Chart.yaml"
echo "==============================================="
cp "${CHARTS_DIR}/${TEST_CHART}/Chart.yaml" "${CHARTS_DIR}/${TEST_CHART}/Chart.yaml.backup"

yq eval '
  (.dependencies[] |
    select(.repository | test("^file://.*/(hyperswitch-.*)$")) |
    .repository
  ) = "'${HELM_REPO_URL}'"
' -i "${CHARTS_DIR}/${TEST_CHART}/Chart.yaml"

echo "✓ Chart.yaml rewritten"
echo ""

echo "Step 5: Show changes"
echo "===================="
echo "Before (file://) vs After (https://):"
diff "${CHARTS_DIR}/${TEST_CHART}/Chart.yaml.backup" "${CHARTS_DIR}/${TEST_CHART}/Chart.yaml" || true
echo ""

echo "Step 6: Package the chart"
echo "========================="
mkdir -p .test-packages
helm package "${CHARTS_DIR}/${TEST_CHART}" -d .test-packages
echo "✓ Chart packaged successfully"
echo ""

echo "Step 7: Inspect the packaged chart"
echo "==================================="
latest_package=$(ls -t .test-packages/${TEST_CHART}-*.tgz | head -1)
echo "Package: ${latest_package}"
echo ""
echo "Contents:"
tar -tzf "${latest_package}" | head -20
echo ""

echo "Extracting Chart.yaml from package to verify:"
tar -xzf "${latest_package}" -O "${TEST_CHART}/Chart.yaml" | yq eval '.dependencies[] | select(.repository | test("hyperswitch")) | {"name": .name, "repository": .repository}'
echo ""

echo "Step 8: Restore original Chart.yaml"
echo "===================================="
mv "${CHARTS_DIR}/${TEST_CHART}/Chart.yaml.backup" "${CHARTS_DIR}/${TEST_CHART}/Chart.yaml"
echo "✓ Original Chart.yaml restored"
echo ""

echo "Step 9: Cleanup"
echo "==============="
rm -rf "${CHARTS_DIR}/${TEST_CHART}/charts"
rm -rf .test-packages
echo "✓ Test artifacts cleaned up"
echo ""

echo "================================================"
echo "✓ Test Complete!"
echo "================================================"
echo ""
echo "Summary:"
echo "  1. ✓ Built dependencies using local file:// references"
echo "  2. ✓ Rewrote Chart.yaml to use https:// references"
echo "  3. ✓ Packaged chart successfully"
echo "  4. ✓ Packaged chart contains the rewritten references"
echo "  5. ✓ Original Chart.yaml restored (for development)"
echo ""
echo "This approach allows:"
echo "  • Local development with file:// (no circular deps)"
echo "  • Published charts with https:// (easy user installation)"
echo "  • Single workflow run for all charts"
echo ""
