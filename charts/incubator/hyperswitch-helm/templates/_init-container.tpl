{{/*Ensure postgres database is up and running */}}
{{- define "postgresql.initContainer.check.ready" -}}
- name: check-postgres
  image: {{ .Values.initDB.checkPGisUp.image }}
  command: [ "/bin/sh", "-c" ]
  #language=sh
  args:
  - >
    MAX_ATTEMPTS={{ .Values.initDB.checkPGisUp.maxAttempt }};
    SLEEP_SECONDS=10;
    attempt=0;
    while ! pg_isready -U {{ include "postgresql.username" . }} -d {{ include "postgresql.database" . }} -h {{ include "postgresql.host" . }} -p 5432; do
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
