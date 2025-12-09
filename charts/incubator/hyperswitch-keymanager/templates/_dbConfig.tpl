{{/*
PostgreSQL configuration validation
*/}}
{{- define "validate.keymanager-psql.config" -}}
{{- if not (or .Values.postgresql.enabled .Values.externalPostgresql.enabled) }}
{{- fail "Both postgresql.enabled and externalPostgresql.enabled cannot be 'false'" }}
{{- else if and .Values.postgresql.enabled .Values.externalPostgresql.enabled }}
{{- fail "Both postgresql.enabled and externalPostgresql.enabled cannot be 'true'" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "keymanager-psql.host" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- $nameOverride := .Values.postgresql.nameOverride | default "keymanager-db" }}
{{- printf "%s-%s" .Release.Name $nameOverride | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
{{- else }}
{{- .Values.externalPostgresql.config.host | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "keymanager-psql.port" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "5432" | quote }}
{{- else }}
{{- .Values.externalPostgresql.config.port | default 5432 | toString | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "keymanager-psql.username" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username | quote }}
{{- else }}
{{- .Values.externalPostgresql.config.username | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "keymanager-psql.database" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database | quote }}
{{- else }}
{{- .Values.externalPostgresql.config.database | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL password
*/}}
{{- define "keymanager-psql.password" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- required "Missing postgresql.auth.password!" .Values.postgresql.auth.password }}
{{- else }}
{{- .Values.externalPostgresql.config.password | trim }}
{{- end }}
{{- end }}

{{/*
PostgreSQL plain password for external PostgreSQL
*/}}
{{- define "keymanager-psql.plainpassword" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- required "Missing postgresql.auth.password!" .Values.postgresql.auth.password }}
{{- else }}
{{- default .Values.externalPostgresql.config.password .Values.externalPostgresql.config.plainpassword | trim }}
{{- end }}
{{- end }}

{{/*
PostgreSQL enable SSL
*/}}
{{- define "keymanager-psql.enable_ssl" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "false" | quote }}
{{- else }}
{{- .Values.externalPostgresql.enable_ssl | default false | toString | quote }}
{{- end }}
{{- end }}

{{/* Common helper: Check if a password config uses _secretRef */}}
{{- define "keymanager-psql.password.uses.secretRef" -}}
  {{- $passwordConfig := . -}}
  {{- if and (kindIs "map" $passwordConfig) (hasKey $passwordConfig "_secretRef") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{/*
PostgreSQL secret name for password (supports _secretRef)
*/}}
{{- define "keymanager-psql.secret.name" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
  {{- $passwordConfig := .Values.postgresql.auth.password -}}
  {{- if eq (include "keymanager-psql.password.uses.secretRef" $passwordConfig) "true" -}}
    {{- printf "%s" $passwordConfig._secretRef.name -}}
  {{- else -}}
    {{- $nameOverride := .Values.postgresql.nameOverride | default "keymanager-db" }}
    {{- printf "%s-%s" .Release.Name $nameOverride | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- else if .Values.externalPostgresql.enabled }}
  {{- $passwordConfig := .Values.externalPostgresql.config.password -}}
  {{- if eq (include "keymanager-psql.password.uses.secretRef" $passwordConfig) "true" -}}
    {{- printf "%s" $passwordConfig._secretRef.name -}}
  {{- else -}}
    {{- printf "%s-secrets" (include "hyperswitch-keymanager.fullname" .) -}}
  {{- end -}}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key for password (supports _secretRef)
*/}}
{{- define "keymanager-psql.secret.key" -}}
{{- include "validate.keymanager-psql.config" . }}
{{- if .Values.postgresql.enabled }}
  {{- $passwordConfig := .Values.postgresql.auth.password -}}
  {{- if eq (include "keymanager-psql.password.uses.secretRef" $passwordConfig) "true" -}}
    {{- printf "%s" $passwordConfig._secretRef.key -}}
  {{- else -}}
    {{- printf "password" -}}
  {{- end -}}
{{- else if .Values.externalPostgresql.enabled }}
  {{- $passwordConfig := .Values.externalPostgresql.config.password -}}
  {{- if eq (include "keymanager-psql.password.uses.secretRef" $passwordConfig) "true" -}}
    {{- printf "%s" $passwordConfig._secretRef.key -}}
  {{- else -}}
    {{- printf "CRIPTA__DATABASE__PASSWORD" -}}
  {{- end -}}
{{- end }}
{{- end }}
