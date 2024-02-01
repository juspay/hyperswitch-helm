{{/*
Expand the name of the chart.
*/}}
{{- define "hyperswitch-card-vault.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hyperswitch-card-vault.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hyperswitch-card-vault.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hyperswitch-card-vault.labels" -}}
helm.sh/chart: {{ include "hyperswitch-card-vault.chart" . }}
{{ include "hyperswitch-card-vault.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hyperswitch-card-vault.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hyperswitch-card-vault.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hyperswitch-card-vault.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hyperswitch-card-vault.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}



{{/*  validation */}}
{{- define "validate.locker-psql.config" -}}
    {{- if not (or  .Values.postgresql.enabled .Values.external.postgresql.enabled) }}
        {{-  fail
        "Both postgresql.enabled and external.postgresql.enabled cannot be 'false' at the same time. Please, onfigure at least one Redis."
         }}
    {{- else if and .Values.postgresql.enabled .Values.external.postgresql.enabled }}
        {{-  fail
        "Both postgresql.enabled and external.postgresql.enabled cannot be 'true' at the same time. Select only once please"
         }}
    {{- end }}
{{- end }}


{{/* Select PostgreSQL host Internal or External */}}
{{- define "locker-psql.host" -}}
{{- $test_db := include "validate.locker-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
    {{- printf "%s-locker-db" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{- printf "%s" .Values.external.postgresql.config.host -}}
  {{- end -}}
{{- end -}}


{{/* Select PostgreSQL port Internal or External */}}
{{- define "locker-psql.port" -}}
{{- $test_db := include "validate.locker-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
    {{- printf "\"5432\"" }}
  {{- else -}}
    {{- printf "%s" .Values.external.postgresql.config.port -}}
  {{- end -}}
{{- end -}}


{{/* Select PostgreSQL host Internal or External */}}
{{- define "locker-psql.username" -}}
{{- $test_db := include "validate.locker-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
    {{- printf "%s" .Values.postgresql.global.postgresql.auth.username -}}
  {{- else -}}
    {{- printf "%s" .Values.external.postgresql.config.username -}}
  {{- end -}}
{{- end -}}


{{/* Select PostgreSQL host Internal or External */}}
{{- define "locker-psql.name" -}}
{{- $test_db := include "validate.locker-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
    {{- printf "%s" .Values.postgresql.global.postgresql.auth.database -}}
  {{- else -}}
    {{- printf "%s" .Values.external.postgresql.config.database -}}
  {{- end -}}
{{- end -}}


{{/* Select PostgreSQL host Internal or External */}}
{{- define "locker-psql.password" -}}
{{- $test_db := include "validate.locker-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
    {{- printf "%s" .Values.postgresql.global.postgresql.auth.password -}}
  {{- else -}}
    {{- printf "%s" .Values.external.postgresql.config.password -}}
  {{- end -}}
{{- end -}}
