# Router services: OLAP and Payment Method Modular

A guide to running the OLAP and payment-method-modular services from `hyperswitch-helm`.

- [What this is](#what-this-is)
- [How it works](#how-it-works)
- [Quick start](#quick-start)
- [Deployment models](#deployment-models)
- [Values reference](#values-reference)
- [Superposition](#superposition)
- [Verifying a deployment](#verifying-a-deployment)
- [Test results](#test-results)
- [Reproducing the tests](#reproducing-the-tests)
- [Known issues](#known-issues)
- [What changed in the chart](#what-changed-in-the-chart)

---

## What this is

Hyperswitch runs three variations of the same router binary:

| Service | Serves | Database | Config difference |
| --- | --- | --- | --- |
| **main router** | everything else | primary (read/write) | the chart's `server.configs` |
| **olap** | `/olap/*` — read and analytics traffic | **read replica for both handles** | `master_database.pool_size: 5` |
| **paymentMethodModular** | `/v1/payment-methods`, `/v1/payment-method-sessions`, `/v1/customers`, `/v1/proxy` | primary (read/write) | `micro_services.payment_methods_prefix`, `trace_header`, and friends |

They are the **same image and the same chart**. Nothing about OLAP or PMM is a different application —
the behaviour difference comes entirely from configuration. This is exactly how they run internally:
`hyperswitch-infra/argo-sandbox/apps/sandbox/hyperswitch-app-olap.yaml` and
`.../hyperswitch-payment-method-modular.yaml` both install `charts/incubator/hyperswitch-app`
unchanged, with a values overlay on top.

The chart now supports that natively, in two shapes: **all three routers in one Helm release**
(simplest, one database and one Redis), or **one release per service** (independent image versions
and rollouts, which is what sandbox and production do).

## How it works

The router pod spec lives in exactly one place, `templates/router/_router-shared.tpl`. Three thin
template files call it:

```
templates/router/
  _router-shared.tpl                 the pod spec, service, HPA, ingress, analysis template, istio
  deployment.yaml                    main router  -> include ... (dict "root" . "key" "")
  olap.yaml                          olap         -> include ... (dict "root" . "key" "olap")
  payment-method-modular.yaml        pmm          -> include ... (dict "root" . "key" "paymentMethodModular")
```

Because the spec is shared, the three routers cannot drift apart when the chart is updated.

### What each service renders

| Object | When |
| --- | --- |
| Deployment (or Rollout) | always |
| Service | always |
| HorizontalPodAutoscaler | `<service>.autoscaling.enabled` |
| Ingress | `<service>.ingress.enabled` |
| VirtualService + DestinationRule | `<service>.istio.enabled` |
| AnalysisTemplate | Argo Rollouts + canary analysis enabled |

There is **no ConfigMap, Secret or ServiceAccount per service.** Each one reuses the release's
`<release>-hyperswitch-configs`, `<release>-hyperswitch-secrets` and router ServiceAccount.

### Config layering

A service's `configs` block is merged over `server.configs` and rendered as **inline `env:`** on its
pods. Kubernetes gives `env` precedence over `envFrom`, so the shared ConfigMap supplies everything
else and the service's deltas win:

```yaml
envFrom:
  - configMapRef: {name: <release>-hyperswitch-configs}   # shared base
  - secretRef:    {name: <release>-hyperswitch-secrets}   # shared base
env:                                                       # the service's deltas
  - {name: ROUTER__MASTER_DATABASE__HOST,      value: <release>-postgresql-read}
  - {name: ROUTER__REPLICA_DATABASE__HOST,     value: <release>-postgresql-read}
  - {name: ROUTER__MASTER_DATABASE__POOL_SIZE, value: "5"}
```

`_secret` values are **not** supported in a delta — they would sit in plaintext in the pod spec. Use
`_secretRef`, which is what the production PMM overlay already does.

### Resource names

| | Main | OLAP | PMM |
| --- | --- | --- | --- |
| Deployment / Service | `<release>-hyperswitch-server` | `<release>-hyperswitch-olap-server` | `<release>-hyperswitch-payment-method-modular-server` |
| Ingress | `…-server-ingress` | `…-olap-server-ingress` | `…-payment-method-modular-server-ingress` |
| VirtualService / DestinationRule | `…-server-vs` / `-dr` | `…-olap-server-vs` / `-dr` | `…-payment-method-modular-server-vs` / `-dr` |

PMM's name is 41 characters before the release prefix, so a release name longer than 21 characters
is truncated at Kubernetes' 63-character limit — set `paymentMethodModular.fullnameOverride` there.

### The OLAP write guardrail

`olap.database.useReplicaForMaster: true` (the default) points **both** database handles at the read
replica. A write attempted behind `/olap` fails at the replica instead of reaching the writer:

```
ERROR:  cannot execute CREATE TABLE in a read-only transaction
```

This is read-only *by endpoint, not by credential* — the database user is unchanged. If the release
has no read replica (`postgresql.readReplicas.replicaCount: 0`, or `externalPostgresql.readOnly`
disabled) the primary is used instead so the service still starts, and `helm install` prints a
warning saying writes are not blocked.

## Quick start

One release with all three routers, on a local cluster:

```bash
# 1. Superposition fallback seed (see the Superposition section for why)
curl -sfLO https://raw.githubusercontent.com/juspay/hyperswitch/v1.126.0/config/superposition_seed.toml
kubectl create ns hyperswitch
kubectl create configmap superposition-seed -n hyperswitch \
  --from-file=superposition_seed.toml=superposition_seed.toml

# 2. Install
cd charts/incubator/hyperswitch-app
helm dependency build
helm install hyperswitch-v1 . -n hyperswitch \
  --set superpositionFallback.enabled=true \
  --set olap.enabled=true \
  --set paymentMethodModular.enabled=true

# 3. Check
kubectl get deploy -n hyperswitch
kubectl port-forward -n hyperswitch svc/hyperswitch-v1-hyperswitch-olap-server 8081:80 &
curl localhost:8081/health          # -> health is good
```

## Deployment models

### A. One release, several routers

Best for laptops, demos and small installs: one PostgreSQL, one Redis, one `helm upgrade`.

```bash
helm install hyperswitch-v1 . -n hyperswitch \
  --set superpositionFallback.enabled=true \
  --set olap.enabled=true \
  --set paymentMethodModular.enabled=true
```

Or in a values file:

```yaml
superpositionFallback:
  enabled: true
olap:
  enabled: true
  istio:
    enabled: true
    virtualService:
      hosts:    [hyperswitch.example.com]     # same host/gateway as istio.virtualService
      gateways: [istio-system/gateway]
paymentMethodModular:
  enabled: true
  istio:
    enabled: true
    virtualService:
      hosts:    [hyperswitch.example.com]
      gateways: [istio-system/gateway]
```

Combinations:

| You want | Values |
| --- | --- |
| all three routers | `olap.enabled=true`, `paymentMethodModular.enabled=true` |
| main + one service | one of the two flags |
| **only** olap | `olap.enabled=true`, `services.router.enabled=false` |
| **only** pmm | `paymentMethodModular.enabled=true`, `services.router.enabled=false` |

When you turn the main router off, also turn off the workers you do not want
(`services.consumer.enabled`, `services.producer.enabled`, `services.drainer.enabled`). The release's
shared ConfigMap, Secret, `router-cm` and ServiceAccount are still created, because the remaining
service needs them.

### B. One release per service

What sandbox and production do. Each service gets its own release — its own image version, rollout,
Argo sync and `helm upgrade` blast radius — and reads the datastores of the base release.

The chart does not ship ready-made overlays for this: `hyperswitch-infra` already keeps richer ones
per environment (`infra-configurations/hyperswitch-app-olap/`, `deployment-configs/hyperswitch-app-olap/`
and the payment-method-modular equivalents). Write the overlay for your environment; this is what it
has to contain.

```yaml
# olap-release.yaml — values for a second release, alongside hyperswitch-v1
baseRelease: hyperswitch-v1              # the release that owns the shared infrastructure

services:                                # router only: the workers stay with the base release,
  router:   {enabled: true}              # and a second copy would double-process the same queues
  consumer: {enabled: false}
  producer: {enabled: false}
  drainer:  {enabled: false}
initDB:
  enable: false                          # the base release owns the schema

postgresql:             {enabled: false} # datastores belong to the base release
redis:                  {enabled: false}
kafka:                  {enabled: false}
clickhouse:             {enabled: false}
mailhog:                {enabled: false}
vector:                 {enabled: false}
superposition:          {enabled: false}
hyperswitch-card-vault: {enabled: false}

externalSecretsOperator:        {enabled: false}   # fixed-name resources the base
superposition_fallback_efs:     {enabled: false}   # release already owns
superposition_fallback_cronjob: {enabled: false}

externalPostgresql:                      # OLAP: both handles on the reader (write guardrail)
  enabled: true
  primary:
    host: "{{ .Values.baseRelease }}-postgresql-read"
    auth:
      username: hyperswitch
      database: hyperswitch
      password:
        _secretRef:
          name: "{{ .Values.baseRelease }}-postgresql"
          key: password
  readOnly:
    enabled: true
    host: "{{ .Values.baseRelease }}-postgresql-read"
    auth:
      username: hyperswitch
      database: hyperswitch
      password:
        _secretRef:
          name: "{{ .Values.baseRelease }}-postgresql"
          key: password
externalRedis:
  enabled: true
  host: "{{ .Values.baseRelease }}-redis-master"
  auth: {enabled: false}

server:
  serviceAccount:
    create: false                        # reuse the base release's identity
    name: "{{ .Values.baseRelease }}-hyperswitch-router-role"
  configs:
    master_database: {pool_size: "5"}    # this release only reads

istio:
  enabled: true
  virtualService:
    hosts:    [hyperswitch.example.com]  # same host/gateway as the base release
    gateways: [istio-system/gateway]
    http:
      - name: primary
        match:   [{uri: {prefix: /olap/}}]
        rewrite: {uri: /}
        weight: 100
        timeout: 50s
        retries: {}
```

```bash
cd charts/incubator/hyperswitch-app

# base release: datastores, migrations, ServiceAccount, main router, workers
helm install hyperswitch-v1 . -n hyperswitch --set superpositionFallback.enabled=true

# the second release
helm install hyperswitch-olap . -n hyperswitch \
  -f olap-release.yaml \
  --set superpositionFallback.enabled=true
```

Host and secret-name values are templated, so `{{ .Values.baseRelease }}` resolves at render time
and the overlay follows whatever the base release is called.

For payment-method-modular the overlay is the same shape with three differences: `primary.host` is
`{{ .Values.baseRelease }}-postgresql` (it reads *and* writes), `server.configs` carries
`micro_services.payment_methods_prefix`, `trace_header` and the rest instead of the pool size, and
the VirtualService matches the four `/v1` prefixes with no rewrite.

### C. The umbrella stack

```bash
cd charts/incubator/hyperswitch-stack
helm dependency build
helm install hyperswitch-v1 . -n hyperswitch \
  --set hyperswitch-app.superpositionFallback.enabled=true \
  --set hyperswitch-app.olap.enabled=true \
  --set hyperswitch-app.paymentMethodModular.enabled=true
```

Everything under `hyperswitch-app.*` in the stack's values is the app chart's values, so the same
keys apply — there is a commented example in `charts/incubator/hyperswitch-stack/values.yaml`.

### Istio routing

Each service renders its own VirtualService. Point `hosts` and `gateways` at the same values the main
router's `istio.virtualService` uses, and Istio merges them into one route table for that host:

```yaml
olap:
  istio:
    enabled: true
    virtualService:
      hosts:    [hyperswitch.example.com]
      gateways: [istio-system/gateway]
      # default route: everything under /olap/ with the prefix stripped
      # (/olap/health -> /health)
```

> **Ordering caveat.** Istio does not guarantee rule ordering across VirtualServices bound to the
> same host. If the main router's VirtualService keeps a catch-all `/` route it can shadow the paths
> claimed here. Restrict it, or verify with:
> `istioctl proxy-config routes deploy/istio-ingressgateway -n istio-system --name http.80`

## Values reference

Both services take the same keys; only the defaults differ.

```yaml
olap:                              # or paymentMethodModular:
  enabled: false
  fullnameOverride: ""             # default <release>-hyperswitch-olap-server
  version: ""                      # empty -> services.router.version
  imageRegistry: ""                # empty -> services.router.imageRegistry
  image: ""                        # empty -> services.router.image
  imagePullPolicy: ""              # empty -> IfNotPresent
  replicas: 1                      # ignored when this service's autoscaling is on
  serviceAccountName: ""           # empty -> the release's router ServiceAccount

  database:
    useReplicaForMaster: true      # olap: true (write guardrail) | pmm: false
    masterHost: ""                 # explicit override, templated
    replicaHost: ""

  configs: {}                      # merged over server.configs, rendered as inline env

  resources: {}                    # every workload key below falls back to
  env: []                          #   server.* and then global.*
  tolerations: []
  affinity: {}
  nodeSelector: {}
  annotations: {}
  podAnnotations: {}
  labels: {}
  livenessProbe: {}
  readinessProbe: {}
  strategy: {}
  progressDeadlineSeconds: ""
  terminationGracePeriodSeconds: ""
  extraVolumes: []                 # empty -> server.extraVolumes
  extraVolumeMounts: []            # empty -> server.extraVolumeMounts

  autoscaling:
    enabled: false
    minReplicas: 2                 # pmm default: 1
    maxReplicas: 4
    targetCPUUtilizationPercentage: 80

  ingress:
    enabled: false
    className: ""
    annotations: {}
    hostname: ""
    path: /olap                    # pmm default: /v1/payment-methods
    pathType: Prefix
    tls: []

  istio:
    enabled: false
    virtualService:
      create: true
      hosts: []
      gateways: []
      http: [...]                  # olap: /olap/ + rewrite | pmm: four /v1 prefixes, no rewrite
    destinationRule:
      trafficPolicy: {}

  argoRollouts: {}                 # merged over the release-level argoRollouts block;
                                   # lists (canary steps, analysis metrics) replace, not extend
```

Two release-level keys support these services:

```yaml
baseRelease: ""                    # the base release, for the release-per-service model
superpositionFallback:
  enabled: false
  configMap: superposition-seed
  key: superposition_seed.toml
  mountPath: /local/config/superposition_seed.toml
```

Note: the main router's HPA still uses a fixed 70% CPU target and ignores
`autoscaling.targetCPUUtilizationPercentage` — long-standing chart behaviour, left untouched so no
existing install's autoscaling shifts. The olap and pmm services do honour their own setting.

## Superposition

Router v1.126.0 **requires a Superposition config source at boot**. Without one it panics:

```
thread 'main' panicked at crates/router/src/routes/app.rs:528:
Failed to initialize superposition client
```

The bundled `superposition` subchart ships **without database migrations**, so it cannot serve config
on its own (its API returns `Failed to find a type oid for superposition.org_status`). Two changes in
the chart deal with this:

**1. The endpoint follows the release.** `server.configs.superposition.endpoint` now defaults to
`""` and resolves to the Superposition of the current release:

```
http://<release>-superposition.<namespace>.svc.cluster.local:80
```

It used to be hardcoded to `hyperswitch-v1`/`hyperswitch`, which silently pointed at nothing for any
other release name or namespace. Set the key explicitly to point somewhere else.

**2. A file fallback you can actually use.** The router falls back to a local seed file when the
endpoint is unreachable. Provide it as a ConfigMap:

```bash
curl -sfLO https://raw.githubusercontent.com/juspay/hyperswitch/v1.126.0/config/superposition_seed.toml
kubectl create configmap superposition-seed -n hyperswitch \
  --from-file=superposition_seed.toml=superposition_seed.toml

helm install ... --set superpositionFallback.enabled=true
```

The chart mounts it into **every workload that runs the router binary** — router, consumer, producer,
drainer, olap and pmm — and sets `ROUTER__SUPERPOSITION__BACKUP_FILE_PATH` for you. Keep the seed
file's version in step with `services.router.version`.

If you do run a working Superposition, leave `superpositionFallback.enabled: false` and either use
the auto-resolved endpoint or set your own.

## Verifying a deployment

```bash
# what is running
kubectl get deploy -n hyperswitch

# health of each router
for svc in hyperswitch-v1-hyperswitch-server \
           hyperswitch-v1-hyperswitch-olap-server \
           hyperswitch-v1-hyperswitch-payment-method-modular-server; do
  kubectl port-forward -n hyperswitch svc/$svc 8081:80 >/dev/null 2>&1 &
  sleep 3
  echo "$svc -> $(curl -s localhost:8081/health)"
  kill %1
done

# the config each service actually got
kubectl get pod -n hyperswitch -l app=hyperswitch-v1-hyperswitch-olap-server \
  -o jsonpath='{range .items[0].spec.containers[0].env[?(@.value)]}{.name}={.value}{"\n"}{end}' \
  | grep ROUTER__

# proof of the OLAP write guardrail
kubectl exec -n hyperswitch hyperswitch-v1-postgresql-read-0 -c postgresql -- \
  bash -c 'PGPASSWORD=<pw> psql -U hyperswitch -d hyperswitch -c "CREATE TABLE probe(i int);"'
# -> ERROR: cannot execute CREATE TABLE in a read-only transaction
```

`/health` returns `health is good`. `/health/ready` also checks the card vault, so it returns 500
when `hyperswitch-card-vault` is disabled — that is expected in a slim install.

## Test results

Every scenario below was installed on a local Kubernetes cluster (OrbStack, k8s 1.30) with real
PostgreSQL (primary + one read replica) and Redis, and every router was health-checked over a
port-forward.

| # | Scenario | Result |
| --- | --- | --- |
| S1 | main router + consumer + producer, one release | 3/3 Ready · `/health` 200 |
| S2 | main + olap + pmm, one release | 5/5 Ready · 200 on all three routers |
| S3 | main + olap | Ready · 200 |
| S4 | olap alone (`services.router.enabled=false`) | Ready · 200 · base ConfigMap/Secret/SA kept · 0 orphan HPAs |
| S5 | payment-method-modular alone | Ready · 200 |
| S6 | olap as a separate release with a values overlay | Ready · 200 · wired to the base release's replica, Redis, SA and DB secret |
| S7 | umbrella `hyperswitch-stack`, both services enabled through it | 4/4 Ready · 200 on all three · endpoint resolved to `hs-stack-superposition.hs-stack…` |

Config isolation observed live in S2, with **one** ConfigMap, **one** Secret and **one**
ServiceAccount shared by all three routers:

```
olap: ROUTER__MASTER_DATABASE__HOST=hyperswitch-v1-postgresql-read
      ROUTER__MASTER_DATABASE__POOL_SIZE=5
pmm:  ROUTER__MASTER_DATABASE__HOST=hyperswitch-v1-postgresql
      ROUTER__MICRO_SERVICES__PAYMENT_METHODS_PREFIX=v1
      ROUTER__TRACE_HEADER__HEADER_NAME=x-request-id
```

Write guardrail, verified at the database: `CREATE TABLE` against the endpoint OLAP's master handle
points at is rejected with `cannot execute CREATE TABLE in a read-only transaction`, while the same
statement on the primary succeeds.

**Regression.** The rendered output of the main router was compared against the previous chart across
nine value sets — default, istio, Argo Rollouts + analysis, autoscaling, ingress + custom
ServiceAccount, external PostgreSQL/Redis, EFS + ESO + `disableInternalSecrets`, router disabled, and
global/server overrides. All byte-identical for the documented install, with one intended exception:
a release with the main router disabled no longer emits an HPA pointing at a Deployment that does not
exist.

`helm lint` passes and `helm-docs` leaves no diff.

## Reproducing the tests

```bash
# render checks (no cluster needed)
helm template hyperswitch-v1 charts/incubator/hyperswitch-app -n hyperswitch \
  --set olap.enabled=true --set paymentMethodModular.enabled=true | grep -E "^kind:|^  name:"

# regression: current tree vs the previous commit, same values
git stash                                   # or: git worktree add /tmp/base HEAD~1
helm template hyperswitch-v1 <old-chart> -n hyperswitch > /tmp/before.yaml
git stash pop
helm template hyperswitch-v1 charts/incubator/hyperswitch-app -n hyperswitch > /tmp/after.yaml
diff /tmp/before.yaml /tmp/after.yaml

# lint and docs
helm lint charts/incubator/hyperswitch-app --set olap.enabled=true --set paymentMethodModular.enabled=true
task update-readme
```

For a cluster run, use the Quick start above and then the commands in
[Verifying a deployment](#verifying-a-deployment).

## Known issues

These are pre-existing and independent of the router services; each one bit during testing.

| Issue | Effect | Workaround |
| --- | --- | --- |
| The `superposition` subchart ships no DB migrations | It can never serve config, so the router cannot boot against it | `superpositionFallback.enabled=true` with the seed ConfigMap |
| `Chart.dev.yaml` dependencies have no `version:` | `helm dependency build` refuses the dev wiring | Add the local chart versions to the dependency entries |
| `hyperswitch-stack` pins `services.router.version: v1.121.0` | Older than the app chart's appVersion v1.126.0; that build also rejects the chart's own connector list (`revolv3`, `tsys_transit`) | Override the four `services.*.version` keys |
| `analytics.clickhouse.password: null` does not remove the secret ref under the umbrella | Every router fails with `secret "clickhouse" not found` when clickhouse is disabled | Keep clickhouse enabled, or pre-create the `clickhouse` secret |
| The DB migration job logs `CREATE INDEX CONCURRENTLY cannot run inside a transaction block` but exits 0 | A failed migration is invisible unless you read the job logs | Check the job's logs after install |

## What changed in the chart

`hyperswitch-app` 1.1.8 → **1.2.0**, `hyperswitch-stack` 0.2.24 → **0.2.25**.

**New**

| File | Purpose |
| --- | --- |
| `templates/router/_router-shared.tpl` | The router pod spec, service, HPA, ingress, analysis template and istio objects, as named templates |
| `templates/router/olap.yaml` | The OLAP service's objects |
| `templates/router/payment-method-modular.yaml` | The PMM service's objects |

**Modified**

- `templates/router/{deployment,service,hpa,ingress,analysistemplate}.yaml` — now thin wrappers
  around the shared templates, so all routers share one spec.
- `templates/_helpers.tpl` — `hyperswitch.anyRouterEnabled`, `superposition.url`, the fallback volume
  helpers, and `tpl` support for external hosts, the ServiceAccount name and `_secretRef` names.
- `templates/misc/{configmap,secrets}.yaml`, `templates/router/{configmap,sa}.yaml` — gated on
  "any router enabled" rather than the main router, so a service can run on its own.
- `templates/{consumer,producer,drainer}/deployment.yaml` — `extraVolumes` / `extraVolumeMounts` and
  the Superposition fallback mount.
- `templates/NOTES.txt` — lists the running services and warns when the write guardrail has silently
  fallen back to the primary.
- `values.yaml` — `olap`, `paymentMethodModular`, `baseRelease`, `superpositionFallback`,
  `server.extraVolumes` / `extraVolumeMounts`, and the templated superposition endpoint.
- `charts/incubator/hyperswitch-stack/values.yaml` — a commented example of enabling both services.
