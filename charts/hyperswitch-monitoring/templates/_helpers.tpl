{{/*
Expand the name of the chart.
*/}}
{{- define "hyperswitch-monitoring.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hyperswitch-monitoring.fullname" -}}
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
{{- define "hyperswitch-monitoring.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hyperswitch-monitoring.labels" -}}
helm.sh/chart: {{ include "hyperswitch-monitoring.chart" . }}
{{ include "hyperswitch-monitoring.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hyperswitch-monitoring.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hyperswitch-monitoring.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hyperswitch-monitoring.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hyperswitch-monitoring.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* 
Postgresql Hostname 
*/}}
{{- define "hyperswitch-monitoring.postgresql.hostname" -}}
  {{- if not .Values.postgresql.external }}
    {{- printf "%s-postgresql" .Release.Name | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf "%s" .Values.postgresql.primary.host -}}
  {{- end }}
{{- end }}

{{/* 
Postgresql Port 
*/}}
{{- define "hyperswitch-monitoring.postgresql.port" -}}
  {{- printf "%d" (int .Values.postgresql.primary.port) -}}
{{- end }}

{{/*
Postgresql Username
*/}}
{{- define "hyperswitch-monitoring.postgresql.username" -}}
  {{- printf "%s" .Values.postgresql.primary.username -}}
{{- end }}

{{/*
Postgresql Password 
*/}}
{{- define "hyperswitch-monitoring.postgresql.password" -}}
  {{- printf "%s" .Values.postgresql.primary.password -}}
{{- end }}

{{/* 
Postgresql Database 
*/}}
{{- define "hyperswitch-monitoring.postgresql.database" -}}
  {{- printf "%s" .Values.postgresql.primary.database -}}
{{- end }}

{{/*
Loki URL helper
*/}}
{{- define "hyperswitch-monitoring.loki.url" -}}
{{- printf "http://loki:3100" }}
{{- end }}

{{/*
Prometheus URL helper
*/}}
{{- define "hyperswitch-monitoring.prometheus.url" -}}
{{- printf "http://%s-kube-prometheus-prometheus:9090" .Release.Name }}
{{- end }}

