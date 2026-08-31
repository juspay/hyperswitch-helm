# Changelog

All notable changes to HyperSwitch-Helm will be documented here.

- - -

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

## [0.1.2] - 2024-04-04

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


