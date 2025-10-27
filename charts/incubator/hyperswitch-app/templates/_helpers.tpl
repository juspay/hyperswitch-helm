# Define `hyperswitch.fullname` template
{{- define "hyperswitch.fullname" -}}
{{- default .Chart.Name .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch.labels` template
{{- define "hyperswitch.labels" -}}
helm.sh/chart: {{ include "hyperswitch.chart" . }}
{{ include "hyperswitch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "hyperswitch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

# Define `hyperswitch.selectorLabels` template
{{- define "hyperswitch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hyperswitch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

# Define `hyperswitch.name` template
{{- define "hyperswitch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch.chart` template
{{- define "hyperswitch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


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

{{/* Define the clickhouse secret when enabled */}}
{{- define "clickhouse.secret" -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- include "clickhouse.fullname" . -}}
  {{- else -}}
    {{- include "hyperswitch.secrets.name" . -}}
  {{- end -}}
{{- end -}}

{{/* Define the clickhouse password when enabled */}}
{{- define "clickhouse.secret.password" -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- printf "admin-password" -}}
  {{- else -}}
    {{- printf "ROUTER__ANALYTICS__CLICKHOUSE__PASSWORD" -}}
  {{- end -}}
{{- end -}}

{{/* Define the HyperLoader js URL */}}
{{- define "hyperswitchWeb.hyperloaderUrl" -}}
  {{- printf "%s/web/%s/%s/HyperLoader.js" .Values.services.sdk.host .Values.services.sdk.version .Values.services.sdk.subversion -}}
{{- end -}}

{{/* Define the ClickHouse host (hostname only, used for clickhouse-client) */}}
{{- define "clickhouse.host" -}}
{{- include "clickhouse.fullname" . -}}
{{- end -}}

{{/* Define the ClickHouse URL (http://hostname:port, used for analytics configuration) */}}
{{- define "clickhouse.url" -}}
{{- printf "http://%s:8123" (include "clickhouse.fullname" .) -}}
{{- end -}}

{{/* Define the OpenTelemetry Collector endpoint when metrics or traces are enabled */}}
{{- define "opentelemetry-collector.url" -}}
  {{- $telemetryConfig := .Values.server.log.telemetry -}}
  {{- if or $telemetryConfig.metrics_enabled $telemetryConfig.traces_enabled -}}
    {{- if $telemetryConfig.external_otel_collector_endpoint -}}
      {{- $telemetryConfig.external_otel_collector_endpoint -}}
    {{- else if $telemetryConfig.autoConfigureOtelEndpoint -}}
      {{- /* 
        When autoConfigureOtelEndpoint is true, construct the endpoint using the release name.
        This is typically set to true when deployed via hyperswitch-stack with monitoring enabled.
      */}}
      {{- printf "http://%s-opentelemetry-collector.%s.svc.cluster.local:4317" .Release.Name .Release.Namespace -}}
    {{- else -}}
      {{- fail "Could not obtain OpenTelemetry Collector URL. Please specify either `external_otel_collector_endpoint` or use hyperswitch-monitoring chart & enable `autoConfigureOtelEndpoint`" -}}
    {{- end -}}
  {{- else -}}
    {{- print "" -}}  
  {{- end -}}
{{- end -}}

{{/*
Convert version format from v1.115.0 to v1o115o0 for Kubernetes labels
*/}}
{{- define "version.suffix" -}}
{{- . | replace "." "o" -}}
{{- end -}}

{{/*
Component name helpers - allows configurable naming for each service
*/}}

{{/* Router component name */}}
{{- define "hyperswitch.router.name" -}}
{{- default "hyperswitch-server" .Values.server.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Router full name */}}
{{- define "hyperswitch.router.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "hyperswitch-server" .Values.server.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Consumer component name */}}
{{- define "hyperswitch.consumer.name" -}}
{{- default "hyperswitch-consumer" .Values.consumer.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Consumer full name */}}
{{- define "hyperswitch.consumer.fullname" -}}
{{- if .Values.consumer.fullnameOverride -}}
{{- .Values.consumer.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "hyperswitch-consumer" .Values.consumer.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Producer component name */}}
{{- define "hyperswitch.producer.name" -}}
{{- default "hyperswitch-producer" .Values.producer.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Producer full name */}}
{{- define "hyperswitch.producer.fullname" -}}
{{- if .Values.producer.fullnameOverride -}}
{{- .Values.producer.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "hyperswitch-producer" .Values.producer.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Drainer component name */}}
{{- define "hyperswitch.drainer.name" -}}
{{- default "hyperswitch-drainer" .Values.drainer.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Drainer full name */}}
{{- define "hyperswitch.drainer.fullname" -}}
{{- if .Values.drainer.fullnameOverride -}}
{{- .Values.drainer.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "hyperswitch-drainer" .Values.drainer.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Control Center component name */}}
{{- define "hyperswitch.controlCenter.name" -}}
{{- default "hyperswitch-control-center" .Values.controlCenter.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Control Center full name */}}
{{- define "hyperswitch.controlCenter.fullname" -}}
{{- if .Values.controlCenter.fullnameOverride -}}
{{- .Values.controlCenter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "hyperswitch-control-center" .Values.controlCenter.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Secrets name */}}
{{- define "hyperswitch.secrets.name" -}}
{{- if .Values.global.secretsNameOverride -}}
{{- .Values.global.secretsNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-secrets" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Router service account name */}}
{{- define "hyperswitch.server.serviceAccountName" -}}
{{- if .Values.server.serviceAccount.name -}}
{{- .Values.server.serviceAccount.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-hyperswitch-router" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Control Center service account name */}}
{{- define "hyperswitch.controlCenter.serviceAccountName" -}}
{{- if .Values.controlCenter.serviceAccount.name -}}
{{- .Values.controlCenter.serviceAccount.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-hyperswitch-control-center" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* External Redis secret name */}}
{{- define "externalRedis.secret.name" -}}
{{- printf "ext-redis-%s" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* DB migration job name */}}
{{- define "hyperswitch.db.job.name" -}}
{{- printf "%s-hyperswitch-create-db-%s" .Release.Name (regexReplaceAll "\\." .Values.services.router.version "-") | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Clickhouse fullname - matches Bitnami subchart default naming */}}
{{- define "clickhouse.fullname" -}}
{{- $fullname := printf "%s-clickhouse" .Release.Name -}}
{{- if and .Values.clickhouse (hasKey .Values.clickhouse "fullnameOverride") -}}
{{- if and .Values.clickhouse.fullnameOverride (ne .Values.clickhouse.fullnameOverride "") -}}
{{- $fullname = .Values.clickhouse.fullnameOverride -}}
{{- end -}}
{{- end -}}
{{- $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Kafka fullname - matches Bitnami subchart default naming */}}
{{- define "kafka.fullname" -}}
{{- $fullname := printf "%s-kafka" .Release.Name -}}
{{- if and .Values.kafka (hasKey .Values.kafka "fullnameOverride") -}}
{{- if and .Values.kafka.fullnameOverride (ne .Values.kafka.fullnameOverride "") -}}
{{- $fullname = .Values.kafka.fullnameOverride -}}
{{- end -}}
{{- end -}}
{{- $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Mailhog fullname - matches mailhog subchart default naming */}}
{{- define "mailhog.fullname" -}}
{{- $fullname := printf "%s-mailhog" .Release.Name -}}
{{- if and .Values.mailhog (hasKey .Values.mailhog "fullnameOverride") -}}
{{- if and .Values.mailhog.fullnameOverride (ne .Values.mailhog.fullnameOverride "") -}}
{{- $fullname = .Values.mailhog.fullnameOverride -}}
{{- end -}}
{{- end -}}
{{- $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}