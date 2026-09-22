{{/*
PostgreSQL configuration validation
*/}}
{{- define "validate.encryption-service-psql.config" -}}
{{- if not (or .Values.postgresql.enabled .Values.externalPostgresql.enabled) }}
{{- fail "Both postgresql.enabled and externalPostgresql.enabled cannot be 'false'" }}
{{- else if and .Values.postgresql.enabled .Values.externalPostgresql.enabled }}
{{- fail "Both postgresql.enabled and externalPostgresql.enabled cannot be 'true'" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "encryption-service-psql.host" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- $nameOverride := .Values.postgresql.nameOverride | default "encryption-service-db" }}
{{- printf "%s-%s" .Release.Name $nameOverride | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
{{- else }}
{{- .Values.externalPostgresql.config.host | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "encryption-service-psql.port" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "5432" | quote }}
{{- else }}
{{- .Values.externalPostgresql.config.port | default 5432 | toString | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "encryption-service-psql.username" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username | quote }}
{{- else }}
{{- .Values.externalPostgresql.config.username | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "encryption-service-psql.database" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database | quote }}
{{- else }}
{{- .Values.externalPostgresql.config.database | trim | quote }}
{{- end }}
{{- end }}

{{/*
PostgreSQL password
*/}}
{{- define "encryption-service-psql.password" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- required "Missing postgresql.auth.password!" .Values.postgresql.auth.password }}
{{- else }}
{{- .Values.externalPostgresql.config.password | trim }}
{{- end }}
{{- end }}

{{/*
PostgreSQL plain password for external PostgreSQL
*/}}
{{- define "encryption-service-psql.plainpassword" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- required "Missing postgresql.auth.password!" .Values.postgresql.auth.password }}
{{- else }}
{{- default .Values.externalPostgresql.config.password .Values.externalPostgresql.config.plainpassword | trim }}
{{- end }}
{{- end }}

{{/*
PostgreSQL enable SSL
*/}}
{{- define "encryption-service-psql.enable_ssl" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
{{- printf "false" | quote }}
{{- else }}
{{- .Values.externalPostgresql.enable_ssl | default false | toString | quote }}
{{- end }}
{{- end }}

{{/* Common helper: Check if a password config uses _secretRef */}}
{{- define "encryption-service-psql.password.uses.secretRef" -}}
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
{{- define "encryption-service-psql.secret.name" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
  {{- $passwordConfig := .Values.postgresql.auth.password -}}
  {{- if eq (include "encryption-service-psql.password.uses.secretRef" $passwordConfig) "true" -}}
    {{- printf "%s" $passwordConfig._secretRef.name -}}
  {{- else -}}
    {{- $nameOverride := .Values.postgresql.nameOverride | default "encryption-service-db" }}
    {{- printf "%s-%s" .Release.Name $nameOverride | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- else if .Values.externalPostgresql.enabled }}
  {{- $passwordConfig := .Values.externalPostgresql.config.password -}}
  {{- if eq (include "encryption-service-psql.password.uses.secretRef" $passwordConfig) "true" -}}
    {{- printf "%s" $passwordConfig._secretRef.name -}}
  {{- else -}}
    {{- printf "%s-secrets" (include "hyperswitch-encryption-service.fullname" .) -}}
  {{- end -}}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key for password (supports _secretRef)
*/}}
{{- define "encryption-service-psql.secret.key" -}}
{{- include "validate.encryption-service-psql.config" . }}
{{- if .Values.postgresql.enabled }}
  {{- $passwordConfig := .Values.postgresql.auth.password -}}
  {{- if eq (include "encryption-service-psql.password.uses.secretRef" $passwordConfig) "true" -}}
    {{- printf "%s" $passwordConfig._secretRef.key -}}
  {{- else -}}
    {{- printf "password" -}}
  {{- end -}}
{{- else if .Values.externalPostgresql.enabled }}
  {{- $passwordConfig := .Values.externalPostgresql.config.password -}}
  {{- if eq (include "encryption-service-psql.password.uses.secretRef" $passwordConfig) "true" -}}
    {{- printf "%s" $passwordConfig._secretRef.key -}}
  {{- else -}}
    {{- printf "CRIPTA__DATABASE__PASSWORD" -}}
  {{- end -}}
{{- end }}
{{- end }}
