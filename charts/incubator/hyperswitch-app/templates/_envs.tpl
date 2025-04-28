{{/* Define environment variables for PostgreSQL secrets */}}
{{- define "postgresql.secrets.envs" -}}
- name: ROUTER__ANALYTICS__CLICKHOUSE__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "clickhouse.secret" . }}
      key: {{ include "clickhouse.secret.password" . }}
- name: ROUTER__ANALYTICS__SQLX__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secret" . }}
      {{- if .Values.postgresql.enabled }}
      key: password
      {{- else if .Values.externalPostgresql.enabled }}
      key: primaryPassword
      {{- end }}
- name: ROUTER__MASTER_DATABASE__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secret" . }}
      {{- if .Values.postgresql.enabled }}
      key: password
      {{- else if .Values.externalPostgresql.enabled }}
      key: primaryPassword
      {{- end }}
- name: ROUTER__REPLICA_DATABASE__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secret" . }}
      {{- if .Values.postgresql.enabled }}
      key: password
      {{- else if .Values.externalPostgresql.enabled }}
      key: primaryPassword
      {{- end }}
{{- end -}}

{{/* Generic secret enviornnement variables */}}
{{- define "generic.envs" -}}
- name: ROUTER__EMAIL__ALLOWED_UNVERIFIED_DAYS
  value: "{{ .Values.server.email.allowed_unverified_days }}"
- name: RUN_ENV
  value: {{ .Values.server.run_env }}
{{- end -}}
