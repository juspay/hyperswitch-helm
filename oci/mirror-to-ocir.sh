#!/usr/bin/env bash
# mirror-to-ocir.sh — Mirror ALL images used by hyperswitch-stack to OCIR.
#
# Pulls every image rendered by helm template and re-pushes it to your OCI
# Container Registry (OCIR) under the same repo path (source registry stripped).
# Also updates values-ocir.yaml with the correct global.imageRegistry so all
# Helm chart image pulls use OCIR — no Docker Hub rate limits.
#
# Prerequisites:
#   - crane  (brew install crane)
#   - helm >= 3.x
#   - crane logged in to OCIR:
#       crane auth login <region>.ocir.io \
#         -u '<tenancy-namespace>/<oci-username>' \
#         -p '<oci-auth-token>'
#
# Required environment variables:
#   OCIR_REGION     — OCI region identifier, e.g. ap-hyderabad-1
#   OCIR_NAMESPACE  — OCI tenancy object-storage namespace (oci os ns get)
#
# Optional environment variables:
#   DOCKERHUB_USERNAME  — Docker Hub username (avoids anonymous pull rate limits)
#   DOCKERHUB_TOKEN     — Docker Hub access token or password
#   DRY_RUN=1           — List images only, do not push; still writes values-ocir.yaml
#   MAX_PARALLEL=6      — Number of concurrent image copies (default: 6)
#
# Usage:
#   export OCIR_REGION=<region>
#   export OCIR_NAMESPACE=<tenancy-namespace>
#   ./oci/mirror-to-ocir.sh
#
#   # Dry run (list images, skip push, update values-ocir.yaml):
#   DRY_RUN=1 OCIR_REGION=<region> OCIR_NAMESPACE=<namespace> ./oci/mirror-to-ocir.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="${SCRIPT_DIR}/../charts/incubator/hyperswitch-stack"
OUTPUT_VALUES="${SCRIPT_DIR}/values-ocir.yaml"
DRY_RUN="${DRY_RUN:-0}"
MAX_PARALLEL="${MAX_PARALLEL:-6}"

# ─── Config ───────────────────────────────────────────────────────────────────

OCIR_REGION="${OCIR_REGION:?Set OCIR_REGION  e.g. export OCIR_REGION=ap-hyderabad-1}"
OCIR_NAMESPACE="${OCIR_NAMESPACE:?Set OCIR_NAMESPACE  (run: oci os ns get)}"
OCIR_HOST="${OCIR_REGION}.ocir.io"
OCIR_REGISTRY="${OCIR_HOST}/${OCIR_NAMESPACE}"

# Optional: Docker Hub credentials to avoid anonymous pull rate limits.
# docker.juspay.io is served by Docker Hub — crane needs to authenticate.
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-}"
DOCKERHUB_TOKEN="${DOCKERHUB_TOKEN:-}"

# ─── Helpers ──────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
section() { echo ""; echo "── $* ──────────────────────────────────"; }

