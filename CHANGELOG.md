# Changelog

All notable changes to HyperSwitch-Helm will be documented here.

- - -

## [hyperswitch-encryption-service-0.1.12] - 2026-09-09

### 📚 Documentation

- Add `# --` descriptions and `@section -- Encryption Service Secrets` annotations to every
  secret-bearing field in `values.yaml` (TLS certs, Postgres SSL root CA, local master key,
  internal/external Postgres passwords), and switch `README.md.gotmpl` to the HTML-table values
  renderer already used by `hyperswitch-app` so those fields render under a dedicated
  "Encryption Service Secrets" section instead of the flat default table.

## [hyperswitch-card-vault-0.1.8] - 2026-09-09

### 📚 Documentation

- Add `# --` descriptions and `@section -- Card Vault Secrets` annotations to every secret-bearing
  field in `values.yaml` (locker/tenant keys, database password, AWS/Vault/TLS backend secrets,
  custodian unlock keys), and switch `README.md.gotmpl` to the HTML-table values renderer already
  used by `hyperswitch-app` so those fields render under a dedicated "Card Vault Secrets" section
  instead of the flat default table.

## [hyperswitch-stack-0.2.28] - 2026-09-09

### 🚜 Refactor

- Graduate `hyperswitch-stack` out of `charts/incubator` to `charts/` (incubator graduation,
  phase 3). The incubator is now empty; `ct.yaml`, the release workflow and the docs/scripts that
  referenced `charts/incubator` are simplified back to a single `charts/` location.
- Refresh dependency pins to the graduated chart versions: `hyperswitch-app` 1.3.1 (was 1.2.1),
  `hyperswitch-web` 0.2.16 (was 0.2.12), `hyperswitch-monitoring` 0.1.8 (was 0.1.6),
  `hyperswitch-control-center` 1.1.2 (was 1.1.0).
- Align default values with the versions the pinned subcharts ship: SDK version 0.133.0
  (was 0.129.0, set in `hyperswitch-web` autoBuild, `hyperswitch-app.services.sdk` and
  `hyperswitch-control-center.dependencies.sdk`), control center image tag v1.38.7 (was v1.38.2),
  and card vault image v0.7.0 (was the dev build v0.6.5-dev).
- Remove dead overrides that no chart version ever read (rendered manifests are unchanged):
  `hyperswitch-web.image.pullPolicy` (the web chart has no top-level `image` key; the live
  `autoBuild.pullPolicy` already defaults to `IfNotPresent`) and
  `hyperswitch-app.hyperswitch-card-vault.server.tenant_secrets.hyperswitch` (the card vault chart
  reads top-level `tenant_secrets.public.*`, and its default carries the same master key).

## [hyperswitch-app-1.3.1] - 2026-09-09

### 🚜 Refactor

- Graduate `hyperswitch-app` out of `charts/incubator` to `charts/` (incubator graduation,
  phase 2). Only `hyperswitch-stack` remains in the incubator, moving in phase 3 once this
  version is released.
- Refresh dependency pins to the phase-1 graduated versions: `hyperswitch-card-vault` 0.1.7
  (was 0.1.4) and `hyperswitch-ucs` 0.1.8 (was 0.1.2).
- Drop the stale `hyperswitch-ucs.config.connectors` override, which was a verbatim copy of the
  UCS 0.1.2 chart defaults (including live Adyen endpoints). Newer UCS charts ship connector URLs
  in per-environment config files selected by `config.server.run_env`, and this leftover override
  would have injected the old URLs as `CS__CONNECTORS__*` environment variables on top of them.
  Only affects releases that enable `hyperswitch-ucs` (disabled by default).

## Incubator graduation, phase 1 - 2026-09-09

Charts are moving out of `charts/incubator` in dependency order (leaves first), with a release
between phases so each dependent chart can pin versions already published from the new location.
Phase 1 graduates the six leaf charts to `charts/`; phase 2 is `hyperswitch-app` (after these
release), phase 3 is `hyperswitch-stack` (after `hyperswitch-app` releases). No template or values
changes - version bumps mark the first release cut from the new location:

- `hyperswitch-card-vault` 0.1.7
- `hyperswitch-ucs` 0.1.8
- `hyperswitch-web` 0.2.16
- `hyperswitch-monitoring` 0.1.8
- `hyperswitch-control-center` 1.1.2
- `hyperswitch-encryption-service` 0.1.11

Tooling now covers both locations while the move is in progress: `ct.yaml` lists both chart dirs,
helm-docs searches from `charts/`, and the release workflow packages `charts/*` and
`charts/incubator/*`.

## [hyperswitch-stack-0.2.27] - 2026-09-01

