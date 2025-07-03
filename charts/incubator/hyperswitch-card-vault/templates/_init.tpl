{{/*Ensure postgres database is up and running */}}
{{- define "locker-psql.initContainer.check.ready" -}}
- name: check-postgres
  image: {{ .Values.initDB.checkPGisUp.image }}
  env:
    - name: PGPASSWORD
      value: {{ include "locker-psql.password" . | quote }}
  command: [ "/bin/sh", "-c" ]
  #language=sh
  args:
  - |
    MAX_ATTEMPTS={{ .Values.initDB.checkPGisUp.maxAttempt | default 30 }};
    SLEEP_SECONDS=5;
    attempt=0;
    while ! pg_isready -U {{ include "locker-psql.username" . }} \
           -d {{ include "locker-psql.name" . }} \
           -h {{ include "locker-psql.host" . }} \
           -p {{ include "locker-psql.port" . }}; do
      if [ $attempt -ge $MAX_ATTEMPTS ]; then
        echo "PostgreSQL did not become ready in time";
        exit 1;
      fi;
      attempt=$((attempt+1));
      echo "Waiting for PostgreSQL to be ready... Attempt: $attempt";
      sleep $SLEEP_SECONDS;
    done;
    echo "PostgreSQL is ready.";
{{- end -}}

---

{{/* Ensure CardVault service is up and healthy */}}
{{- define "locker-vault.initContainer.check.ready" -}}
- name: check-vault-service-ready
  image: {{ .Values.vaultKeysJob.checkVaultService.image }}
  command: [ "/bin/sh", "-c" ]
  args:
    - |
      MAX_ATTEMPTS={{ .Values.vaultKeysJob.checkVaultService.maxAttempt | default 30 }};
      SLEEP_SECONDS=5;
      attempt=0;
      while true; do
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://{{ .Values.vaultKeysJob.checkVaultService.host | default (printf "hyperswitch-vault.%s.svc.cluster.local" .Release.Namespace) }}/health)
        if [ "$HTTP_STATUS" = "200" ]; then
          echo " Vault service is healthy.";
          break;
        fi
        if [ $attempt -ge $MAX_ATTEMPTS ]; then
          echo "Vault service did not become healthy in time (last HTTP status: $HTTP_STATUS)";
          exit 1;
        fi;
        attempt=$((attempt+1));
        echo "Waiting for Vault service to be healthy... Attempt: $attempt";
        sleep $SLEEP_SECONDS;
      done;
{{- end -}}
