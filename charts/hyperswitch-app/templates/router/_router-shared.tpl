{{/*
Router services
===============

This chart can run the hyperswitch router in more than one shape inside a single release. Every
shape uses the same image and the same release-wide ConfigMap, Secret and ServiceAccount, and
differs only in configuration:

  key                   values block                   resources
  --------------------- ------------------------------ ----------------------------------------
  "" (the main router)  services.router + server.*      <release>-hyperswitch-server
  olap                  .Values.olap                    <release>-hyperswitch-olap-server
  paymentMethodModular  .Values.paymentMethodModular    <release>-hyperswitch-payment-method-modular-server

Every define below takes the same argument - (dict "root" $ "key" "<values key>") - where an
empty key means the main router. Settings fall back variant -> server.* -> global.*, so for the
main router each lookup collapses to exactly the expression the chart used before.

The extra services carry their config deltas as inline `env:` entries rather than a ConfigMap of
their own: Kubernetes gives `env` precedence over `envFrom`, so the release's base ConfigMap and
Secret still supply everything else. `_secret` values cannot be used in a delta (they would be
plaintext in the pod spec) - use `_secretRef`.
*/}}

{{/* Is any router enabled? Guards the release-wide config the routers share. */}}
{{- define "hyperswitch.anyRouterEnabled" -}}
{{- $enabled := .Values.services.router.enabled -}}
{{- range $key := list "olap" "paymentMethodModular" -}}
{{- $svc := default dict (index $.Values $key) -}}
{{- if $svc.enabled -}}
{{- $enabled = true -}}
{{- end -}}
{{- end -}}
{{- if $enabled -}}true{{- end -}}
{{- end -}}

