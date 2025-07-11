{{/*
Expand the name of the chart.
*/}}
{{- define "hyperswitch-keymanager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hyperswitch-keymanager.fullname" -}}
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
{{- define "hyperswitch-keymanager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hyperswitch-keymanager.labels" -}}
helm.sh/chart: {{ include "hyperswitch-keymanager.chart" . }}
{{ include "hyperswitch-keymanager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hyperswitch-keymanager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hyperswitch-keymanager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "hyperswitch-keymanager.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hyperswitch-keymanager.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL configuration validation
*/}}
{{- define "validate.keymanager-psql.config" -}}
{{- if not (or .Values.postgresql.enabled .Values.external.postgresql.enabled) }}
{{- fail "Both postgresql.enabled and external.postgresql.enabled cannot be 'false'" }}
{{- else if and .Values.postgresql.enabled .Values.external.postgresql.enabled }}
{{- fail "Both postgresql.enabled and external.postgresql.enabled cannot be 'true'" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "keymanager-psql.host" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-keymanager-db" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
{{- else }}
{{- .Values.external.postgresql.config.host | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "keymanager-psql.port" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "5432" }}
{{- else }}
{{- .Values.external.postgresql.config.port | default 5432 }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "keymanager-psql.username" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username | quote }}
{{- else }}
{{- .Values.external.postgresql.config.username | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "keymanager-psql.database" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database | quote }}
{{- else }}
{{- .Values.external.postgresql.config.database | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL password
*/}}
{{- define "keymanager-psql.password" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- required "Missing postgresql.auth.password!" .Values.postgresql.auth.password }}
{{- else }}
{{- .Values.external.postgresql.config.password | trim }}
{{- end }}
{{- end }}

{{/*
PostgreSQL plain password for external PostgreSQL
*/}}
{{- define "keymanager-psql.plainpassword" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- required "Missing postgresql.auth.password!" .Values.postgresql.auth.password }}
{{- else }}
{{- default .Values.external.postgresql.config.password .Values.external.postgresql.config.plainpassword | trim }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "keymanager-psql.secret" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-keymanager-db" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "keymanager-secrets-%s" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL enable SSL
*/}}
{{- define "keymanager-psql.enable_ssl" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "false" }}
{{- else }}
{{- .Values.external.postgresql.enable_ssl | default false }}
{{- end }}
{{- end }}
