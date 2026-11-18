{{/* Step 15 is render-only. No values/certificate flag can open production execution. */}}
{{- define "hyperswitch.requiredFields.validate" -}}
{{- $s := .Values.requiredFieldsSync | default dict -}}
{{- if $s.enabled -}}{{ fail "required-fields execution unavailable: certified platform adapters are pending" }}{{- end -}}
{{- if ne ($s.mode | default "disabled") "disabled" -}}{{ fail "required-fields mode must remain disabled" }}{{- end -}}
{{- if $s.renderSuspended -}}
{{- range $key := list "registrationJson" "intentJson" "commandJson" "inputProfileJson" "deploymentJson" -}}
{{- if gt (len (index $s $key | default "")) 65536 -}}{{ fail "required-fields input exceeds 64 KiB" }}{{- end -}}
{{- end -}}
{{- if or (not .Values.services.router.enabled) (ne ($s.releaseClass | default "") "v1") (ne $s.authorityRelease .Release.Name) -}}
{{- fail "required-fields suspended definition requires the explicit main v1 authority release" -}}
{{- end -}}
{{- if not (regexMatch "^sha256:[a-f0-9]{64}$" (.Values.services.router.digest | default "")) -}}{{ fail "required-fields requires the serving router OCI digest" }}{{- end -}}
{{- range $key := list "targetId" "coordinatorName" "writerSecretRef" -}}
{{- if not (regexMatch "^[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?$" (index $s $key | default "")) -}}{{ fail "required-fields names must be explicit DNS labels" }}{{- end -}}
{{- end -}}
{{- if not (regexMatch "^[a-zA-Z0-9./_-]+@sha256:[a-f0-9]{64}$" ($s.companionImage | default "")) -}}{{ fail "required-fields companion must be digest-pinned" }}{{- end -}}
{{- $intent := mustFromJson (required "required-fields intentJson required" $s.intentJson) -}}
{{- $registration := mustFromJson (required "required-fields registrationJson required" $s.registrationJson) -}}
{{- $config := mustFromJson (required "required-fields commandJson required" $s.commandJson) -}}
{{- $profile := mustFromJson (required "required-fields inputProfileJson required" $s.inputProfileJson) -}}
{{- $deployment := mustFromJson (required "required-fields deploymentJson required" $s.deploymentJson) -}}
{{- if or (ne (toJson $registration.target) (toJson $intent.target)) (ne $registration.authority $intent.authority) (ne $registration.issuer $intent.issuer) (ne $registration.coordinator.object $s.coordinatorName) (ne $registration.coordinator.namespace .Release.Namespace) (le (int $intent.target.instance_generation) 0) -}}{{ fail "required-fields registration/intent/coordinator mismatch" }}{{- end -}}
{{- if or (ne (toJson (keys $registration.readers | sortAlpha)) (toJson (keys $intent.readers | sortAlpha))) (gt (len $intent.readers) 32) -}}{{ fail "required-fields complete reader membership required" }}{{- end -}}
{{- if or (ne $config.mode "disabled") (ne $config.target.target_id $s.targetId) (ne (toJson $config.target) (toJson $intent.target)) -}}{{ fail "required-fields command/intent target mismatch or non-disabled command" }}{{- end -}}
{{- if or (le (int $intent.generation) 0) (ne $intent.executor_image .Values.services.router.digest) -}}{{ fail "required-fields intent generation/image mismatch" }}{{- end -}}
{{- if or (not (has "V1" $intent.feature_keys)) (not (has "REQUIRED_FIELDS_SYNC" $intent.feature_keys)) (has "V2" $intent.feature_keys) -}}{{ fail "required-fields unsupported build features" }}{{- end -}}
{{- range $key := list "executor_image" "build" "input_manifest" "bundle" "settings" "policy" "catalog" "release" -}}
{{- if not (regexMatch "^sha256:[a-f0-9]{64}$" (index $intent $key | default "")) -}}{{ fail "required-fields intent hashes must be exact" }}{{- end -}}
{{- end -}}
{{- if or (not (hasKey $intent.readers $intent.authority)) (ne (index $intent.readers $intent.authority).image $intent.executor_image) (ne (index $intent.readers $intent.authority).inputs $intent.input_manifest) (ne (index $intent.readers $intent.authority).build $intent.build) -}}{{ fail "required-fields authority reader binding mismatch" }}{{- end -}}
{{- if not (regexMatch "^sha256:[a-f0-9]{64}$" ($s.planHash | default "")) -}}{{ fail "required-fields accepted plan hash required" }}{{- end -}}
{{- if or (ne $deployment.schema_version 1.0) (ne $deployment.status "pending") (ne $deployment.authority_release $s.authorityRelease) (ne $deployment.coordinator_name $s.coordinatorName) -}}{{ fail "required-fields deployment contract mismatch" }}{{- end -}}
{{- if or (ne $deployment.intent_bytes_sha256 (sha256sum $s.intentJson)) (ne $deployment.command_bytes_sha256 (sha256sum $s.commandJson)) (ne $deployment.profile_bytes_sha256 (sha256sum $s.inputProfileJson)) -}}{{ fail "required-fields immutable input bytes mismatch" }}{{- end -}}
{{- if ne $deployment.registration_bytes_sha256 (sha256sum $s.registrationJson) -}}{{ fail "required-fields registration bytes mismatch" }}{{- end -}}
{{- if or (ne $deployment.scope "disabled_definition") (ne $deployment.external_writer_exclusion "pending") (ne $deployment.retention "independent_immutable_store_pending") (ne $deployment.backup "publication_and_startup_canary_pending") -}}{{ fail "required-fields retention/barrier/backup definitions must remain pending" }}{{- end -}}
{{- range $key := list "web_revision" "shared_revision" -}}
{{- if not (regexMatch "^[a-f0-9]{40}$" (index $deployment $key | default "")) -}}{{ fail "required-fields verifier revision missing" }}{{- end -}}
{{- end -}}
{{- range $key := list "verifier_artifact_sha256" "case_pack_sha256" "recovery_image_sha256" -}}
{{- if not (regexMatch "^[a-f0-9]{64}$" (index $deployment $key | default "")) -}}{{ fail "required-fields retained artifact binding missing" }}{{- end -}}
{{- end -}}
{{- if or (ne $deployment.verifier_image $s.companionImage) (ne $deployment.plan_hash $s.planHash) -}}{{ fail "required-fields plan/verifier binding mismatch" }}{{- end -}}
{{- range $key := list "server" "journal" "controls" "readers" "v1" "v2" "v3" "v4" "report_delivery" "recovery_image" -}}
{{- if ne (index $deployment.gates $key | default "") "pending" -}}{{ fail "required-fields definitions cannot assert platform certification" }}{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "hyperswitch.requiredFields.name" -}}
{{- printf "%s-rf-%s" (.Release.Name | trunc 22 | trimSuffix "-") (include "hyperswitch.requiredFields.digest" . | trunc 24) -}}
{{- end -}}
{{- define "hyperswitch.requiredFields.digest" -}}
{{- $s := .Values.requiredFieldsSync -}}
{{- toJson (list $s.registrationJson $s.intentJson $s.commandJson $s.inputProfileJson $s.deploymentJson $s.planHash $s.companionImage .Values.services.router.digest) | sha256sum -}}
{{- end -}}

{{- define "hyperswitch.requiredFields.mount" -}}
- name: required-fields-inputs
  mountPath: /required-fields-inputs
  readOnly: true
{{- end -}}
{{- define "hyperswitch.requiredFields.volume" -}}
- name: required-fields-inputs
  configMap:
    name: {{ include "hyperswitch.requiredFields.name" . }}
{{- end -}}