# Strip the source registry prefix to get <repo>:<tag>
# docker.io/bitnamilegacy/redis:7.2.3         →  bitnamilegacy/redis:7.2.3
# docker.juspay.io/juspaydotin/router:v1      →  juspaydotin/router:v1
# registry.k8s.io/ingress-nginx/certgen:v1    →  ingress-nginx/certgen:v1
# quay.io/prometheus/prometheus:v2            →  prometheus/prometheus:v2
# kiwigrid/k8s-sidecar:1.27.5               →  kiwigrid/k8s-sidecar:1.27.5
strip_registry() {
  local src="$1"
  if [[ "$src" =~ ^[^/]*\.[^/]*/(.+)$ ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo "$src"
  fi
}

# ─── Extract images rendered by the chart ─────────────────────────────────────

section "Rendering chart to extract images"
echo "Chart: $CHART_DIR"

RENDERED=$(helm template hs "$CHART_DIR" --namespace hyperswitch 2>/dev/null)

# Method 1 — YAML `image:` fields.
# Catches implicit Docker Hub refs (no registry prefix, e.g. kiwigrid/k8s-sidecar:1.27).
M1=$(echo "$RENDERED" \
  | grep -E '^\s+image:\s' \
  | sed 's/.*image:[[:space:]]*//' \
  | tr -d '"' \
  | sed 's/^[[:space:]]*//' \
  | grep -v '^$')

# Method 2 — Any hostname.tld/path:tag pattern anywhere in the rendered output.
# Catches images passed as operator CLI flags or env var values, e.g.:
#   --prometheus-config-reloader=quay.io/prometheus-operator/prometheus-config-reloader:v0.77.1
#   --thanos-default-base-image=quay.io/thanos/thanos:v0.36.1
# Requires an explicit :tag so Kubernetes API paths (networking.k8s.io/v1) are excluded.
M2=$(echo "$RENDERED" \
  | grep -oE '[a-zA-Z0-9][a-zA-Z0-9-]*(\.[a-zA-Z0-9-]+)+/[a-zA-Z0-9._/-]+:[a-zA-Z0-9][a-zA-Z0-9._-]+' \
  | grep -vE '^(api|app|alb|cert|helm|runbooks|docs|github)\.' \
  | grep -v 'kubernetes\.io/')

ALL_IMAGES=$(printf '%s\n%s\n' "$M1" "$M2" \
  | grep -v '^$' | sort -u)

echo ""
echo "Images to mirror (all sources):"
echo "$ALL_IMAGES" | while IFS= read -r img; do echo "  $img"; done
echo ""
echo "Total: $(echo "$ALL_IMAGES" | wc -l | tr -d ' ') images  |  parallelism: ${MAX_PARALLEL}"

if [[ "$DRY_RUN" == "1" ]]; then
  echo ""
  warn "DRY_RUN=1 — skipping pull/push"
  # Still write values-ocir.yaml on dry run so it's always up to date
  section "Writing ${OUTPUT_VALUES} (dry run)"
else
  section "Mirroring images to ${OCIR_REGISTRY} (parallel: ${MAX_PARALLEL})"
fi

# ─── Check for crane ──────────────────────────────────────────────────────────

if ! command -v crane &> /dev/null; then
  echo "ERROR: 'crane' is required but not installed."
  echo "  brew install crane"
  echo ""
  echo "crane copies images by digest across registries without local caching,"
  echo "which guarantees the correct linux/amd64 platform is pushed to OCIR."
  exit 1
fi

# Helper: read a credential field from the local Docker credential store.
# Tries macOS Keychain first, falls back to secretservice (Linux).
_docker_cred_get() {
  local host="$1" field="$2"
  if command -v docker-credential-osxkeychain &>/dev/null; then
    printf 'https://%s' "$host" \
      | docker-credential-osxkeychain get 2>/dev/null \
      | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('${field}',''))" 2>/dev/null || echo ""
  elif command -v docker-credential-secretservice &>/dev/null; then
    printf 'https://%s' "$host" \
      | docker-credential-secretservice get 2>/dev/null \
      | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('${field}',''))" 2>/dev/null || echo ""
  fi
}

# Log crane into OCIR using credentials already stored in the Docker config.
# If you used `crane auth login` or `docker login` for OCIR beforehand,
# crane picks up those credentials automatically from ~/.docker/config.json.
crane auth login "$OCIR_HOST" \
  --username "$(_docker_cred_get "$OCIR_HOST" Username)" \
  --password "$(_docker_cred_get "$OCIR_HOST" Secret)" \
  2>/dev/null || true

# Log crane into Docker Hub.
# docker.juspay.io is served by Docker Hub — anonymous pulls hit rate limits fast.
# Prefer explicit env vars; fall back to the local Docker credential store.

if [[ -z "$DOCKERHUB_USERNAME" || -z "$DOCKERHUB_TOKEN" ]]; then
  DOCKERHUB_USERNAME="$(_docker_cred_get "index.docker.io/v1/" Username)"
  DOCKERHUB_TOKEN="$(_docker_cred_get "index.docker.io/v1/" Secret)"
fi

