{{/* Define environment variables for PostgreSQL secrets */}}
{{- define "postgresql.secrets.envs" -}}
{{- if not .Values.server.configs.analytics.sqlx.password }}
- name: ROUTER__ANALYTICS__SQLX__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.master.password.secret" . }}
      key: {{ include "postgresql.master.password.key" . }}
{{- end }}
- name: ROUTER__MASTER_DATABASE__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.master.password.secret" . }}
      key: {{ include "postgresql.master.password.key" . }}
- name: ROUTER__REPLICA_DATABASE__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.replica.password.secret" . }}
      key: {{ include "postgresql.replica.password.key" . }}
{{- end -}}

{{/* Define environment variables for PostgreSQL secrets */}}
{{- define "drainer.secrets.envs" -}}
- name: DRAINER__MASTER_DATABASE__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.master.password.secret" . }}
      key: {{ include "postgresql.master.password.key" . }}
{{- end -}}

{{/* Generic secret enviornnement variables */}}
{{- define "generic.envs" -}}
- name: ROUTER__EMAIL__ALLOWED_UNVERIFIED_DAYS
  value: "{{ .Values.server.configs.email.allowed_unverified_days }}"
- name: RUN_ENV
  value: {{ if eq .Values.server.run_env "production" }}"production"{{ else }}"sandbox"{{ end }}
{{- end -}}

{{- define "metadata.envs" -}}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: SERVICE_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['app']
- name: VERSION_VALUE
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['version']
{{- end -}}


{{/* Define environment variables for KeyManager configuration */}}
{{- define "keymanager.envs" -}}
{{- if .Values.server.keymanager }}
- name: ROUTER__KEY_MANAGER__ENABLED
  value: "{{ .Values.server.keymanager.enabled | default false }}"
{{- if .Values.server.keymanager.url }}
- name: ROUTER__KEY_MANAGER__URL
  value: "{{ .Values.server.keymanager.url }}"
{{- end }}
{{- end }}
{{- end -}}

{{/* Generate environment variables from external secrets configuration */}}
{{- define "external.secrets.envs" -}}
{{- if .Values.global.useExternalSecrets.enabled }}
{{- range $secretName, $mappings := .Values.global.useExternalSecrets.secrets }}
{{- range $mapping := $mappings }}
- name: {{ $mapping.envName }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ $mapping.secretKey }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
