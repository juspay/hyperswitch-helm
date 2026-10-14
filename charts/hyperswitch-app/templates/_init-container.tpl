{{/*Ensure postgres database is up and running */}}
{{- define "postgresql.initContainer.check.ready" -}}
- name: check-postgres
  {{- $registry := .Values.global.imageRegistry | default .Values.initDB.checkPGisUp.imageRegistry }}
  image: "{{ $registry }}/{{ .Values.initDB.checkPGisUp.image }}"
  imagePullPolicy: IfNotPresent
  command: [ "/bin/sh", "-c" ]
  #language=sh
  args:
  - >
    MAX_ATTEMPTS={{ .Values.initDB.checkPGisUp.maxAttempt }};
    SLEEP_SECONDS=5;
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


{{/*Ensure Redis is up and running */}}
{{- define "redis.initContainer.check.ready" -}}
- name: check-redis
  {{- $registry := .Values.global.imageRegistry | default .Values.redisMiscConfig.checkRedisIsUp.initContainer.imageRegistry }}
  image: "{{ $registry }}/{{ .Values.redisMiscConfig.checkRedisIsUp.initContainer.image }}"
  imagePullPolicy: IfNotPresent
  command: [ "/bin/sh", "-c" ]
  #language=sh
  args:
  - >
    MAX_ATTEMPTS={{ .Values.redisMiscConfig.checkRedisIsUp.initContainer.maxAttempt }};
    SLEEP_SECONDS=5;
    attempt=0;
    while ! redis-cli -h {{ include "redis.host" . }} -p 6379 ping; do
      if [ $attempt -ge $MAX_ATTEMPTS ]; then
        echo "Redis did not become ready in time";
        exit 1;
      fi;
      attempt=$((attempt+1));
      echo "Waiting for Redis to be ready... Attempt: $attempt";
      sleep $SLEEP_SECONDS;
    done;
    echo "Redis is ready.";
{{- end -}}

{{/* Wait for the hyperswitch-ucs gRPC port: the router builds its UCS client once at startup
and runs without UCS until restarted if the dial fails. */}}
{{- define "ucs.initContainer.check.ready" -}}
- name: check-ucs
  {{- $ucs := index .Values "hyperswitch-ucs" }}
  {{- $check := .Values.ucsMiscConfig.checkUcsIsUp.initContainer }}
  {{- $registry := .Values.global.imageRegistry | default $check.imageRegistry }}
  image: "{{ $registry }}/{{ $check.image }}"
  imagePullPolicy: IfNotPresent
  command: [ "/bin/bash", "-c" ]
  #language=sh
  args:
  - >
    MAX_ATTEMPTS={{ $check.maxAttempt }};
    SLEEP_SECONDS=5;
    attempt=0;
    while ! timeout 2 bash -c "</dev/tcp/{{ $ucs.fullnameOverride | default "hyperswitch-ucs" }}/{{ $ucs.service.grpc.port | default 8000 }}"; do
      if [ $attempt -ge $MAX_ATTEMPTS ]; then
        echo "UCS did not become ready in time";
        exit 1;
      fi;
      attempt=$((attempt+1));
      echo "Waiting for UCS to be ready... Attempt: $attempt";
      sleep $SLEEP_SECONDS;
    done;
    echo "UCS is ready.";
{{- end -}}

{{/* Ensure ClickHouse is up and running */}}
{{- define "clickhouse.initContainer.check.ready" -}}
- name: check-clickhouse
  {{- $registry := .Values.global.imageRegistry | default .Values.initCH.checkCHisUp.imageRegistry }}
  image: "{{ $registry }}/{{ .Values.initCH.checkCHisUp.image }}"
  imagePullPolicy: IfNotPresent
  command: [ "/bin/sh", "-c" ]
  #language=sh
  env:
    - name: CLICKHOUSE_ADMIN_PASSWORD
      valueFrom:
        secretKeyRef:
          name: clickhouse
          key: admin-password
  args:
  - >
    MAX_ATTEMPTS={{ .Values.initCH.checkCHisUp.maxAttempt }};
    SLEEP_SECONDS=5;
    attempt=0;
    while ! clickhouse-client --host={{ include "clickhouse.host" . }} \
                              --port=9000 \
                              --user={{ .Values.clickhouse.auth.username }} \
                              --password=$CLICKHOUSE_ADMIN_PASSWORD \
                              --query="SELECT 1"; do
      if [ $attempt -ge $MAX_ATTEMPTS ]; then
        echo "ClickHouse did not become ready in time";
        exit 1;
      fi;
      attempt=$((attempt+1));
      echo "Waiting for ClickHouse to be ready... Attempt: $attempt";
      sleep $SLEEP_SECONDS;
    done;
    echo "ClickHouse is ready.";
{{- end -}}