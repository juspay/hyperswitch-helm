{{/*
Expand the name of the chart.
*/}}
{{- define "hyperswitch-control-center.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hyperswitch-control-center.fullname" -}}
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
{{- define "hyperswitch-control-center.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Convert version format from v1.115.0 to v1o115o0 for Kubernetes labels
*/}}
{{- define "version.suffix" -}}
{{- . | replace "." "o" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "hyperswitch-control-center.labels" -}}
helm.sh/chart: {{ include "hyperswitch-control-center.chart" . }}
{{ include "hyperswitch-control-center.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hyperswitch-control-center.selectorLabels" -}}
app: {{ include "hyperswitch-control-center.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hyperswitch-control-center.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hyperswitch-control-center.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Define the HyperLoader js URL */}}
{{- define "hyperswitch-sdk.hyperloaderUrl" -}}
{{- if .Values.dependencies.sdk.fullUrlOverride }}
{{- .Values.dependencies.sdk.fullUrlOverride -}}
{{- else }}
{{- printf "%s/web/%s/%s/HyperLoader.js" .Values.dependencies.sdk.host .Values.dependencies.sdk.version .Values.dependencies.sdk.subversion -}}
{{- end -}}
{{- end -}}

{{/*
Convert nested config to flat environment variables for ConfigMap
Usage: {{ include "hyperswitch-control-center.configEnvVars" (dict "config" .Values.config) }}
*/}}
{{- define "hyperswitch-control-center.configEnvVars" -}}
  {{- $config := .config -}}
  {{- $currentKey := .currentKey | default "" -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := $key -}}
    {{- if $currentKey -}}
      {{- $envKey = printf "%s__%s" $currentKey $key -}}
    {{- end -}}

    {{- if kindIs "map" $value -}}
      {{/* Recursively process nested objects */}}
      {{- include "hyperswitch-control-center.configEnvVars" (dict "config" $value "currentKey" $envKey) -}}
    {{- else if kindIs "slice" $value -}}
      {{/* Handle arrays by joining with commas */}}
      {{- $arrayValue := $value | join "," -}}
      {{- printf "%s: %q\n" $envKey $arrayValue -}}
    {{- else -}}
      {{/* Handle primitive values */}}
      {{- printf "%s: %q\n" $envKey ($value | toString) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Get the full image name
*/}}
{{- define "hyperswitch-control-center.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry }}
{{- $repository := .Values.image.repository }}
{{- $tag := .Values.image.tag | default "latest" }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}
