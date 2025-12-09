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

{{/*
Get the full image name
*/}}
{{- define "hyperswitch-keymanager.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry }}
{{- $repository := .Values.image.repository }}
{{- $tag := .Values.image.tag | default "latest" }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/* Define mapping of config keys to helper functions */}}
{{- define "hyperswitch-keymanager.configKeyToHelperMapping" -}}
{{/* Add any config key mappings here if needed in the future */}}
{{- end -}}

{{/* Helper: Check if a config value is a secret field (_secret) */}}
{{- define "hyperswitch-keymanager.isSecretField" -}}
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
{{- define "hyperswitch-keymanager.isReferenceField" -}}
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
{{- define "hyperswitch-keymanager.configToEnvVars" -}}
  {{- $config := .config -}}
  {{- $prefix := .prefix -}}
  {{- $context := .context | default . -}}
  {{- $currentPath := .currentPath | default "" -}}
  {{- $keyMapping := include "hyperswitch-keymanager.configKeyToHelperMapping" . | fromYaml -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := printf "%s__%s" $prefix ($key | upper | replace "." "__") -}}
    {{- $configPath := $key -}}
    {{- if $currentPath -}}
      {{- $configPath = printf "%s.%s" $currentPath $key -}}
    {{- end -}}

    {{- if kindIs "map" $value -}}
      {{- $isSecret := include "hyperswitch-keymanager.isSecretField" $value -}}
      {{- $isReference := include "hyperswitch-keymanager.isReferenceField" $value -}}
      {{- if and (eq $isSecret "false") (eq $isReference "false") -}}
        {{/* Recursively process normal nested objects */}}
        {{- include "hyperswitch-keymanager.configToEnvVars" (dict "config" $value "prefix" $envKey "context" $context "currentPath" $configPath) -}}
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
      {{- else -}}
        {{/* Handle primitive values with proper YAML quoting */}}
        {{- printf "%s: %q\n" $envKey ($value | toString) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Convert YAML config to secret data (base64 encoded) for _secret fields */}}
{{- define "hyperswitch-keymanager.configToSecrets" -}}
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
      {{- $isSecret := include "hyperswitch-keymanager.isSecretField" $value -}}
      {{- if eq $isSecret "true" -}}
        {{/* Handle _secret field */}}
        {{- $secretValue := get $value "_secret" -}}
        {{- printf "%s: %s\n" $envKey ($secretValue | b64enc) -}}
      {{- else -}}
        {{/* Recursively process nested objects */}}
        {{- include "hyperswitch-keymanager.configToSecrets" (dict "config" $value "prefix" $envKey "context" $context "currentPath" $configPath) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Convert YAML config to environment variables with valueFrom for _secretRef/_configRef fields */}}
{{- define "hyperswitch-keymanager.configToEnvRefs" -}}
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
      {{- $isReference := include "hyperswitch-keymanager.isReferenceField" $value -}}
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
        {{- include "hyperswitch-keymanager.configToEnvRefs" (dict "config" $value "prefix" $envKey "context" $context "currentPath" $configPath) }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