### 🚜 Refactor

- Move the `hyperswitch-ucs` dependency out of `hyperswitch-stack` and into `hyperswitch-app`, since
  it is a router-side concern and standalone `hyperswitch-app` deployments had no way to enable it.
  **Breaking for values**: anything set under the top-level `hyperswitch-ucs:` key must move to
  `hyperswitch-app.hyperswitch-ucs:`. The chart still ships disabled by default
  (`hyperswitch-app.hyperswitch-ucs.enabled: false`), so no running deployment changes.

## [hyperswitch-app-1.3.0] - 2026-09-01

### 🚀 Features

- Add `hyperswitch-ucs` as a dependency (`condition: hyperswitch-ucs.enabled`, default `false`), so
  the Unified Connector Service can be deployed alongside a standalone `hyperswitch-app` release and
  not only through `hyperswitch-stack`. Configuration is unchanged from the values previously set
  under `hyperswitch-stack`'s `hyperswitch-ucs:` key.

## [hyperswitch-app-1.2.1] - 2026-08-27

### 🐛 Bug Fixes

- *(initDB)* Install diesel_cli 2.x in the migration Job instead of relying on an image pinned to
  diesel 1.4.1. The older CLI ignores the `run_in_transaction = false` marker that the
  `CREATE INDEX CONCURRENTLY` migrations carry, so it stopped at the first one and left the schema
  part-applied - the API then failed with errors like
  `column merchant_account.network_tokenization_credentials does not exist`. The Job also now runs
  under `set -e`, so a migration failure fails the release instead of being reported as success.
- *(postgresql)* Point the replica database pool at the primary when the release has no read
  replica. With `architecture: replication` and `readReplicas.replicaCount: 0` the chart pointed it
  at a `-read` Service with no endpoints, and the router failed to boot on
  `failed to create replica pool ... Connection refused`.
- *(superposition)* Wire the bundled subchart to this release's PostgreSQL and apply the
  Superposition global schema, so it no longer crash-loops on
  `Failed to find a type oid for superposition.org_status`. The schema is fetched from the
  superposition repository at `superpositionDB.migration.version`, the same way `initDB` pulls the
  hyperswitch migrations at `services.router.version`. See the new `superpositionDB` values.
- *(superposition)* Default `superposition.enabled` to `false`. Without its global schema the
  service still answers `/health` with 200, so it reported Healthy to Kubernetes while every API
  call returned 500 - shipping that enabled by default hid the failure. `hyperswitch-stack`
  enables it together with `superpositionDB`, which applies the schema.

### 🚀 Features

- *(superpositionFallback)* Add `source: fetch` (now the default), where an init container downloads
  `config/superposition_seed.toml` from the hyperswitch repo at the running router version. The
  previous behaviour is still available as `source: configMap`.

## [hyperswitch-stack-0.2.26] - 2026-08-27

### 🚀 Features

- Enable `hyperswitch-ucs` by default.
- Enable the Superposition seed fallback by default, so a default install comes up without any
  manual preparation.

### 🚜 Refactor

- Stop pinning the router, consumer, producer and drainer image versions in the stack values: they
  must track the `hyperswitch-app` dependency, whose config files they have to match.

- - -

## [0.1.3] - 2024-09-30

### 🚀 Features

- Add istio gateway, virtual service, destination rule and alb ingress for traffic control (#94)
- Add keymanager to helm (#100)

### 🚜 Refactor

- *(helm)* Using TOML for configuring hyperswitch backend instead of environment variables (#90)
- Update istio helm index (#95)
- Update packages for hyperswitch-istio (#96)
- Update istio helm package index (#97)
- Update helm v0.1.0 for sdk bug (#106)

### Helm

- Update version for hyperswitch-app, control-center, web (#98)

### Release

- Update latest hyperswitch stable release V1.110.0 (#103)
- Update latest hyperswitch stable release v1.111.0 (#107)

## [0.1.2] - 2024-04-04

### 🐛 Bug Fixes

- *(sdk-demo)* Fix hyperloader js url in demo app (#88)

<!-- markdownlint-disable MD024 -->
## [0.1.2] - 2024-04-04
<!-- markdownlint-enable MD024 -->

### 🚜 Refactor

- Replace hardcoded value with release name in NOTES.txt (#79)

### Helm

- Create and package new version v0.1.1
- Create and package new version v0.1.1 (#77)
- Update version for helm-stack (#82)
- Add support to configure secrets manager at runtime (#84)
- Update version in deployment.yaml (#85)
- Create version v0.1.2 (#86)
- Move common secrets to hyperswitch-secrets (#87)

## [0.1.1] - 2024-03-21

### Helm