{{/* Resource name for one router */}}
{{- define "hyperswitch.router.name" -}}
{{- $root := .root -}}
{{- if not .key -}}
{{- include "hyperswitch-server.name" $root -}}
{{- else -}}
{{- $svc := default dict (index $root.Values .key) -}}
{{- if $svc.fullnameOverride -}}
{{- $svc.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-hyperswitch-%s-server" $root.Release.Name (.key | kebabcase) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Router image tag; an extra service defaults to the release's router version */}}
{{- define "hyperswitch.router.version" -}}
{{- $root := .root -}}
{{- $svc := default dict (index $root.Values .key) -}}
{{- $svc.version | default $root.Values.services.router.version | toString -}}
{{- end -}}

{{/* Full image reference */}}
{{- define "hyperswitch.router.image" -}}
{{- $root := .root -}}
{{- if not .key -}}
{{- include "hyperswitch-router.image" $root -}}
{{- else -}}
{{- $svc := default dict (index $root.Values .key) -}}
{{- $registry := $root.Values.global.imageRegistry | default ($svc.imageRegistry | default $root.Values.services.router.imageRegistry) -}}
{{- $repository := $svc.image | default $root.Values.services.router.image -}}
{{- $tag := include "hyperswitch.router.version" . | default $root.Chart.AppVersion -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}
{{- end -}}

{{/* Release-scoped image version, used for the `image-version` label and IMAGE_VERSION_VALUE */}}
{{- define "hyperswitch.router.imageVersion" -}}
{{- if not .key -}}
{{- include "router.image.version" .root -}}
{{- else -}}
{{- printf "%s_%s" .root.Release.Name (include "hyperswitch.router.version" .) -}}
{{- end -}}
{{- end -}}

{{/* ServiceAccount: an extra service reuses the release's router ServiceAccount by default */}}
{{- define "hyperswitch.router.serviceAccountName" -}}
{{- $root := .root -}}
{{- $svc := default dict (index $root.Values .key) -}}
{{- $svc.serviceAccountName | default (include "hyperswitch-router-sa.name" $root) -}}
{{- end -}}

{{/*
Does this release actually have a PostgreSQL read replica? Decides whether
`database.useReplicaForMaster` can be honoured, so a single-PostgreSQL install still renders a
service that starts instead of one pointed at a host that does not exist.
*/}}
{{- define "hyperswitch.router.replicaAvailable" -}}
{{- $root := .root -}}
{{- if $root.Values.postgresql.enabled -}}
  {{- if and (eq ($root.Values.postgresql.architecture | default "standalone") "replication") (gt (int ($root.Values.postgresql.readReplicas.replicaCount | default 0)) 0) -}}
    {{- print "true" -}}
  {{- end -}}
{{- else if $root.Values.externalPostgresql.enabled -}}
  {{- if $root.Values.externalPostgresql.readOnly.enabled -}}
    {{- print "true" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Master (write) database host. `database.masterHost` wins; otherwise
`database.useReplicaForMaster` points the write handle at the read replica - the guardrail the
OLAP service uses, where a write attempted against it fails at the replica instead of reaching
the writer. With no replica in the release the primary is used.
*/}}
{{- define "hyperswitch.router.masterHost" -}}
{{- $root := .root -}}
{{- $db := (default dict (index $root.Values .key)).database | default dict -}}
{{- if $db.masterHost -}}
{{- tpl ($db.masterHost | toString) $root -}}
{{- else if and $db.useReplicaForMaster (include "hyperswitch.router.replicaAvailable" .) -}}
{{- include "postgresqlreplica.host" $root -}}
{{- else -}}
{{- include "postgresql.host" $root -}}
{{- end -}}
{{- end -}}

{{/* Replica (read) database host */}}
{{- define "hyperswitch.router.replicaHost" -}}
{{- $root := .root -}}
{{- $db := (default dict (index $root.Values .key)).database | default dict -}}
{{- if $db.replicaHost -}}
{{- tpl ($db.replicaHost | toString) $root -}}
{{- else if include "hyperswitch.router.replicaAvailable" . -}}
{{- include "postgresqlreplica.host" $root -}}
{{- else -}}
{{- include "postgresql.host" $root -}}
{{- end -}}
{{- end -}}

{{/* Deployment, or Rollout when Argo Rollouts is enabled for this router */}}
{{- define "hyperswitch.router.workload" -}}
{{- $root := .root -}}
{{- $key := .key -}}
{{- $svc := default dict (index $root.Values $key) -}}
{{- $server := $root.Values.server -}}
{{- $global := $root.Values.global -}}
{{- $name := include "hyperswitch.router.name" . -}}
{{- $version := include "hyperswitch.router.version" . -}}
{{- $as := $root.Values.autoscaling -}}
{{- $ar := $root.Values.argoRollouts -}}
{{- $istioEnabled := $root.Values.istio.enabled -}}
{{- $configs := $server.configs -}}
{{- if $key -}}
{{- $as = default dict $svc.autoscaling -}}
{{- $istioEnabled = (default dict $svc.istio).enabled -}}
{{- if $svc.argoRollouts -}}
{{- $ar = mergeOverwrite (deepCopy $root.Values.argoRollouts) (deepCopy $svc.argoRollouts) -}}
{{- end -}}
{{- if $svc.configs -}}
{{- $configs = mergeOverwrite (deepCopy $server.configs) (deepCopy $svc.configs) -}}
{{- end -}}
{{- end -}}
{{- if $ar.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Rollout
{{- else }}
apiVersion: apps/v1
kind: Deployment
{{- end }}
metadata:
  annotations:
    {{- with ($svc.annotations | default (default $global.annotations $server.annotations)) }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  labels:
    {{- include "hyperswitch.labels" $root | nindent 4 }}
    app.kubernetes.io/name: {{ $name }}
    app.kubernetes.io/version: {{ $version | quote }}
    app: {{ $name }}
    version: {{ include "version.suffix" $version | quote }}
    {{- if $key }}
    hyperswitch.io/router-service: {{ $key | kebabcase | quote }}
    {{- end }}
  name: {{ $name }}
  namespace: {{ $root.Release.Namespace }}
spec:
  progressDeadlineSeconds: {{ $svc.progressDeadlineSeconds | default (default $global.progressDeadlineSeconds $server.progressDeadlineSeconds) }}
  {{- if not $as.enabled }}
  replicas: {{ $svc.replicas | default (default $global.replicas $server.replicas) }}
  {{- end }}
  {{- if $ar.enabled }}
  revisionHistoryLimit: {{ $ar.revisionHistoryLimit }}
  {{- else }}
  revisionHistoryLimit: 10
  {{- end }}
  selector:
    matchLabels:
      app: {{ $name }}
      app.kubernetes.io/instance: {{ $root.Release.Name }}
  {{- if $ar.enabled }}
  # Argo Rollouts strategy configuration
  # TODO: Add support for other deployment strategies (Blue-Green)
  strategy:
    canary:
      # Canary deployment steps with traffic percentage and pause duration
      steps:
      {{- toYaml $ar.canary.steps | nindent 6 }}
      # Optional canary configuration settings
      {{- with $ar.canary.dynamicStableScale}}
      dynamicStableScale: {{ . }}
      {{- end }}
      {{- with $ar.canary.abortScaleDownDelaySeconds}}
      abortScaleDownDelaySeconds: {{ . }}
      {{- end }}
      # AB Testing Analysis Configuration using VictoriaMetrics
      {{- if $ar.canary.analysis.enabled }}
      analysis:
        templates:
        - templateName: {{ $name }}-canary
        startingStep: {{ $ar.canary.analysis.startingStep | default 2 }}
        args:
        {{- range $ar.canary.analysis.args }}
        {{- if not (and .valueFrom .valueFrom.secretKeyRef) }}
        - {{ toYaml . | nindent 10 | trim }}
        {{- end }}
        {{- end }}
      {{- end }}
      {{- with $ar.canary.antiAffinity}}
      antiAffinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $ar.canary.maxSurge}}
      maxSurge: {{ . }}
      {{- end }}
      {{- with $ar.canary.maxUnavailable}}
      maxUnavailable: {{ . }}
      {{- end }}
      # Istio traffic routing configuration
      # TODO: Add support for other traffic routers (e.g., Nginx, SMI)
      {{- if $ar.canary.trafficRouting.istio.enabled }}
      {{- if not $istioEnabled }}
      {{- if $key }}
      {{- fail (printf "Istio must be enabled (.Values.%s.istio.enabled: true) when using Argo Rollouts - Istio traffic routing" $key) }}
      {{- else }}
      {{- fail "Istio must be enabled (.Values.istio.enabled: true) when using Argo Rollouts - Istio traffic routing" }}
      {{- end }}
      {{- end }}
      trafficRouting:
        istio:
          virtualService:
            name: {{ $name }}-vs
            {{- with $ar.canary.trafficRouting.istio.virtualService.routeNames }}
            routes:
              {{- toYaml . | nindent 14 }}
            {{- end }}
          destinationRule:
            name: {{ $name }}-dr
            canarySubsetName: {{ $ar.canary.trafficRouting.istio.destinationRule.canarySubsetName }}
            stableSubsetName: {{ $ar.canary.trafficRouting.istio.destinationRule.stableSubsetName }}
      {{- end }}
  {{- else }}
  # Standard Deployment strategy
  strategy:
    {{- with ($svc.strategy | default (default $global.strategy $server.strategy)) }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  template:
    metadata:
      annotations:
        checksum/router-config: {{ include (print $root.Template.BasePath "/router/configmap.yaml") $root | sha256sum }}
        checksum/hyperswitch-configs: {{ include (print $root.Template.BasePath "/misc/configmap.yaml") $root | sha256sum }}
        checksum/hyperswitch-secrets: {{ include (print $root.Template.BasePath "/misc/secrets.yaml") $root | sha256sum }}
        {{- with ($svc.podAnnotations | default (default $global.podAnnotations $server.podAnnotations)) }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        app: {{ $name }}
        version: {{ include "version.suffix" $version | quote }}
        image-version: {{ include "hyperswitch.router.imageVersion" . | quote }}
        {{- include "hyperswitch.labels" $root | nindent 8 }}
        {{- if $key }}
        hyperswitch.io/router-service: {{ $key | kebabcase | quote }}
        {{- end }}
        {{- with ($svc.labels | default ($server.labels | default $global.labels)) }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with ($svc.tolerations | default (default $global.tolerations $server.tolerations)) }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with ($svc.affinity | default (default $global.affinity $server.affinity)) }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with ($svc.nodeSelector | default (default $global.nodeSelector $server.nodeSelector)) }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if or $root.Values.initDB.enable $root.Values.redisMiscConfig.checkRedisIsUp.initContainer.enable (eq (include "hyperswitch.superpositionFallback.fetchEnabled" $root) "true") }}
      initContainers:
        {{- if eq (include "hyperswitch.superpositionFallback.fetchEnabled" $root) "true" }}
        {{- include "hyperswitch.superpositionFallback.initContainer" $root | nindent 8 }}
        {{- end }}
        {{- if $root.Values.initDB.enable }}
        {{- include "postgresql.initContainer.check.ready" $root | nindent 8 }}
        {{- end }}
        {{- if $root.Values.redisMiscConfig.checkRedisIsUp.initContainer.enable }}
        {{- include "redis.initContainer.check.ready" $root | nindent 8 }}
        {{- end }}
      {{- end }}
      containers:
        - name: hyperswitch-router
          image: {{ include "hyperswitch.router.image" . }}
          imagePullPolicy: {{ $svc.imagePullPolicy | default "IfNotPresent" }}
          lifecycle:
            preStop:
              exec:
                command:
                  - /bin/bash
                  - -c
                  - pkill -15 node
          env:
            - name: BINARY
              value: {{ $server.binary }}
          {{- with $global.env }}
          {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $server.env }}
          {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $svc.env }}
          {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if $key }}
            - name: IMAGE_VERSION_VALUE
              value: {{ include "hyperswitch.router.imageVersion" . | quote }}
          {{- else }}
          {{- include "router.infra.values.envs" $root | nindent 12 }}
          {{- end }}
          {{- include "metadata.envs" $root | nindent 12 }}
          {{- if $key }}
            - name: ROUTER__EMAIL__ALLOWED_UNVERIFIED_DAYS
              value: "{{ (($configs.email) | default dict).allowed_unverified_days }}"
            - name: RUN_ENV
              value: {{ if eq $server.run_env "production" }}"production"{{ else }}"sandbox"{{ end }}
          {{- else }}
          {{- include "generic.envs" $root | nindent 12 }}
          {{- end }}
          {{- include "postgresql.secrets.envs" $root | nindent 12 }}
          {{- include "hyperswitch.configToEnvRefs" (dict "config" $configs "prefix" "ROUTER" "context" $root) | nindent 12 }}
          {{- if $key }}
          {{- $deltas := dict "ROUTER__MASTER_DATABASE__HOST" (include "hyperswitch.router.masterHost" .) "ROUTER__REPLICA_DATABASE__HOST" (include "hyperswitch.router.replicaHost" .) }}
          {{- with $svc.configs }}
          {{- $deltas = merge (include "hyperswitch.configToEnvVars" (dict "config" . "prefix" "ROUTER" "context" $root) | fromYaml) $deltas }}
          {{- end }}
          {{- /* keys already rendered above as fixed env entries, or backed by the release secret */}}
          {{- range $skip := list "ROUTER__EMAIL__ALLOWED_UNVERIFIED_DAYS" "ROUTER__MASTER_DATABASE__PASSWORD" "ROUTER__REPLICA_DATABASE__PASSWORD" "ROUTER__ANALYTICS__SQLX__PASSWORD" }}
          {{- $deltas = unset $deltas $skip }}
          {{- end }}
          {{- range $envKey, $envValue := $deltas }}
            - name: {{ $envKey }}
              value: {{ $envValue | quote }}
          {{- end }}
          {{- end }}
          envFrom:
            - configMapRef:
                name: {{ $root.Release.Name }}-hyperswitch-configs
          {{- if not $root.Values.disableInternalSecrets }}
            - secretRef:
                name: {{ $root.Release.Name }}-hyperswitch-secrets
          {{- end }}
          livenessProbe:
          {{- toYaml ($svc.livenessProbe | default (default $global.livenessProbe $server.livenessProbe)) | nindent 12 }}
          readinessProbe:
          {{- toYaml ($svc.readinessProbe | default (default $global.readinessProbe $server.readinessProbe)) | nindent 12 }}
          ports:
            - containerPort: 8080
              name: http
              protocol: TCP
          resources:
            {{- with ($svc.resources | default (default $global.resources $server.resources)) }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          securityContext:
            privileged: false
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          volumeMounts:
            {{- if eq $server.run_env "production" }}
            - mountPath: /local/config/production.toml
              name: router-config
              subPath: router.toml
            {{- else }}
            - mountPath: /local/config/sandbox.toml
              name: router-config
              subPath: router.toml
            {{- end }}
            {{- if $root.Values.superposition_fallback_efs.enabled }}
            - mountPath: {{ $root.Values.superposition_fallback_efs.mountPath | default "/mnt/data" }}
              name: {{ $root.Values.superposition_fallback_efs.volumeName | default "superposition-config-backup" }}
              readOnly: true
            {{- end }}
            {{- if $root.Values.superpositionFallback.enabled }}
            {{- include "hyperswitch.superpositionFallback.volumeMount" $root | nindent 12 }}
            {{- end }}
            {{- with ($svc.extraVolumeMounts | default $server.extraVolumeMounts) }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccountName: {{ include "hyperswitch.router.serviceAccountName" . }}
      terminationGracePeriodSeconds: {{ $svc.terminationGracePeriodSeconds | default (default $global.terminationGracePeriodSeconds $server.terminationGracePeriodSeconds) }}
      volumes:
        - configMap:
            defaultMode: 420
            name: router-cm-{{ $root.Release.Name }}
          name: router-config
        {{- if $root.Values.superposition_fallback_efs.enabled }}
        - name: {{ $root.Values.superposition_fallback_efs.volumeName | default "superposition-config-backup" }}
          persistentVolumeClaim:
            claimName: {{ $root.Values.superposition_fallback_efs.pvcName }}
        {{- end }}
        {{- if $root.Values.superpositionFallback.enabled }}
        {{- include "hyperswitch.superpositionFallback.volume" $root | nindent 8 }}
        {{- end }}
        {{- with ($svc.extraVolumes | default $server.extraVolumes) }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
{{- end -}}

{{/* ClusterIP Service fronting one router */}}
{{- define "hyperswitch.router.service" -}}
{{- $root := .root -}}
{{- $name := include "hyperswitch.router.name" . -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ $name }}
  namespace: {{ $root.Release.Namespace }}
spec:
  internalTrafficPolicy: Cluster
  ipFamilies:
    - IPv4
  ipFamilyPolicy: SingleStack
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 8080
    - name: https
      port: 443
      protocol: TCP
      targetPort: 8080
  selector:
    app: {{ $name }}
    app.kubernetes.io/instance: {{ $root.Release.Name }}
  sessionAffinity: None
  type: ClusterIP
{{- end -}}

{{/*
HorizontalPodAutoscaler for one router.

The main router keeps the 70% target this chart has always rendered - it never read
`autoscaling.targetCPUUtilizationPercentage`, and changing that here would move the target of
every existing install on upgrade. The extra services honour their own setting.
*/}}
{{- define "hyperswitch.router.hpa" -}}
{{- $root := .root -}}
{{- $key := .key -}}
{{- $svc := default dict (index $root.Values $key) -}}
{{- $name := include "hyperswitch.router.name" . -}}
{{- $as := $root.Values.autoscaling -}}
{{- $ar := $root.Values.argoRollouts -}}
{{- $cpuTarget := 70 -}}
{{- if $key -}}
{{- $as = default dict $svc.autoscaling -}}
{{- $cpuTarget = $as.targetCPUUtilizationPercentage | default 70 -}}
{{- if $svc.argoRollouts -}}
{{- $ar = mergeOverwrite (deepCopy $root.Values.argoRollouts) (deepCopy $svc.argoRollouts) -}}
{{- end -}}
{{- end }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $name }}
spec:
  scaleTargetRef:
    {{- if $ar.enabled }}
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    {{- else }}
    apiVersion: apps/v1
    kind: Deployment
    {{- end }}
    name: {{ $name }}
  minReplicas: {{ $as.minReplicas }}
  maxReplicas: {{ $as.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ $cpuTarget }}
{{- end -}}

{{/* Ingress for one router */}}
{{- define "hyperswitch.router.ingress" -}}
{{- $root := .root -}}
{{- $key := .key -}}
{{- $svc := default dict (index $root.Values $key) -}}
{{- $name := include "hyperswitch.router.name" . -}}
{{- $ingress := $root.Values.server.ingress -}}
{{- if $key -}}
{{- $ingress = default dict $svc.ingress -}}
{{- end }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $name }}-ingress
  namespace: {{ $root.Release.Namespace }}
  annotations:
    {{- with $ingress.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- if $ingress.className }}
  ingressClassName: {{ $ingress.className }}
  {{- end }}
  {{- with $ingress.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    - {{- if $ingress.hostname }}
      host: {{ $ingress.hostname | quote }}
      {{- end }}
      http:
        paths:
          - path: {{ $ingress.path | default "/" }}
            pathType: {{ $ingress.pathType | default "Prefix" }}
            backend:
              service:
                name: {{ $name }}
                port:
                  number: 80
{{- end -}}

{{/* Argo Rollouts AnalysisTemplate for one router */}}
{{- define "hyperswitch.router.analysistemplate" -}}
{{- $root := .root -}}
{{- $key := .key -}}
{{- $svc := default dict (index $root.Values $key) -}}
{{- $name := include "hyperswitch.router.name" . -}}
{{- $ar := $root.Values.argoRollouts -}}
{{- if and $key $svc.argoRollouts -}}
{{- $ar = mergeOverwrite (deepCopy $root.Values.argoRollouts) (deepCopy $svc.argoRollouts) -}}
{{- end -}}
{{- $analysis := $ar.canary.analysis -}}
{{- if $key -}}
{{- if or $analysis.failureThreshold $analysis.errorRatioThreshold $analysis.latencyRatioThreshold $analysis.minTrafficRate -}}
{{- fail (printf "%s.argoRollouts.canary.analysis: threshold keys (failureThreshold, errorRatioThreshold, latencyRatioThreshold, minTrafficRate) have been replaced by the metrics list. See values.yaml." $key) -}}
{{- end -}}
{{- if eq (len ($analysis.metrics | default list)) 0 -}}
{{- fail (printf "%s.argoRollouts.canary.analysis.metrics must have at least one metric when analysis is enabled" $key) -}}
{{- end -}}
{{- else -}}
{{- include "hyperswitch.validateAnalysisConfig" $root -}}
{{- end -}}
{{- $addr := $analysis.victoriaMetrics.address | required "argoRollouts.canary.analysis.victoriaMetrics.address is required when analysis is enabled" -}}
{{- $mergedMetrics := list -}}
{{- range $analysis.metrics -}}
{{- $merged := include "hyperswitch.mergeAnalysisMetric" (dict "metric" . "sharedInterval" $analysis.interval "prometheusAddress" $addr "prometheusTimeout" $analysis.timeout) | fromYaml -}}
{{- $mergedMetrics = append $mergedMetrics $merged -}}
{{- end }}
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: {{ $name }}-canary
  namespace: {{ $root.Release.Namespace }}
  labels:
    {{- include "hyperswitch.labels" $root | nindent 4 }}
spec:
  {{- if $analysis.args }}
  args:
  {{- range $analysis.args }}
  {{- if and .valueFrom .valueFrom.secretKeyRef }}
  - {{ toYaml . | nindent 4 | trim }}
  {{- else }}
  - name: {{ .name }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- if not $analysis.enforce }}
  dryRun:
    - metricName: .*
  {{- end }}
  metrics:
{{ toYaml $mergedMetrics | nindent 4 }}
{{- end -}}

{{/*
VirtualService and DestinationRule for one of the extra router services.

The main router keeps its own templates under templates/istio/ - it carries header-based canary
routing that only makes sense for the release's primary route table.

Set `hosts` and `gateways` to the same values the main VirtualService uses so Istio merges the
two into one route table for that host. Istio does not guarantee rule ordering across
VirtualServices bound to the same host, so keep the main router's catch-all from shadowing the
paths claimed here.
*/}}
{{- define "hyperswitch.router.istio" -}}
{{- $root := .root -}}
{{- $key := .key -}}
{{- $svc := default dict (index $root.Values $key) -}}
{{- $name := include "hyperswitch.router.name" . -}}
{{- $istio := default dict $svc.istio -}}
{{- $vs := default dict $istio.virtualService -}}
{{- $dr := default dict $istio.destinationRule -}}
{{- $ar := $root.Values.argoRollouts -}}
{{- if $svc.argoRollouts -}}
{{- $ar = mergeOverwrite (deepCopy $root.Values.argoRollouts) (deepCopy $svc.argoRollouts) -}}
{{- end -}}
{{- $canary := and $ar.enabled $ar.canary.trafficRouting.istio.enabled -}}
{{- if and $vs.create $vs.http }}
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: {{ $name }}-vs
  namespace: {{ $root.Release.Namespace }}
  labels:
    {{- include "hyperswitch.labels" $root | nindent 4 }}
    app.kubernetes.io/component: istio-virtual-service
    hyperswitch.io/router-service: {{ $key | kebabcase | quote }}
spec:
  {{- if $vs.hosts }}
  hosts:
  {{- toYaml $vs.hosts | nindent 2 }}
  {{- end }}
  {{- if $vs.gateways }}
  gateways:
  {{- toYaml $vs.gateways | nindent 2 }}
  {{- end }}
  http:
  {{- range $vs.http }}
  - {{- if .name }}
    name: {{ .name | quote }}
    {{- end }}
    {{- if .match }}
    match:
      {{- toYaml .match | nindent 6 }}
    {{- end }}
    {{- if .rewrite }}
    rewrite:
      {{- toYaml .rewrite | nindent 6 }}
    {{- end }}
    route:
    {{- if and $canary (mustHas .name $ar.canary.trafficRouting.istio.virtualService.routeNames) }}
    # Argo Rollouts manages these weights during a canary deployment
    - destination:
        host: {{ $name }}
        subset: {{ $ar.canary.trafficRouting.istio.destinationRule.stableSubsetName }}
        port:
          number: 80
      weight: 100
    - destination:
        host: {{ $name }}
        subset: {{ $ar.canary.trafficRouting.istio.destinationRule.canarySubsetName }}
        port:
          number: 80
      weight: 0
    {{- else }}
    - destination:
        host: {{ $name }}
        port:
          number: 80
      weight: {{ .weight | default 100 }}
    {{- end }}
    {{- if .timeout }}
    timeout: {{ .timeout }}
    {{- end }}
    {{- if .retries }}
    retries:
      {{- toYaml .retries | nindent 6 }}
    {{- end }}
  {{- end }}
---
{{ end }}
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: {{ $name }}-dr
  namespace: {{ $root.Release.Namespace }}
  labels:
    {{- include "hyperswitch.labels" $root | nindent 4 }}
    app.kubernetes.io/component: istio-destination-rule
    hyperswitch.io/router-service: {{ $key | kebabcase | quote }}
spec:
  host: {{ $name }}
  {{- if $canary }}
  # Argo Rollouts subset configuration for canary deployments
  subsets:
  - name: {{ $ar.canary.trafficRouting.istio.destinationRule.stableSubsetName }}
    labels:
      app: {{ $name }}
      app.kubernetes.io/instance: {{ $root.Release.Name }}
  - name: {{ $ar.canary.trafficRouting.istio.destinationRule.canarySubsetName }}
    labels:
      app: {{ $name }}
      app.kubernetes.io/instance: {{ $root.Release.Name }}
  {{- end }}
  {{- with $dr.trafficPolicy }}
  trafficPolicy:
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/* Is Argo Rollouts canary analysis on for this router? (release-level block, merged) */}}
{{- define "hyperswitch.router.analysisEnabled" -}}
{{- $root := .root -}}
{{- $svc := default dict (index $root.Values .key) -}}
{{- $ar := $root.Values.argoRollouts -}}
{{- if $svc.argoRollouts -}}
{{- $ar = mergeOverwrite (deepCopy $root.Values.argoRollouts) (deepCopy $svc.argoRollouts) -}}
{{- end -}}
{{- if and $ar.enabled $ar.canary.analysis.enabled -}}true{{- end -}}
{{- end -}}
