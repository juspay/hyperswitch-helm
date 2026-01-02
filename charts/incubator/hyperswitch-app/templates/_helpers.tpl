# Define `hyperswitch.fullname` template
{{- define "hyperswitch.fullname" -}}
{{- default .Chart.Name .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch.labels` template
{{- define "hyperswitch.labels" -}}
helm.sh/chart: {{ include "hyperswitch.chart" . }}
helm.sh/version: {{ .Chart.Version | quote }}
{{- if .Chart.AppVersion }}
helm.sh/app-version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

# Define `hyperswitch.chart` template
{{- define "hyperswitch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Convert version format from v1.115.0 to v1o115o0 for Kubernetes labels
*/}}
{{- define "version.suffix" -}}
{{- . | replace "." "o" -}}
{{- end -}}

# Define `hyperswitch-server.name` template
{{- define "hyperswitch-server.name" -}}
{{- printf "%s-hyperswitch-server" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch-consumer.name` template
{{- define "hyperswitch-consumer.name" -}}
{{- printf "%s-hyperswitch-consumer" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch-producer.name` template
{{- define "hyperswitch-producer.name" -}}
{{- printf "%s-hyperswitch-producer" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch-drainer.name` template
{{- define "hyperswitch-drainer.name" -}}
{{- printf "%s-hyperswitch-drainer" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch-router-sa.name` template
{{- define "hyperswitch-router-sa.name" -}}
{{- default (printf "%s-hyperswitch-router-role" .Release.Name) .Values.server.serviceAccount.name -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments
*/}}

{{/* Generic namespace helper for components */}}
{{- define "component.namespace" -}}
{{- $component := .component -}}
{{- $override := index .Values $component "namespaceOverride" | default "" -}}
{{- if $override }}
{{- $override }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/* Drainer namespace helper */}}
{{- define "drainer.namespace" -}}
{{- include "component.namespace" (dict "Values" .Values "Release" .Release "component" "drainer") }}
{{- end }}


{{/* Redis configuration validation template */}}
{{- define "validate.redis.config" -}}
    {{- if not (or  .Values.redis.enabled .Values.externalRedis.enabled) }}
        {{-  fail
        "Both redis.enabled and externalRedis.enabled cannot be 'false' at the same time. Please, onfigure at least one Redis."
         }}
    {{- else if and  .Values.redis.enabled .Values.externalRedis.enabled }}
        {{-  fail
        "Both redis.enabled and externalRedis.enabled cannot be 'true' at the same time. Select only once please"
         }}
    {{- end }}
{{- end }}

{{/* Valide Redis configuration and */}}
{{/* select Redis host Internal or External depends on configuration */}}
{{- define "redis.host" -}}
{{- $test_redis := include "validate.redis.config" . }}
    {{- if .Values.redis.enabled }}
        {{- printf "%s-redis-master"  .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else if .Values.externalRedis.enabled }}
        {{- printf "%s" .Values.externalRedis.host -}}
    {{- end -}}
{{- end -}}

{{/* Select Redis port Internal or External depends on configuration */}}
{{- define "redis.port" -}}
    {{- printf "6379" -}}
{{- end -}}

{{/* Postgresql configuration validation template */}}
{{- define "validate.postgresql.config" -}}
    {{- if not (or  .Values.postgresql.enabled .Values.externalPostgresql.enabled) }}
        {{-  fail
        "Both postgresql.enabled and externalPostgresql.enabled cannot be 'false' at the same time. Please, onfigure at least one Postgresql."
         }}
    {{- else if and  .Values.postgresql.enabled .Values.externalPostgresql.enabled }}
        {{-  fail
        "Both postgresql.enabled and externalPostgresql.enabled cannot be 'true' at the same time. Select only once please"
         }}
    {{- end }}
{{- end }}

{{/* Valide Postgres configuration and */}}
{{/* select Postgres host Internal or External depends on configuration */}}
{{- define "postgresql.host" -}}
{{- $test_pg := include "validate.postgresql.config" . }}
    {{- if .Values.postgresql.enabled }}
        {{- printf "%s-postgresql" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
    {{- else if .Values.externalPostgresql.enabled }}
        {{- printf "%s" .Values.externalPostgresql.primary.host -}}
    {{- end -}}
{{- end -}}

{{/* Valide Postgres configuration and */}}
{{/* select Postgres Replica host Internal or External depends on configuration */}}
{{- define "postgresqlreplica.host" -}}
{{- $test_pg := include "validate.postgresql.config" . }}
    {{- if .Values.postgresql.enabled }}
        {{- printf "%s-postgresql-read" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
    {{- else if .Values.externalPostgresql.enabled }}
        {{- printf "%s" .Values.externalPostgresql.readOnly.host -}}
    {{- end -}}
{{- end -}}

{{/* Select Postgres master port Internal or External */}}
{{- define "postgresql.port" -}}
    {{- printf "5432" -}}
{{- end -}}

{{/* Select Postgres replica port Internal or External */}}
{{- define "postgresqlreplica.port" -}}
    {{- printf "5432" -}}
{{- end -}}

{{/* Select Postgres master database Internal or External */}}
{{- define "postgresql.database" -}}
    {{- if .Values.postgresql.enabled }}
        {{- printf "%s" .Values.postgresql.global.postgresql.auth.database  -}}
    {{- else if .Values.externalPostgresql.enabled }}
        {{- printf "%s" .Values.externalPostgresql.primary.auth.database -}}
    {{- end -}}
{{- end -}}

{{/* Select Postgres master username Internal or External */}}
{{- define "postgresql.username" -}}
    {{- if .Values.postgresql.enabled }}
        {{- printf "%s" .Values.postgresql.global.postgresql.auth.username  -}}
    {{- else if .Values.externalPostgresql.enabled }}
        {{- printf "%s" .Values.externalPostgresql.primary.auth.username -}}
    {{- end -}}
{{- end -}}

{{/* Select Postgres replica username Internal or External */}}
{{- define "postgresqlreplica.username" -}}
    {{- if .Values.postgresql.enabled }}
        {{- printf "%s" .Values.postgresql.global.postgresql.auth.username  -}}
    {{- else if .Values.externalPostgresql.enabled }}
        {{- printf "%s" .Values.externalPostgresql.readOnly.auth.username -}}
    {{- end -}}
{{- end -}}


{{/* Define the name for external PostgreSQL secret */}}
{{- define "externalPostgresql.secret.name" -}}
{{- printf "ext-postgresql-%s" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Define the PostgreSQL secret name based on whether internal or external PostgreSQL is enabled */}}
{{- define "postgresql.secret" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- printf "%s-postgresql" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
  {{- else if .Values.externalPostgresql.enabled -}}
    {{- include "externalPostgresql.secret.name" . -}}
  {{- end -}}
{{- end -}}

{{/* =====================================================
     POSTGRESQL PASSWORD SECRET REFERENCE HELPERS
     ===================================================== */}}

{{/* Common helper: Get default PostgreSQL secret name for internal/external */}}
{{- define "postgresql.default.secret.name" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- printf "%s-postgresql" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
  {{- else if .Values.externalPostgresql.enabled -}}
    {{- include "externalPostgresql.secret.name" . -}}
  {{- end -}}
{{- end -}}

{{/* Common helper: Check if a password config uses _secretRef */}}
{{- define "postgresql.password.uses.secretRef" -}}
  {{- $passwordConfig := . -}}
  {{- if and (kindIs "map" $passwordConfig) (hasKey $passwordConfig "_secretRef") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/* PostgreSQL Master Password Secret Name */}}
{{- define "postgresql.master.password.secret" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $passwordConfig := .Values.postgresql.global.postgresql.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.name -}}
    {{- else -}}
      {{- include "postgresql.default.secret.name" . -}}
    {{- end -}}
  {{- else if .Values.externalPostgresql.enabled -}}
    {{- $passwordConfig := .Values.externalPostgresql.primary.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.name -}}
    {{- else -}}
      {{- include "postgresql.default.secret.name" . -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* PostgreSQL Master Password Secret Key */}}
{{- define "postgresql.master.password.key" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $passwordConfig := .Values.postgresql.global.postgresql.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.key -}}
    {{- else -}}
      {{- printf "password" -}}
    {{- end -}}
  {{- else if .Values.externalPostgresql.enabled -}}
    {{- $passwordConfig := .Values.externalPostgresql.primary.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.key -}}
    {{- else -}}
      {{- printf "primaryPassword" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* PostgreSQL Master Plain Password Secret Name */}}
{{- define "postgresql.master.plainPassword.secret" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $passwordConfig := .Values.postgresql.global.postgresql.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.name -}}
    {{- else -}}
      {{- include "postgresql.master.password.secret" . -}}
    {{- end -}}
  {{- else if .Values.externalPostgresql.enabled -}}
    {{- $plainPasswordConfig := .Values.externalPostgresql.primary.auth.plainpassword -}}
    {{- if and $plainPasswordConfig (eq (include "postgresql.password.uses.secretRef" $plainPasswordConfig) "true") -}}
      {{- printf "%s" $plainPasswordConfig._secretRef.name -}}
    {{- else if and $plainPasswordConfig (not (kindIs "map" $plainPasswordConfig)) -}}
      {{- include "postgresql.default.secret.name" . -}}
    {{- else -}}
      {{- include "postgresql.master.password.secret" . -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* PostgreSQL Master Plain Password Secret Key */}}
{{- define "postgresql.master.plainPassword.key" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $passwordConfig := .Values.postgresql.global.postgresql.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.key -}}
    {{- else -}}
      {{- include "postgresql.master.password.key" . -}}
    {{- end -}}
  {{- else if .Values.externalPostgresql.enabled -}}
    {{- $plainPasswordConfig := .Values.externalPostgresql.primary.auth.plainpassword -}}
    {{- if and $plainPasswordConfig (eq (include "postgresql.password.uses.secretRef" $plainPasswordConfig) "true") -}}
      {{- printf "%s" $plainPasswordConfig._secretRef.key -}}
    {{- else if and $plainPasswordConfig (not (kindIs "map" $plainPasswordConfig)) -}}
      {{- printf "primaryPlainPassword" -}}
    {{- else -}}
      {{- include "postgresql.master.password.key" . -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* PostgreSQL Replica Password Secret Name */}}
{{- define "postgresql.replica.password.secret" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $passwordConfig := .Values.postgresql.global.postgresql.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.name -}}
    {{- else -}}
      {{- include "postgresql.default.secret.name" . -}}
    {{- end -}}
  {{- else if .Values.externalPostgresql.enabled -}}
    {{- $passwordConfig := .Values.externalPostgresql.readOnly.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.name -}}
    {{- else -}}
      {{- include "postgresql.default.secret.name" . -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* PostgreSQL Replica Password Secret Key */}}
{{- define "postgresql.replica.password.key" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $passwordConfig := .Values.postgresql.global.postgresql.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.key -}}
    {{- else -}}
      {{- printf "password" -}}
    {{- end -}}
  {{- else if .Values.externalPostgresql.enabled -}}
    {{- $passwordConfig := .Values.externalPostgresql.readOnly.auth.password -}}
    {{- if eq (include "postgresql.password.uses.secretRef" $passwordConfig) "true" -}}
      {{- printf "%s" $passwordConfig._secretRef.key -}}
    {{- else -}}
      {{- printf "readOnlyPassword" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Define the HyperLoader js URL */}}
{{- define "hyperswitchWeb.hyperloaderUrl" -}}
  {{- printf "%s/web/%s/%s/HyperLoader.js" .Values.services.sdk.host .Values.services.sdk.version .Values.services.sdk.subversion -}}
{{- end -}}

{{/* Define the ClickHouse host */}}
{{- define "clickhouse.host" -}}
{{ .Values.clickhouse.host | default "clickhouse" }}
{{- end -}}

{{/* Define the OpenTelemetry Collector endpoint when metrics or traces are enabled */}}
{{- define "opentelemetry-collector.url" -}}
  {{- $telemetryConfig := .Values.server.configs.log.telemetry -}}
  {{- if or $telemetryConfig.metrics_enabled $telemetryConfig.traces_enabled -}}
    {{- if and $telemetryConfig.otel_exporter_otlp_endpoint (ne $telemetryConfig.otel_exporter_otlp_endpoint "") -}}
      {{- $telemetryConfig.otel_exporter_otlp_endpoint -}}
    {{- else -}}
      {{- /*
        When otel_exporter_otlp_endpoint is empty, auto-configure the endpoint using the release name.
        This is typically used when deployed via hyperswitch-stack with monitoring enabled.
      */}}
      {{- printf "http://%s-opentelemetry-collector.%s.svc.cluster.local:4317" .Release.Name .Release.Namespace -}}
    {{- end -}}
  {{- else -}}
    {{- print "" -}}
  {{- end -}}
{{- end -}}

{{/* Define mapping of config keys to helper functions */}}
{{- define "hyperswitch.configKeyToHelperMapping" -}}
generic_link.payment_method_collect.sdk_url: "hyperswitchWeb.hyperloaderUrl"
generic_link.payout_link.sdk_url: "hyperswitchWeb.hyperloaderUrl"
payment_link.sdk_url: "hyperswitchWeb.hyperloaderUrl"
log.telemetry.otel_exporter_otlp_endpoint: "opentelemetry-collector.url"
{{- end -}}

{{/* Helper: Check if a config value is a secret field (_secret) */}}
{{- define "hyperswitch.isSecretField" -}}
  {{- $value := . -}}
  {{- if kindIs "map" $value -}}
    {{- if hasKey $value "_secret" -}}
      {{- print "true" -}}
    {{- else -}}
      {{- print "false" -}}
    {{- end -}}
  {{- else -}}
    {{- print "false" -}}
  {{- end -}}
{{- end -}}

{{/* Helper: Check if a config value is a reference field (_secretRef or _configRef) */}}
{{- define "hyperswitch.isReferenceField" -}}
  {{- $value := . -}}
  {{- if kindIs "map" $value -}}
    {{- if or (hasKey $value "_secretRef") (hasKey $value "_configRef") -}}
      {{- print "true" -}}
    {{- else -}}
      {{- print "false" -}}
    {{- end -}}
  {{- else -}}
    {{- print "false" -}}
  {{- end -}}
{{- end -}}

{{/* Convert YAML config to environment variables for ConfigMap (normal fields only) */}}
{{- define "hyperswitch.configToEnvVars" -}}
  {{- $config := .config -}}
  {{- $prefix := .prefix -}}
  {{- $context := .context | default . -}}
  {{- $currentPath := .currentPath | default "" -}}
  {{- $keyMapping := include "hyperswitch.configKeyToHelperMapping" . | fromYaml -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := printf "%s__%s" $prefix ($key | upper | replace "." "__") -}}
    {{- $configPath := $key -}}
    {{- if $currentPath -}}
      {{- $configPath = printf "%s.%s" $currentPath $key -}}
    {{- end -}}

    {{- if kindIs "map" $value -}}
      {{- $isSecret := include "hyperswitch.isSecretField" $value -}}
      {{- $isReference := include "hyperswitch.isReferenceField" $value -}}
      {{- if and (eq $isSecret "false") (eq $isReference "false") -}}
        {{/* Recursively process normal nested objects */}}
        {{- include "hyperswitch.configToEnvVars" (dict "config" $value "prefix" $envKey "context" $context "currentPath" $configPath) -}}
      {{- end -}}
    {{- else if kindIs "slice" $value -}}
      {{/* Handle arrays by joining with commas */}}
      {{- $arrayValue := $value | join "," -}}
      {{- printf "%s: %q\n" $envKey $arrayValue -}}
    {{- else -}}
      {{/* Check if this path has a helper function mapping and value is empty */}}
      {{- if and (hasKey $keyMapping $configPath) (or (eq $value "") (eq $value nil)) -}}
        {{- $helperFunc := get $keyMapping $configPath -}}
        {{- $helperValue := include $helperFunc $context -}}
        {{- printf "%s: %q\n" $envKey ($helperValue | toString) -}}
      {{- else if ne $value nil -}}
        {{/* Handle primitive values with proper YAML quoting */}}
        {{- printf "%s: %q\n" $envKey ($value | toString) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Convert YAML config to secret data (base64 encoded) for _secret fields */}}
{{- define "hyperswitch.configToSecrets" -}}
  {{- $config := .config -}}
  {{- $prefix := .prefix -}}
  {{- $context := .context | default . -}}
  {{- $currentPath := .currentPath | default "" -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := printf "%s__%s" $prefix ($key | upper | replace "." "__") -}}
    {{- $configPath := $key -}}
    {{- if $currentPath -}}
      {{- $configPath = printf "%s.%s" $currentPath $key -}}
    {{- end -}}

    {{- if kindIs "map" $value -}}
      {{- $isSecret := include "hyperswitch.isSecretField" $value -}}
      {{- if eq $isSecret "true" -}}
        {{/* Handle _secret field */}}
        {{- $secretValue := get $value "_secret" -}}
        {{- printf "%s: %s\n" $envKey ($secretValue | b64enc) -}}
      {{- else -}}
        {{/* Recursively process nested objects */}}
        {{- include "hyperswitch.configToSecrets" (dict "config" $value "prefix" $envKey "context" $context "currentPath" $configPath) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Convert YAML config to environment variables with valueFrom for _secretRef/_configRef fields */}}
{{- define "hyperswitch.configToEnvRefs" -}}
  {{- $config := .config -}}
  {{- $prefix := .prefix -}}
  {{- $context := .context | default . -}}
  {{- $currentPath := .currentPath | default "" -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := printf "%s__%s" $prefix ($key | upper | replace "." "__") -}}
    {{- $configPath := $key -}}
    {{- if $currentPath -}}
      {{- $configPath = printf "%s.%s" $currentPath $key -}}
    {{- end -}}

    {{- if kindIs "map" $value -}}
      {{- $isReference := include "hyperswitch.isReferenceField" $value -}}
      {{- if eq $isReference "true" -}}
        {{/* Handle _secretRef or _configRef field */}}
        {{- if hasKey $value "_secretRef" -}}
          {{- $ref := get $value "_secretRef" }}
- name: {{ $envKey }}
  valueFrom:
    secretKeyRef:
      name: {{ tpl $ref.name $context }}
      key: {{ tpl $ref.key $context }}
        {{- else if hasKey $value "_configRef" -}}
          {{- $ref := get $value "_configRef" }}
- name: {{ $envKey }}
  valueFrom:
    configMapKeyRef:
      name: {{ tpl $ref.name $context }}
      key: {{ tpl $ref.key $context }}
        {{- end }}
      {{- else -}}
        {{/* Recursively process nested objects */}}
        {{- include "hyperswitch.configToEnvRefs" (dict "config" $value "prefix" $envKey "context" $context "currentPath" $configPath) }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
