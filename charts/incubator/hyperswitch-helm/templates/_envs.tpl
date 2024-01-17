{{/* Define environment variables for PostgreSQL secrets */}}
{{- define "postgresql.secrets.envs" -}}
- name: ROUTER__ANALYTICS__CLICKHOUSE__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secret" . }}
      {{- if .Values.postgresql.enabled }}
      key: password
      {{- else if .Values.externalPostgresql.enabled }}
      key: primaryPassword
      {{- end }}
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
- name: ROUTER__JWEKEY__LOCKER_DECRYPTION_KEY1
  valueFrom:
    secretKeyRef:
      key: ROUTER__JWEKEY__LOCKER_DECRYPTION_KEY1
      name: hyperswitch-secrets
- name: ROUTER__JWEKEY__LOCKER_DECRYPTION_KEY2
  valueFrom:
    secretKeyRef:
      key: ROUTER__JWEKEY__LOCKER_DECRYPTION_KEY2
      name: hyperswitch-secrets
- name: ROUTER__JWEKEY__LOCKER_ENCRYPTION_KEY1
  valueFrom:
    secretKeyRef:
      key: ROUTER__JWEKEY__LOCKER_ENCRYPTION_KEY1
      name: hyperswitch-secrets
- name: ROUTER__JWEKEY__LOCKER_ENCRYPTION_KEY2
  valueFrom:
    secretKeyRef:
      key: ROUTER__JWEKEY__LOCKER_ENCRYPTION_KEY2
      name: hyperswitch-secrets
- name: ROUTER__JWEKEY__LOCKER_KEY_IDENTIFIER1
  valueFrom:
    secretKeyRef:
      key: ROUTER__JWEKEY__LOCKER_KEY_IDENTIFIER1
      name: hyperswitch-secrets
- name: ROUTER__JWEKEY__LOCKER_KEY_IDENTIFIER2
  valueFrom:
    secretKeyRef:
      key: ROUTER__JWEKEY__LOCKER_KEY_IDENTIFIER2
      name: hyperswitch-secrets
- name: ROUTER__JWEKEY__TUNNEL_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      key: ROUTER__JWEKEY__TUNNEL_PRIVATE_KEY
      name: hyperswitch-secrets
- name: ROUTER__KMS__KEY_ID
  valueFrom:
    secretKeyRef:
      key: ROUTER__KMS__KEY_ID
      name: hyperswitch-secrets
- name: ROUTER__KMS__REGION
  valueFrom:
    secretKeyRef:
      key: ROUTER__KMS__REGION
      name: hyperswitch-secrets
- name: ROUTER__SECRETS__KMS_ENCRYPTED_ADMIN_API_KEY
  valueFrom:
    secretKeyRef:
      key: ROUTER__SECRETS__KMS_ENCRYPTED_ADMIN_API_KEY
      name: hyperswitch-secrets
- name: ROUTER__SECRETS__KMS_ENCRYPTED_JWT_SECRET
  valueFrom:
    secretKeyRef:
      key: ROUTER__SECRETS__KMS_ENCRYPTED_JWT_SECRET
      name: hyperswitch-secrets
{{- end -}}
