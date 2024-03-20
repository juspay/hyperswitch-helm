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