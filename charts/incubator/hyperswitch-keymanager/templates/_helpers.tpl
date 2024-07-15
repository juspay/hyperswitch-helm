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
Create the name of the service account to use
*/}}
{{- define "hyperswitch-keymanager.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hyperswitch-keymanager.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*  validation */}}
{{- define "validate.keymanager-psql.config" -}}
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
{{- define "keymanager-psql.host" -}}
{{- $test_db := include "validate.keymanager-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
    {{- printf "%s-keymanager-db" .Release.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{- printf "%s" .Values.external.postgresql.config.host -}}
  {{- end -}}
{{- end -}}


{{/* Select PostgreSQL port Internal or External */}}
{{- define "keymanager-psql.port" -}}
{{- $test_db := include "validate.keymanager-psql.config" . }}
  {{- printf "\"5432\"" }}
{{- end -}}


{{/* Select PostgreSQL host Internal or External */}}
{{- define "keymanager-psql.username" -}}
{{- $test_db := include "validate.keymanager-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
    {{- printf "%s" .Values.postgresql.global.postgresql.auth.username -}}
  {{- else -}}
    {{- printf "%s" .Values.external.postgresql.config.username -}}
  {{- end -}}
{{- end -}}


{{/* Select PostgreSQL host Internal or External */}}
{{- define "keymanager-psql.name" -}}
{{- $test_db := include "validate.keymanager-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
      {{- printf "%s" .Values.postgresql.global.postgresql.auth.database -}}
  {{- else if .Values.external.enabled -}}
      {{- printf "%s" .Values.external.postgresql.config.database -}}
  {{- end -}}
{{- end -}}


{{/* Select PostgreSQL host Internal or External */}}
{{- define "keymanager-psql.password" -}}
{{- $test_db := include "validate.keymanager-psql.config" . }}
  {{- if .Values.postgresql.enabled }}
      {{- printf "%s" .Values.postgresql.global.postgresql.auth.password -}}
  {{- else if .Values.external.enabled -}}
      {{- printf "%s" .Values.external.postgresql.config.password -}}
  {{- end -}}
{{- end -}}

