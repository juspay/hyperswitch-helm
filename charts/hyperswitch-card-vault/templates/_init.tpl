{{/*Ensure postgres database is up and running */}}
{{- define "locker-psql.initContainer.check.ready" -}}
- name: check-postgres
  {{- $registry := .Values.global.imageRegistry | default .Values.initDB.checkPGisUp.imageRegistry }}
  image: "{{ $registry }}/{{ .Values.initDB.checkPGisUp.image }}"
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
