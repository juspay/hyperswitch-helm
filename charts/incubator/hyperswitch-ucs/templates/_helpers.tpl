{{/*
Expand the name of the chart.
*/}}
{{- define "hyperswitch-ucs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hyperswitch-ucs.fullname" -}}
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
{{- define "hyperswitch-ucs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hyperswitch-ucs.labels" -}}
helm.sh/chart: {{ include "hyperswitch-ucs.chart" . }}
{{ include "hyperswitch-ucs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hyperswitch-ucs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hyperswitch-ucs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hyperswitch-ucs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hyperswitch-ucs.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Convert YAML config to flattened environment variables (maps & slices only) */}}
{{- define "hyperswitch-ucs.configToEnvVars" -}}
  {{- $config := .config -}}
  {{- $prefix := .prefix -}}
  {{- $currentPath := .currentPath | default "" -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := printf "%s__%s" $prefix ($key | upper | replace "." "__") -}}
    {{- $configPath := $key -}}
    {{- if $currentPath -}}
      {{- $configPath = printf "%s.%s" $currentPath $key -}}
    {{- end -}}

    {{- if kindIs "map" $value -}}
      {{/* Recursively process nested maps */}}
      {{- include "hyperswitch-ucs.configToEnvVars" (dict "config" $value "prefix" $envKey "currentPath" $configPath) -}}

    {{- else if kindIs "slice" $value -}}
      {{/* Convert array → comma-separated */}}
      {{- printf "%s: %q\n" $envKey ($value | join ",") -}}

    {{- end -}}
  {{- end -}}
{{- end -}}
