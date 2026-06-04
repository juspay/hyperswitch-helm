# Deploying Hyperswitch on OCI / OKE

This guide covers deploying the `hyperswitch-stack` Helm chart on Oracle Kubernetes Engine
(OKE) without any AWS dependencies, using OCI Container Registry (OCIR) to avoid Docker
Hub rate limits.

---

## Table of Contents

1. [Why OCIR mirroring?](#1-why-ocir-mirroring)
2. [Why node-level auth?](#2-why-node-level-auth)
3. [Prerequisites](#3-prerequisites)
4. [One-time setup](#4-one-time-setup)
   - [4.1 OCI credentials](#41-oci-credentials)
   - [4.2 Mirror images to OCIR](#42-mirror-images-to-ocir)
   - [4.3 Authenticate OKE nodes to OCIR](#43-authenticate-oke-nodes-to-ocir)
   - [4.4 TLS certificates](#44-tls-certificates)
5. [Deploy](#5-deploy)
6. [Upgrade / version bump](#6-upgrade--version-bump)
7. [Troubleshooting image pull errors](#7-troubleshooting-image-pull-errors)

---

## 1. Why OCIR mirroring?

OKE worker nodes egress through a shared NAT gateway, so every `docker pull` from every
node counts against the **same Docker Hub anonymous quota** (100 pulls / 6 hours per IP).
A fresh Hyperswitch install pulls ~36 images across 2 nodes — that exhausts the quota in
minutes, causing `ErrImagePull: TOOMANYREQUESTS`.

**The fix:** mirror all images to your private OCI Container Registry once, then configure
Helm to pull from OCIR instead of Docker Hub. OCIR is within OCI's network — pulls are
free, fast, and have no rate limits.

`oci/mirror-to-ocir.sh` automates the entire mirror process:

- Renders the full Helm chart with `helm template` to discover **every** image, including
  operator-injected images passed as CLI flags (e.g. `prometheus-config-reloader`,
  `thanos`) that do not appear in `image:` YAML fields.
- Uses `crane copy --platform linux/amd64` to copy images directly between registries
  without a local pull. The `--platform` flag is critical when running on Apple Silicon
  (arm64 Mac) targeting amd64 OKE nodes — `docker pull` without it pushes an arm64 binary
  that fails at runtime with `exec format error`.
- Updates `values-ocir.yaml` with the correct `global.imageRegistry` so all chart pulls
  use OCIR automatically.

---

## 2. Why node-level auth?

The obvious alternative is Kubernetes `imagePullSecrets`. The problem is that
`imagePullSecrets` set in Helm chart values only reach pods managed by that chart's
templates. They do **not** reach:

- Helm pre-install / post-install **hook Jobs** (e.g. admission webhook init, DB migration)
- Sidecar containers **injected by operators** at admission time
- Pods in other namespaces

This means you hit `denied: Anonymous users are only allowed read access` on hook pods
even when the main deployment pods work fine.

`oci/ocir-node-auth.yaml` solves this at the node level:

- Deploys a **DaemonSet** that runs on every OKE node.
- Uses `nsenter -t 1 -m` to write OCIR credentials into the host's cri-o auth paths
  (`/run/containers/auth.json`, `/root/.docker/config.json`, `/etc/crio/auth.json`).
- Uses `nsenter` (not a hostPath volume mount) because Oracle Linux 8 enforces SELinux —
  files written from a container process get the wrong SELinux label and cri-o silently
  ignores them. Running via `nsenter` in PID 1's mount namespace assigns the correct host
  label.
- Writes a cri-o config drop-in (`/etc/crio/crio.conf.d/50-ocir-auth.conf`) that sets
  `global_auth_file`, then restarts cri-o to load it.
- On node reboot, Kubernetes restarts the DaemonSet pod which re-writes the credentials
  automatically.

Once deployed, **every pod on every node** can pull from OCIR without any
`imagePullSecrets`, including future pods in new namespaces.

> **Preferred alternative (zero-maintenance):** Configure an IAM Instance Principal policy
> so OKE nodes authenticate to OCIR using their OCI identity — no secrets or DaemonSet
> needed. See [IAM Instance Principal](#iam-instance-principal-recommended) below.

---

## 3. Prerequisites

| Tool | Version | Install |
|---|---|---|
| OCI CLI | 3.x | `brew install oci-cli` |
| kubectl | 1.28+ | `brew install kubectl` |
| Helm | 3.12+ | `brew install helm` |
| crane | any | `brew install crane` |
| task | any | `brew install go-task` |

Verify OCI CLI is configured:
```bash
oci iam user get --user-id <your-user-ocid>
```

Get your tenancy object-storage namespace (needed for OCIR):
```bash
oci os ns get
```

---

## 4. One-time setup

### 4.1 OCI credentials

Create an **OCI Auth Token** (used as the OCIR password):

```
OCI Console → top-right avatar → User Settings → Auth Tokens → Generate Token
```

Copy it immediately — it is shown only once.

Log crane into OCIR:
```bash
crane auth login <region>.ocir.io \
  -u '<tenancy-namespace>/<oci-username>' \
  -p '<oci-auth-token>'
```

Log Docker Hub in (prevents anonymous pull rate limits during mirroring):
```bash
docker login
# or: export DOCKERHUB_USERNAME=... DOCKERHUB_TOKEN=...
```

### 4.2 Mirror images to OCIR

```bash
export OCIR_REGION=<region>          # e.g. ap-hyderabad-1
export OCIR_NAMESPACE=<namespace>    # from: oci os ns get

./oci/mirror-to-ocir.sh
```

This mirrors all ~36 images and updates `global.imageRegistry` in `values-ocir.yaml`.
Takes ~3–5 minutes on first run; subsequent runs skip already-mirrored images.

After the script finishes, replace the `<LOAD_BALANCER_IP>` placeholder in
`values-ocir.yaml` with your nginx ingress controller's external IP:

```bash
LB_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

sed -i '' "s/<LOAD_BALANCER_IP>/${LB_IP}/g" oci/values-ocir.yaml
```

> **nip.io:** `sub.<IP>.nip.io` resolves to `<IP>` via public DNS — no domain registration
> needed. E.g. `api.1.2.3.4.nip.io` → `1.2.3.4`.

### 4.3 Authenticate OKE nodes to OCIR

#### IAM Instance Principal (recommended)

Grant OKE nodes permission to pull from OCIR using their OCI instance identity — no
Kubernetes secrets needed.

**Step 1 — Create a Dynamic Group** (OCI Console → Identity → Domains → Default →
Dynamic Groups → Create):

```
Name: oke-nodes-<cluster-name>
Matching rule: All {instance.compartment.id = '<compartment-ocid>'}
```

> The matching rule must be set via the Console's **Matching rules** tab. The OCI CLI
> `dynamic-group update --matching-rule` command does not work on Identity Domain
> tenancies (the field stays `null`).

**Step 2 — Create an IAM Policy** (OCI Console → Identity → Policies, root compartment):

```
Name: oke-ocir-pull
Statement: Allow dynamic-group oke-nodes-<cluster-name> to read repos in tenancy
```

Wait 1–2 minutes for propagation. Verify:

```bash
kubectl run test-pull --rm -it --restart=Never \
  --image=<region>.ocir.io/<namespace>/bitnamilegacy/redis:7.2.3-debian-11-r2 \
  --namespace hyperswitch \
  -- echo "instance principal works"
```

#### Node-level DaemonSet (fallback)

If Instance Principal is not available or not yet propagated, deploy the node-auth
DaemonSet instead.

Create the pull secret in `kube-system`:

```bash
kubectl create secret docker-registry ocir-secret \
  --namespace kube-system \
  --docker-server=<region>.ocir.io \
  --docker-username='<tenancy-namespace>/<oci-username>' \
  --docker-password='<oci-auth-token>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Deploy the DaemonSet (substitute your OCIR registry):

```bash
export OCIR_REGISTRY=<region>.ocir.io/<tenancy-namespace>
envsubst < oci/ocir-node-auth.yaml | kubectl apply -f -

kubectl rollout status daemonset/ocir-node-auth -n kube-system
```

### 4.4 TLS certificates

Install cert-manager for automatic Let's Encrypt certificates (nip.io domains work with
HTTP-01 challenge):

```bash
helm repo add jetstack https://charts.jetstack.io && helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

Create a ClusterIssuer (replace the email):

```bash
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: <your-email>
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            ingressClassName: nginx
EOF
```

---

## 5. Deploy

```bash
kubectl create namespace hyperswitch --dry-run=client -o yaml | kubectl apply -f -

helm install hyperswitch charts/incubator/hyperswitch-stack \
  --namespace hyperswitch \
  -f oci/values-ocir.yaml \
  --wait --timeout 15m
```

After install, check all pods are running:

```bash
kubectl get pods -n hyperswitch
kubectl get ingress -n hyperswitch
```

Expected ingresses (all `nginx` class with your IP):

```
hyperswitch-hyperswitch-server-ingress      nginx   api.<IP>.nip.io         <IP>   80,443
hyperswitch-control-center                  nginx   dashboard.<IP>.nip.io   <IP>   80,443
hyperswitch-web-ingress                     nginx   checkout.<IP>.nip.io    <IP>   80,443
hyperswitch-grafana                         nginx   grafana.<IP>.nip.io     <IP>   80,443
```

---

## 6. Upgrade / version bump

After updating the chart version or pulling new upstream changes:

```bash
# 1. Update chart dependencies
helm dependency update charts/incubator/hyperswitch-stack
rm -rf charts/incubator/hyperswitch-stack/charts/hyperswitch-app/   # remove stale directory

# 2. Repackage (picks up local template changes)
task pihh

# 3. Re-mirror new images to OCIR
export OCIR_REGION=<region>
export OCIR_NAMESPACE=<namespace>
./oci/mirror-to-ocir.sh

# 4. Upgrade
helm upgrade hyperswitch charts/incubator/hyperswitch-stack \
  --namespace hyperswitch \
  -f oci/values-ocir.yaml \
  --wait --timeout 15m
```

> **Why remove the stale directory?**
> `helm dependency update` downloads `hyperswitch-app-<version>.tgz` into
> `charts/incubator/hyperswitch-stack/charts/`. If both a `hyperswitch-app/` directory
> and a `.tgz` exist, Helm loads values from both, causing type conflicts that corrupt
> the rendered YAML (e.g. `yaml: line 104: did not find expected '-' indicator`).

---

## 7. Troubleshooting image pull errors

### `TOOMANYREQUESTS` — Docker Hub rate limit
All OKE nodes share a NAT gateway IP. Run the mirror script to move all images to OCIR.

### `denied: Anonymous users are only allowed read access`
Nodes are not authenticated to OCIR. Set up [Instance Principal](#iam-instance-principal-recommended)
or deploy the [node-auth DaemonSet](#node-level-daemonset-fallback).

### `exec format error` — architecture mismatch
Image was mirrored from an Apple Silicon Mac without `--platform linux/amd64`.
Re-mirror the affected image:
```bash
crane copy --platform linux/amd64 <source-image> <ocir-dest-image>
```
Verify what's in OCIR:
```bash
crane config <ocir-image> | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print('arch:', d.get('architecture'))"
```

### `short name mode is enforcing` — cri-o rejects images without registry prefix
Oracle Linux 8 cri-o refuses short image names (e.g. `timberio/vector`). The affected
charts are overridden in `oci/values-ocir.yaml` with full OCIR paths. If a new image appears
with this error, add a similar override for the relevant chart.

### `Repository Name Unknown` — image not mirrored
An operator-injected image was not mirrored. Re-run the mirror script:
```bash
./oci/mirror-to-ocir.sh
```
Or mirror a single image immediately:
```bash
crane copy --platform linux/amd64 <source> <region>.ocir.io/<namespace>/<repo>:<tag>
```

### Helm hook Jobs keep restarting after `helm uninstall`
Helm hook resources are not deleted on uninstall by default:
```bash
kubectl delete jobs --all -n hyperswitch
```

### ClickHouse analytics errors after reinstall
ClickHouse PVCs survive `helm uninstall`. The old schema (missing new columns) persists.
Delete the PVC to force fresh table creation:
```bash
kubectl scale statefulset -n hyperswitch \
  $(kubectl get statefulset -n hyperswitch -l app.kubernetes.io/name=clickhouse \
    -o jsonpath='{.items[0].metadata.name}') --replicas=0

kubectl delete pvc -n hyperswitch \
  $(kubectl get pvc -n hyperswitch | grep clickhouse | awk '{print $1}')

helm upgrade hyperswitch charts/incubator/hyperswitch-stack \
  --namespace hyperswitch -f oci/values-ocir.yaml --wait --timeout 15m
```
