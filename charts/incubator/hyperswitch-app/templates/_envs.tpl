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
- name: ROUTER__SECRETS__ADMIN_API_KEY
  valueFrom:
    secretKeyRef:
      key: ROUTER__SECRETS__ADMIN_API_KEY
      name: hyperswitch-secrets
- name: ROUTER__SECRETS__JWT_SECRET
  valueFrom:
    secretKeyRef:
      key: ROUTER__SECRETS__JWT_SECRET
      name: hyperswitch-secrets
- name: ROUTER__API_KEYS__KMS_ENCRYPTED_HASH_KEY
  valueFrom:
    secretKeyRef:
      key: ROUTER__API_KEYS__KMS_ENCRYPTED_HASH_KEY
      name: hyperswitch-secrets
- name: ROUTER__SECRETS__MASTER_ENC_KEY
  valueFrom:
    secretKeyRef:
      key: ROUTER__SECRETS__MASTER_ENC_KEY
      name: hyperswitch-secrets
- name: ROUTER__CONNECTOR_ONBOARDING__PAYPAL__CLIENT_ID
  valueFrom:
    secretKeyRef:
      key: ROUTER__CONNECTOR_ONBOARDING__PAYPAL__CLIENT_ID
      name: hyperswitch-secrets
- name: ROUTER__CONNECTOR_ONBOARDING__PAYPAL__CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      key: ROUTER__CONNECTOR_ONBOARDING__PAYPAL__CLIENT_SECRET
      name: hyperswitch-secrets
- name: ROUTER__CONNECTOR_ONBOARDING__PAYPAL__PARTNER_ID
  valueFrom:
    secretKeyRef:
      key: ROUTER__CONNECTOR_ONBOARDING__PAYPAL__PARTNER_ID
      name: hyperswitch-secrets
- name: ROUTER__SECRETS_MANAGEMENT__AWS_KMS__KEY_ID
  valueFrom:
    secretKeyRef:
      key: ROUTER__KMS__KEY_ID
      name: hyperswitch-secrets
- name: ROUTER__SECRETS_MANAGEMENT__AWS_KMS__REGION
  valueFrom:
    secretKeyRef:
      key: ROUTER__KMS__REGION
      name: hyperswitch-secrets
- name: ROUTER__ENCRYPTION_MANAGEMENT__AWS_KMS__KEY_ID
  valueFrom:
    secretKeyRef:
      key: ROUTER__KMS__KEY_ID
      name: hyperswitch-secrets
- name: ROUTER__ENCRYPTION_MANAGEMENT__AWS_KMS__REGION
  valueFrom:
    secretKeyRef:
      key: ROUTER__KMS__REGION
      name: hyperswitch-secrets
- name: ROUTER__ANALYTICS__CLICKHOUSE__USERNAME
  valueFrom:
    secretKeyRef:
      key: ROUTER__ANALYTICS__CLICKHOUSE__USERNAME
      name: hyperswitch-secrets
- name: ROUTER__ANALYTICS__CLICKHOUSE__DATABASE_NAME
  valueFrom:
    secretKeyRef:
      key: ROUTER__ANALYTICS__CLICKHOUSE__DATABASE_NAME
      name: hyperswitch-secrets
- name: ROUTER__ANALYTICS__CLICKHOUSE__HOST
  valueFrom:
    secretKeyRef:
      key: ROUTER__ANALYTICS__CLICKHOUSE__HOST
      name: hyperswitch-secrets
- name: ROUTER__EMAIL__SENDER_EMAIL
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__SENDER_EMAIL
      name: hyperswitch-secrets
- name: ROUTER__EMAIL__ALLOWED_UNVERIFIED_DAYS
  value: "{{ .Values.server.email.allowed_unverified_days }}"
- name: ROUTER__EMAIL__AWS_REGION
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__AWS_REGION
      name: hyperswitch-secrets
      optional: true
- name: ROUTER__EMAIL__RECON_RECIPIENT_EMAIL
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__RECON_RECIPIENT_EMAIL
      name: hyperswitch-secrets
- name: ROUTER__EMAIL__PROD_INTENT_RECIPIENT_EMAIL
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__PROD_INTENT_RECIPIENT_EMAIL
      name: hyperswitch-secrets
- name: ROUTER__EMAIL__SMTP__HOST
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__SMTP__HOST
      name: hyperswitch-secrets
- name: ROUTER__EMAIL__SMTP__PORT
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__SMTP__PORT
      name: hyperswitch-secrets
- name: ROUTER__EMAIL__SMTP__USERNAME
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__SMTP__USERNAME
      name: hyperswitch-secrets
      optional: true
- name: ROUTER__EMAIL__SMTP__PASSWORD
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__SMTP__PASSWORD
      name: hyperswitch-secrets
      optional: true
- name: ROUTER__EMAIL__AWS_SES__EMAIL_ROLE_ARN
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__AWS_SES__EMAIL_ROLE_ARN
      name: hyperswitch-secrets
- name: ROUTER__EMAIL__AWS_SES__STS_ROLE_SESSION_NAME
  valueFrom:
    secretKeyRef:
      key: ROUTER__EMAIL__AWS_SES__STS_ROLE_SESSION_NAME
      name: hyperswitch-secrets
- name: RUN_ENV
  value: {{ .Values.server.run_env }}
{{- end -}}
