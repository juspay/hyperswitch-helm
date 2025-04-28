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
Service account name
*/}}
{{- define "hyperswitch-card-vault.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hyperswitch-card-vault.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validation
*/}}
{{- define "validate.locker-psql.config" -}}
{{- if not (or .Values.postgresql.enabled .Values.external.postgresql.enabled) }}
{{- fail "Both postgresql.enabled and external.postgresql.enabled cannot be 'false'" }}
{{- else if and .Values.postgresql.enabled .Values.external.postgresql.enabled }}
{{- fail "Both postgresql.enabled and external.postgresql.enabled cannot be 'true'" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "locker-psql.host" -}}
{{- include "validate.locker-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-locker-db" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Values.external.postgresql.config.host | quote }}
{{- end }}
{{- end }}


{{/*
PostgreSQL port
*/}}
{{- define "locker-psql.port" -}}
{{- include "validate.locker-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "\"5432\"" }}
{{- else }}
{{- .Values.external.postgresql.config.port | quote }}
{{- end }}
{{- end }}


{{/*
PostgreSQL username
*/}}
{{- define "locker-psql.username" -}}
{{- include "validate.locker-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username | quote }}
{{- else }}
{{- .Values.external.postgresql.config.username | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "locker-psql.name" -}}
{{- include "validate.locker-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database | quote }}
{{- else }}
{{- .Values.external.postgresql.config.database | quote }}
{{- end }}
{{- end }}


{{/*
PostgreSQL password
*/}}
{{- define "locker-psql.password" -}}
{{- include "validate.locker-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- required "Missing postgresql.auth.password!" .Values.postgresql.auth.password }}
{{- else }}
{{- .Values.external.postgresql.config.password | quote }}
{{- end }}
{{- end }}

{{/*
LOCKER server host
*/}}
{{- define "locker.server.host" -}}
{{- default "0.0.0.0" .Values.server.host | quote }}
{{- end }}

{{/*
LOCKER server port
*/}}
{{- define "locker.server.port" -}}
{{- default "8080" .Values.server.port | quote }}
{{- end }}

{{- define "locker.externalKeyManager.url" -}}
{{- default "http://localhost:5000" .Values.server.externalKeyManager.url -}}
{{- end -}}

{{- define "locker.externalKeyManager.cert" -}}
{{- default "dummyCert" .Values.server.externalKeyManager.cert -}}
{{- end -}}

{{- define "locker.apiClient.identity" -}}
{{- default "dummyCert" .Values.server.apiClient.identity -}}
{{- end -}}

{{- define "locker.awsKms.keyId" -}}
{{- default "key_id" .Values.server.awsKms.keyId -}}
{{- end -}}

{{- define "locker.awsKms.region" -}}
{{- default "us-east-1" .Values.server.awsKms.region -}}
{{- end -}}