if [[ -n "$DOCKERHUB_USERNAME" && -n "$DOCKERHUB_TOKEN" ]]; then
  info "Logging crane into Docker Hub as ${DOCKERHUB_USERNAME}"
  crane auth login index.docker.io  -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_TOKEN" 2>/dev/null
  crane auth login docker.juspay.io -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_TOKEN" 2>/dev/null
  crane auth login docker.io        -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_TOKEN" 2>/dev/null
else
  warn "No Docker Hub credentials found — anonymous access may hit rate limits"
  warn "  export DOCKERHUB_USERNAME=<username> DOCKERHUB_TOKEN=<access-token>"
  warn "  Or: docker login   (credentials will be picked up automatically)"
fi

# ─── Per-image worker (runs in a subshell) ────────────────────────────────────

_TMPDIR="$(mktemp -d)"
trap 'rm -rf "$_TMPDIR"' EXIT

mirror_one() {
  local src="$1"
  local repo_tag dest slug status crane_out

  repo_tag="$(strip_registry "$src")"
  dest="${OCIR_REGISTRY}/${repo_tag}"
  slug="$(echo "$src" | tr '/:.@' '____')"

  # Try linux/amd64 first (handles multi-arch manifest lists).
  # Fall back to plain copy for single-arch images — those don't have a manifest
  # list so --platform fails, but they're already amd64 (Juspay builds on amd64).
  if crane_out=$(crane copy --platform linux/amd64 "$src" "$dest" 2>&1); then
    status="OK"
  elif crane_out=$(crane copy "$src" "$dest" 2>&1); then
    status="OK"
  else
    status="FAIL"
  fi

  # Atomic progress line — printed immediately so the user sees live updates
  echo "" >> "$_COUNTER"
  local n
  n=$(wc -l < "$_COUNTER" | tr -d ' ')
  if [[ "$status" == "OK" ]]; then
    printf '[%d/%d] \033[0;32m✓\033[0m %s\n' "$n" "$TOTAL" "$src"
    echo "OK" > "${_TMPDIR}/${slug}.status"
  else
    printf '[%d/%d] \033[0;31m✗\033[0m %s\n  %s\n' "$n" "$TOTAL" "$src" "$crane_out"
    echo "FAIL" > "${_TMPDIR}/${slug}.status"
  fi
}

export -f mirror_one strip_registry
export OCIR_REGISTRY _TMPDIR _COUNTER TOTAL

# ─── Parallel execution via FIFO semaphore ────────────────────────────────────

if [[ "$DRY_RUN" != "1" ]]; then
  TOTAL=$(echo "$ALL_IMAGES" | wc -l | tr -d ' ')
  _COUNTER="${_TMPDIR}/.counter"
  touch "$_COUNTER"

  # Create a FIFO semaphore with MAX_PARALLEL tokens
  _SEM="${_TMPDIR}/.sem"
  mkfifo "$_SEM"
  exec 9<>"$_SEM"
  for _ in $(seq 1 "$MAX_PARALLEL"); do printf . >&9; done

  while IFS= read -r src; do
    [[ -z "$src" ]] && continue
    read -rn1 -u9  # acquire a token (blocks when all MAX_PARALLEL slots are busy)
    (
      mirror_one "$src"
      printf . >&9   # release token when done
    ) &
  done <<< "$ALL_IMAGES"

  wait  # wait for all background jobs to finish
  exec 9>&-

  # ─── Collect results ──────────────────────────────────────────────────────
  FAILED=()
  SUCCESS=()
  while IFS= read -r src; do
    [[ -z "$src" ]] && continue
    slug="$(echo "$src" | tr '/:.@' '____')"
    status_file="${_TMPDIR}/${slug}.status"
    if [[ -f "$status_file" ]] && [[ "$(cat "$status_file")" == "OK" ]]; then
      SUCCESS+=("$src")
    else
      FAILED+=("$src")
    fi
  done <<< "$ALL_IMAGES"
fi

# ─── Generate values-ocir.yaml ────────────────────────────────────────────────

section "Writing ${OUTPUT_VALUES}"

