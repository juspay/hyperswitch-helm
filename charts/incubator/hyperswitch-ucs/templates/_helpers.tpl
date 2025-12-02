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

{{- /* Generate TOML tables from nested config values */ -}}
{{- define "hyperswitch-ucs.configToml" -}}
  {{- $config := .config -}}
  {{- $path := default "" .path -}}

  {{- /* Emit table header when we have a non-empty path */ -}}
  {{- if ne $path "" -}}
[{{ $path }}]
  {{- end }}

  {{- range $key, $value := $config }}
    {{- if kindIs "map" $value }}
      {{- /* nested table: compute newPath = (if $path == "" then $key else "$path.$key") */ -}}
      {{- $newPath := ternary (printf "%s.%s" $path $key) $key (ne $path "") -}}
      {{ include "hyperswitch-ucs.configToml" (dict "config" $value "path" $newPath) }}
    {{- else if kindIs "slice" $value }}
{{ printf "%s = [" $key -}}
      {{- range $i, $v := $value -}}
        {{- if $i }}, {{ end -}}
        {{- if kindIs "string" $v -}}
"{{ $v }}"
        {{- else -}}
{{ $v }}
        {{- end -}}
      {{- end -}}
{{ printf "]\n" }}
    {{- else if kindIs "string" $value }}
{{ printf "%s = %q\n" $key $value }}
    {{- else if or (kindIs "int" $value) (kindIs "float64" $value) }}
{{ printf "%s = %v\n" $key $value }}
    {{- else if kindIs "bool" $value }}
{{ printf "%s = %v\n" $key $value }}
    {{- else }}
{{ printf "%s = %q\n" $key ($value | toString) }}
    {{- end }}
  {{- end }}
{{- end -}}
