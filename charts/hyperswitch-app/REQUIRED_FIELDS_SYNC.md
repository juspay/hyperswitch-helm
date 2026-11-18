# Disabled required-fields deployment definitions

Step 15 adds templates to the actual `hyperswitch-app` chart. The default adds **no
resources and no serving configuration**. `enabled: true` or any mode other than
`disabled` is a render error. `renderSuspended: true` is for local review only: it
always produces a suspended PostSync Job, a disabled H command configuration and
deny-all networking. There is no values switch that permits execution.

## Implemented definitions

The existing main-router image helper supports an optional `services.router.digest`.
Without it the existing tag behavior is unchanged. A suspended definition requires
that digest and the same digest in H's `ReleaseIntent.executor_image`; the serving
Deployment/Rollout and executor use the same helper. Other router variants retain
their existing image behavior and receive no executor or attestation injection.

`requiredFieldsSync` accepts explicit registration, release intent, command and input
profile JSON plus a deployment evidence envelope. These are **nonsecret artifacts**;
credentials belong in a separately provisioned executor-only Secret reference.
H remains the strict semantic parser/renderer/authority boundary. Helm checks structural
identity and immutable byte bindings, not the correctness of compiled inputs or grants.
The generation, plan, physical target registration, complete declared reader membership,
policy/catalog/settings/build/input hashes, verifier image/source/case hashes and retained
recovery image are bound to an immutable, content-named ConfigMap and Job name.

The main serving pod and executor mount the same ConfigMap. Serving gets only a disabled
mode and an attestation-profile path; H compares that profile with effective loaded
settings. The ConfigMap alone does **not** prove those settings match, that every reader
uses them, or that observations have authenticated pod/image provenance.

The Job has one completion, no retries, `restartPolicy: Never`, no TTL and no hook-delete
policy. Reusing an intent does not delete/recreate its old Job. A changed intent has a
new content name, but cannot execute while suspended. This avoids encoding blind retries
as Argo hook cleanup. Actual reconciliation/resume dispatch remains unavailable.

The separate ServiceAccount has no ambient token. Only the executor mounts its projected
token and dedicated credential Secret. RBAC permits get/update of one preprovisioned
Lease and read-only namespaced rollout/traffic discovery; no Lease creation/deletion,
Secret API reads, exec, wildcard roles or broad existing router credentials are added.
The companion gets no credential, token, executor report or journal mount. UIDs differ;
process sharing is off, privilege escalation is off and root filesystems are read-only.
NetworkPolicy is pod-scoped and denies all traffic; it cannot prove per-container
authorization or defeat an injected workload identity. Admission, effective RBAC, token
audience, filesystem access and credential isolation require an actual disposable cluster.

## Pending implementation/certification

This is an intentionally non-runnable definition. Before any future activation:

- Implement/certify H's still-closed production target, image, storage, safety and report
  collector provisioners. A JSON certificate identifier cannot create those capabilities.
- Issue current monotonic intents from one durable authority per physical target. A
  rollback gets a newer generation. Argo UID/Git revision/image tags are provenance only.
- Enforce writer exclusion for UI/API, ordinary router, seeders, automation, manual restore,
  administrators and breakglass, including old requests that can still commit. A Lease is
  not this barrier.
- Discover all Deployments/Rollouts, services, EndpointSlices, mesh weights, old pods and
  connections, scaling and cross-region/custom/v2 readers. Hold that gate through mutation.
- Package the actual pinned W/U runner into a digest-certified image. The proposed image
  location `/verifier/playwright-tests/required-fields-verifier/run.cjs` corresponds to the
  existing W entry point, but its OCI build is unavailable. The current runner needs a
  registered source/build fixture, provisioned response/case inputs, browser assets and
  an H exchange/report bridge; the template does **not** supply that bridge. No dummy
  companion result or no-op runner is substituted. Browser confirm must stay intercepted.
- Provision immutable journal/receipts/baseline and recovery image outside Job lifetime,
  least-privilege access and independent recovery reads. EmptyDir is scratch only.
- Validate V1 persisted state, V2 each pod cache, V3 exact browser responses and old SDK
  snapshots, and V4 actual fallback publication/mount/startup. Refresh last-good memory is
  a different check. Wire durable report ingestion and delivery alerts before cleanup.
- Exercise both manual and automatic Argo syncs, duplicate hooks, interrupted jobs, stale
  intents, scaling, old executors and pre-feature rollback in an authorized disposable
  environment. Do not auto-roll back application code against an unknown SP commit.

No hosted target, writer credentials or endpoints are supplied. InfraSwitch, v2, custom,
playground, OLAP, ancillary workloads and unverified regions are not writers.

## Local checks

`tests/required_fields_sync/test_render.py` runs only `helm template` and `yq`. Set
`RF_DEPLOYMENT_FIXTURE` to a private disposable directory registered by `owner.json`
with nonempty `owner`, exact absolute `root` and `cleanup_scope`, and `hosted_target: null`.
The test creates only child directories there; retain or remove only those owned children.
`RF_CHART` optionally selects an isolated copy of a selected tag with this patch applied.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 tests/required_fields_sync/test_render.py -v
helm lint --strict charts/hyperswitch-app
```

These commands do not install dependencies or access a cluster. Use already available,
exact dependency archives; do not replace missing dependencies with empty charts. The
fixture JSON demonstrates transport and refusal, not H profile semantic acceptance.
See H `docs/required_fields_sync_contracts/deployment-v1/` for executed checks.

Changes are on the existing local branch; selected I tags are unchanged. Generated Helm docs
are checked locally. Publish/version review, image certification and platform acceptance remain
separate gates.
