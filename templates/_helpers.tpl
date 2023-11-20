# Define `hyperswitch.fullname` template
{{- define "hyperswitch.fullname" -}}
{{- default .Chart.Name .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch.labels` template
{{- define "hyperswitch.labels" -}}
helm.sh/chart: {{ include "hyperswitch.chart" . }}
{{ include "hyperswitch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "hyperswitch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

# Define `hyperswitch.selectorLabels` template
{{- define "hyperswitch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hyperswitch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

# Define `hyperswitch.name` template
{{- define "hyperswitch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Define `hyperswitch.chart` template
{{- define "hyperswitch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
