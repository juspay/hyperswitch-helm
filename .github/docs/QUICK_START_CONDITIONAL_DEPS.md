# Quick Start: Conditional Dependencies

## TL;DR

Use `file://` in your Chart.yaml, workflow rewrites to `https://` before publishing.

## Setup (One-time)

### 1. Update `hyperswitch-stack/Chart.yaml`

Change from:
```yaml
dependencies:
  - name: hyperswitch-app
    version: 0.2.13
    repository: "https://juspay.github.io/hyperswitch-helm"
```

To:
```yaml
dependencies:
  - name: hyperswitch-app
    version: 0.2.13
    repository: "file://../hyperswitch-app"  # Use local reference
```

### 2. Use the New Workflow

The workflow at [`.github/workflows/release-with-conditional-deps.yml`](../.github/workflows/release-with-conditional-deps.yml) handles the rewriting automatically.

## Everyday Usage

### Bumping Chart Versions

**Before (Old way - TWO steps required):**
```bash
# Step 1: Bump and release hyperswitch-app alone
yq eval '.version = "0.2.15"' -i charts/incubator/hyperswitch-app/Chart.yaml
git commit -m "bump app to 0.2.15"
# Run release workflow, wait for GitHub Pages to update (~5 min)

# Step 2: Update stack to reference new app version
yq eval '(.dependencies[] | select(.name == "hyperswitch-app") | .version) = "0.2.15"' -i charts/incubator/hyperswitch-stack/Chart.yaml
yq eval '.version = "0.2.17"' -i charts/incubator/hyperswitch-stack/Chart.yaml
git commit -m "bump stack to 0.2.17"
# Run release workflow again
```

**After (New way - ONE step):**
```bash
# Bump both in the same commit
yq eval '.version = "0.2.15"' -i charts/incubator/hyperswitch-app/Chart.yaml
yq eval '(.dependencies[] | select(.name == "hyperswitch-app") | .version) = "0.2.15"' -i charts/incubator/hyperswitch-stack/Chart.yaml
yq eval '.version = "0.2.17"' -i charts/incubator/hyperswitch-stack/Chart.yaml

git add charts/incubator/*/Chart.yaml
git commit -m "bump app to 0.2.15 and stack to 0.2.17"
git push

# Run release workflow ONCE - both charts released ✅
```

### Local Testing

```bash
# Test dependencies work locally
helm dependency update charts/incubator/hyperswitch-stack

# Check what was downloaded
ls -la charts/incubator/hyperswitch-stack/charts/

# Clean up
rm -rf charts/incubator/hyperswitch-stack/charts
```

## What Happens in CI/CD

```bash
# 1. Build with file:// (no circular dependency)
helm dependency update charts/incubator/hyperswitch-stack
# ✅ Downloads from local filesystem

# 2. Rewrite to https:// (for publishing)
# Chart.yaml changed: file://... → https://juspay.github.io/hyperswitch-helm

# 3. Package and publish
helm package charts/incubator/hyperswitch-stack
# 📦 Creates hyperswitch-stack-0.2.17.tgz with https:// references

# 4. Restore original (optional)
# Chart.yaml restored: https://... → file://...
```

## Verification

After release, check the published chart:

```bash
# Add the repo
helm repo add hyperswitch https://juspay.github.io/hyperswitch-helm
helm repo update

# Fetch the chart
helm pull hyperswitch/hyperswitch-stack --untar

# Check Chart.yaml has https:// references
cat hyperswitch-stack/Chart.yaml
```

## Adding More Charts with Local Dependencies

If you create a new chart that depends on other local charts:

1. Use `file://` references in Chart.yaml
2. Update the workflow to include it:

```yaml
# In .github/workflows/release-with-conditional-deps.yml
charts_to_rewrite=("hyperswitch-stack" "your-new-chart")
```

Done! 🎉
