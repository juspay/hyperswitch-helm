{{/*
Expand the name of the chart.
*/}}
{{- define "sdk.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
Format: {release-name}-hyperswitch-web
*/}}
{{- define "sdk.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "hyperswitch-web" .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sdk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sdk.labels" -}}
helm.sh/chart: {{ include "sdk.chart" . }}
{{ include "sdk.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sdk.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sdk.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sdk.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sdk.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Ngnix autobuild statefulset sdk path
*/}}
{{- define "nginx.autobuild.sdk.path" -}}
{{- printf "/web/%s/%s/" .Values.autoBuild.gitCloneParam.gitVersion .Values.autoBuild.nginxConfig.extraPath}}
{{- end }}


{{/*
Ngnix deployment sdk path
*/}}
{{- define "nginx.sdk.path" -}}
{{- printf "/web/%s/%s/" .Values.autoBuild.gitCloneParam.gitVersion .Values.autoBuild.nginxConfig.extraPath }}
{{- end }}

{{/* Define the name for hyperswitch sdk host */}}
{{- define "hyperswitch-sdk.host" -}}
{{- printf "%s" .Values.autoBuild.buildParam.envSdkUrl -}}
{{- end -}}

{{/* Define the name for hyperswitch sdk version */}}
{{- define "hyperswitch-sdk.version" -}}
{{- printf "%s" .Values.autoBuild.gitCloneParam.gitVersion -}}
{{- end -}}

{{/* Define the name for hyperswitch sdk subversion */}}
{{- define "hyperswitch-sdk.subversion" -}}
{{- printf "%s" .Values.autoBuild.nginxConfig.extraPath -}}
{{- end -}}

{{/* Define the fullname for hyperswitch SDK demo app */}}
{{- define "hyperswitch-sdk-demo.fullname" -}}
{{- if .Values.sdkDemo.nameOverride }}
{{- .Values.sdkDemo.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-hyperswitch-sdk-demo" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end -}}

{{/* Version suffix helper for hyperswitch-web */}}
{{- define "hyperswitch-web.version.suffix" -}}
{{- $version := .Values.autoBuild.gitCloneParam.gitVersion | default .Chart.AppVersion -}}
{{- printf "v%s" ($version | replace "." "o") -}}
{{- end -}}

{{/* Version suffix helper for SDK demo app - extracts version from image tag */}}
{{- define "hyperswitch-sdk-demo.version.suffix" -}}
{{- $image := .Values.services.sdkDemo.image -}}
{{- $version := "unknown" -}}
{{- if contains ":" $image -}}
{{- $parts := split ":" $image -}}
{{- $version = $parts._1 | replace "." "o" -}}
{{- end -}}
{{- printf "%s" $version -}}
{{- end -}}