# Update only the imageRegistry values in values-ocir.yaml.
# The URL/ingress sections are preserved as-is (user fills those in manually).
if [[ -f "$OUTPUT_VALUES" ]]; then
  # Replace the _ocir anchor value and all imageRegistry / repository lines
  # that contain an OCIR host pattern.
  python3 - "$OUTPUT_VALUES" "$OCIR_REGISTRY" << 'PYEOF'
import sys, re

path, registry = sys.argv[1], sys.argv[2]
host = registry.split('/')[0]  # e.g. ap-hyderabad-1.ocir.io

content = open(path).read()

# Update the _ocir anchor
content = re.sub(
    r'(_ocir:\s*&ocir\s*")[^"]*(")',
    lambda m: m.group(1) + registry + m.group(2),
    content
)
# Update imageRegistry values that look like OCIR
content = re.sub(
    r'(imageRegistry:\s*")[^"]*\.ocir\.io[^"]*(")',
    lambda m: m.group(1) + registry + m.group(2),
    content
)
# Update repository lines that start with an OCIR host/namespace prefix.
# Only replace host/namespace/ — preserve the image org/name that follows.
# e.g. "old.ocir.io/ns/timberio/vector" → "new.ocir.io/ns/timberio/vector"
content = re.sub(
    r'(repository:\s*")[^"]*\.ocir\.io/[^"/]+/',
    lambda m: m.group(1) + registry + '/',
    content
)
# Update registry lines that are OCIR host
content = re.sub(
    r'(registry:\s*")[^"]*\.ocir\.io[^"]*(")',
    lambda m: m.group(1) + registry + m.group(2),
    content
)
open(path, 'w').write(content)
print(f"Updated imageRegistry to: {registry}")
PYEOF
else
  warn "values-ocir.yaml not found — creating minimal version"
  cat > "$OUTPUT_VALUES" << EOF
# values-ocir.yaml — generated by oci/mirror-to-ocir.sh
# Fill in the URL/ingress sections. See values-ocir.yaml.example for reference.
_ocir: &ocir "${OCIR_REGISTRY}"
global:
  imageRegistry: "${OCIR_REGISTRY}"
hyperswitch-app:
  global:
    imageRegistry: "${OCIR_REGISTRY}"
  hyperswitch-ucs:
    global:
      imageRegistry: "${OCIR_REGISTRY}"
hyperswitch-control-center:
  global:
    imageRegistry: "${OCIR_REGISTRY}"
hyperswitch-monitoring:
  global:
    imageRegistry: "${OCIR_REGISTRY}"
EOF
fi

info "Written: $OUTPUT_VALUES"

# ─── Summary ──────────────────────────────────────────────────────────────────

if [[ "$DRY_RUN" != "1" ]]; then
  section "Summary"
  echo "  Mirrored : ${#SUCCESS[@]}"
  echo "  Failed   : ${#FAILED[@]}"

  if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo ""
    warn "Failed images (re-run the script or mirror manually):"
    printf '    %s\n' "${FAILED[@]}"
  fi
fi

echo ""
echo "Next steps:"
echo ""
echo "  1. Create pull secret (once per namespace):"
echo "       kubectl create secret docker-registry ocir-secret \\"
echo "         --namespace hyperswitch \\"
echo "         --docker-server=${OCIR_HOST} \\"
echo "         --docker-username='${OCIR_NAMESPACE}/<oci-username>' \\"
echo "         --docker-password='<oci-auth-token>' \\"
echo "         --dry-run=client -o yaml | kubectl apply -f -"
echo ""
echo "  2. Install:"
echo "       helm install hyperswitch charts/incubator/hyperswitch-stack \\"
echo "         --namespace hyperswitch \\"
echo "         -f oci/values-ocir.yaml \\"
echo "         --set 'hyperswitch-app.server.ingress.className=nginx' \\"
echo "         --set 'hyperswitch-web.ingress.className=nginx' \\"
echo "         --wait --timeout 15m"
echo ""
echo "  3. After any chart version bump, re-run to mirror new images:"
echo "       ./oci/mirror-to-ocir.sh"
