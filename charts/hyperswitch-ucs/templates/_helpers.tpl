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

{{/*
Config value conventions (same as the hyperswitch-app chart):

  key: value                       -> ConfigMap entry CS__KEY (configToEnvVars)
  key: { _secret: value }          -> chart-managed Secret entry CS__KEY (configToSecrets)
  key: { _secretRef: {name, key} } -> env CS__KEY with valueFrom.secretKeyRef (configToEnvRefs)
  key: { _configRef: {name, key} } -> env CS__KEY with valueFrom.configMapKeyRef (configToEnvRefs)

A `_secret` / `_secretRef` / `_configRef` map is a leaf: it is never flattened into the
ConfigMap, so a secret can only reach the pod through a Secret or a reference.
*/}}

{{/* Is this config value a `_secret` leaf? */}}
{{- define "hyperswitch-ucs.isSecretField" -}}
  {{- if and (kindIs "map" .) (hasKey . "_secret") -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/* Is this config value a `_secretRef` or `_configRef` leaf? */}}
{{- define "hyperswitch-ucs.isReferenceField" -}}
  {{- if and (kindIs "map" .) (or (hasKey . "_secretRef") (hasKey . "_configRef")) -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/* Convert YAML config to flattened environment variables for the ConfigMap (plain values only) */}}
{{- define "hyperswitch-ucs.configToEnvVars" -}}
  {{- $config := .config -}}
  {{- $prefix := .prefix | default "" -}}
  {{- $currentPath := .currentPath | default "" -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := printf "%s__%s" $prefix ($key | upper | replace "." "__") -}}
    {{- $configPath := $key -}}
    {{- if $currentPath -}}
      {{- $configPath = printf "%s.%s" $currentPath $key -}}
    {{- end -}}

    {{- if kindIs "map" $value -}}
      {{- $isSecret := include "hyperswitch-ucs.isSecretField" $value -}}
      {{- $isReference := include "hyperswitch-ucs.isReferenceField" $value -}}
      {{- if and (eq $isSecret "false") (eq $isReference "false") -}}
        {{- /* Recursively process nested maps; secret and reference leaves are delivered elsewhere */ -}}
        {{- include "hyperswitch-ucs.configToEnvVars"
            (dict "config" $value "prefix" $envKey "currentPath" $configPath)
        -}}
      {{- end -}}

    {{- else if kindIs "slice" $value -}}
      {{- /* Convert arrays to comma-separated */ -}}
      {{- printf "%s: %q\n" $envKey ($value | join ",") -}}

    {{- else -}}
      {{- /* Handle primitive values */ -}}
      {{- printf "%s: %q\n" $envKey ($value | toString) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Convert `_secret` config values to base64 Secret data */}}
{{- define "hyperswitch-ucs.configToSecrets" -}}
  {{- $config := .config -}}
  {{- $prefix := .prefix | default "" -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := printf "%s__%s" $prefix ($key | upper | replace "." "__") -}}
    {{- if kindIs "map" $value -}}
      {{- if eq (include "hyperswitch-ucs.isSecretField" $value) "true" -}}
        {{- printf "%s: %s\n" $envKey (get $value "_secret" | toString | b64enc) -}}
      {{- else if eq (include "hyperswitch-ucs.isReferenceField" $value) "false" -}}
        {{- include "hyperswitch-ucs.configToSecrets" (dict "config" $value "prefix" $envKey) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Convert `_secretRef` / `_configRef` config values to env entries with valueFrom.
`name` and `key` go through tpl, so "{{ .Release.Name }}-…" works. An optional
`optional: true` on a `_secretRef` lets the pod start before the Secret exists.
*/}}
{{- define "hyperswitch-ucs.configToEnvRefs" -}}
  {{- $config := .config -}}
  {{- $prefix := .prefix | default "" -}}
  {{- $context := .context -}}

  {{- range $key, $value := $config -}}
    {{- $envKey := printf "%s__%s" $prefix ($key | upper | replace "." "__") -}}
    {{- if kindIs "map" $value -}}
      {{- if hasKey $value "_secretRef" -}}
        {{- $ref := get $value "_secretRef" }}
- name: {{ $envKey }}
  valueFrom:
    secretKeyRef:
      name: {{ tpl ($ref.name | toString) $context }}
      key: {{ tpl ($ref.key | toString) $context }}
      {{- if $ref.optional }}
      optional: true
      {{- end }}
      {{- else if hasKey $value "_configRef" -}}
        {{- $ref := get $value "_configRef" }}
- name: {{ $envKey }}
  valueFrom:
    configMapKeyRef:
      name: {{ tpl ($ref.name | toString) $context }}
      key: {{ tpl ($ref.key | toString) $context }}
      {{- if $ref.optional }}
      optional: true
      {{- end }}
      {{- else if not (hasKey $value "_secret") -}}
        {{- include "hyperswitch-ucs.configToEnvRefs" (dict "config" $value "prefix" $envKey "context" $context) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
