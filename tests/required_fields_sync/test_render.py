"""Local Helm renders only; no install, dependency update, API or cluster client.

RF_DEPLOYMENT_FIXTURE must name an explicitly registered private disposable directory.
RF_CHART optionally selects an isolated copy of an exact release tag plus this patch.
"""
import copy
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


def digest(label):
    return hashlib.sha256(label.encode()).hexdigest()


def h(label):
    return "sha256:" + digest(label)


def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"))


def fixture():
    target = dict(target_id="fixture", organisation="synthetic", workspace="disposable", instance_generation=1)
    readers = {
        "main": dict(region="region-a", cluster=h("cluster-a"), namespace="rf-fixture", workload="fixture-router", uid="reader-a", kind="rollout", traffic_resources=["stable", "canary", "endpoints", "mesh"]),
        "shared": dict(region="region-b", cluster=h("cluster-b"), namespace="rf-fixture", workload="fixture-shared", uid="reader-b", kind="deployment", traffic_resources=["service", "endpoints"]),
    }
    registration = dict(schema_version=1, target=target, backing_instance=h("physical-backend"), endpoint_identity=h("endpoint"), coordinator=dict(cluster=h("cluster-a"), namespace="rf-fixture", object="fixture-coordinator", uid="lease-uid"), authority="main", issuer="fixture-issuer", server_contract=h("uncertified-server"), journal_contract=h("uncertified-journal"), controls_contract=h("uncertified-controls"), readers=readers)
    intent = dict(schema_version=1, target=target, issuer="fixture-issuer", authority="main", generation=7, source="4" * 40, application_uid="app-uid", git_revision="5" * 40, executor_image=h("router"), build=h("build"), feature_keys=["V1", "REQUIRED_FIELDS_SYNC"], input_manifest=h("inputs"), bundle=h("bundle"), policy=h("policy"), catalog=h("catalog"), settings=h("settings"), release=h("release"), readers={key: dict(image=h("router" if key == "main" else "older-router"), build=h("build"), inputs=h("inputs"), compatibility=h("both-states-" + key)) for key in readers})
    config = dict(schema_version=1, mode="disabled", target=target, journal_store="fixture-journal", planning=None)
    # This input is deliberately not claimed to pass H's semantic profile validation.
    # Helm proves byte transport only. H remains the parser/renderer/authority boundary.
    s = dict(enabled=False, mode="disabled", renderSuspended=True, releaseClass="v1", authorityRelease="rf", targetId="fixture", coordinatorName="fixture-coordinator", writerSecretRef="fixture-writer", companionImage="fixture.invalid/verifier@" + h("companion"), planHash=h("plan"), registrationJson=encoded(registration), intentJson=encoded(intent), commandJson=encoded(config), inputProfileJson=encoded({"fixture": "synthetic-nonsecret-profile-bytes"}))
    deployment = dict(schema_version=1, status="pending", scope="disabled_definition", authority_release="rf", coordinator_name="fixture-coordinator", verifier_image=s["companionImage"], plan_hash=s["planHash"], external_writer_exclusion="pending", retention="independent_immutable_store_pending", backup="publication_and_startup_canary_pending", web_revision="939f45786aee1c3b14e3f0b134bb42cb2cf2dd39", shared_revision="1af3e5dabf9d5a17dd864ac7312151ebac4367c6", verifier_artifact_sha256="dde73f3935b9d0b10bca5adc9144539dfc88eff3299fe16314e834757748a8c2", case_pack_sha256="a7b7936786fffac90fcdea0669a739dc28e5ade87e7d5989742d54f31443f95e", recovery_image_sha256=digest("retained-recovery-image"), gates={k: "pending" for k in ["server", "journal", "controls", "readers", "v1", "v2", "v3", "v4", "report_delivery", "recovery_image"]})
    for key, field in [("registration", "registrationJson"), ("intent", "intentJson"), ("command", "commandJson"), ("profile", "inputProfileJson")]:
        deployment[key + "_bytes_sha256"] = digest(s[field])
    s["deploymentJson"] = encoded(deployment)
    return {"services": {"router": {"digest": h("router")}}, "requiredFieldsSync": s}


class RenderTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.chart = Path(os.environ.get("RF_CHART", Path(__file__).resolve().parents[2] / "charts/hyperswitch-app")).resolve()
        cls.root = Path(os.environ["RF_DEPLOYMENT_FIXTURE"]).resolve(strict=True)
        marker = json.loads((cls.root / "owner.json").read_text())
        if marker.get("root") != str(cls.root) or marker.get("cleanup_scope") != str(cls.root) or marker.get("hosted_target") is not None or not marker.get("owner"):
            raise ValueError("registered disposable fixture required")

    def render(self, values, succeeds=True):
        run = Path(tempfile.mkdtemp(prefix="render-", dir=self.root))
        config = run / "values.json"
        config.write_text(encoded(values))
        result = subprocess.run(["helm", "template", "rf", str(self.chart), "--namespace", "rf-fixture", "-f", str(config)], text=True, capture_output=True, timeout=30)
        (run / "stderr.txt").write_text(result.stderr)
        if not succeeds:
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("required-fields", result.stderr)
            return
        self.assertEqual(result.returncode, 0, result.stderr)
        manifest = run / "rendered.yaml"
        manifest.write_text(result.stdout)
        parsed = subprocess.run(["yq", "ea", "-o=json", "[.]", str(manifest)], text=True, capture_output=True, check=True, timeout=10)
        return [v for v in json.loads(parsed.stdout) if v]

    def selected(self, docs, kind):
        return [v for v in docs if v["kind"] == kind and v["metadata"]["name"].startswith("rf-rf-")]

    def test_default_adds_no_resources_or_profile(self):
        docs = self.render({})
        self.assertFalse([v for v in docs if v["metadata"]["name"].startswith("rf-rf-")])
        router = next(v for v in docs if v["kind"] in ["Rollout", "Deployment"] and v["metadata"]["name"] == "rf-hyperswitch-server")
        self.assertNotIn("required-fields-inputs", encoded(router))

    def test_both_workload_kinds_use_exact_same_image_and_immutable_bytes(self):
        for rollout in [False, True]:
            with self.subTest(rollout=rollout):
                values = fixture()
                values["argoRollouts"] = {"enabled": rollout, "canary": {"trafficRouting": {"istio": {"enabled": False}}, "analysis": {"enabled": False}}}
                docs = self.render(values)
                job = self.selected(docs, "Job")[0]
                router = next(v for v in docs if v["kind"] == ("Rollout" if rollout else "Deployment") and v["metadata"]["name"] == "rf-hyperswitch-server")
                executor, verifier = job["spec"]["template"]["spec"]["containers"]
                pod = router["spec"]["template"]["spec"]
                self.assertEqual(executor["image"], pod["containers"][0]["image"])
                self.assertTrue(executor["image"].endswith("@" + h("router")))
                cm = self.selected(docs, "ConfigMap")[0]
                self.assertIs(cm["immutable"], True)
                for p in [pod, job["spec"]["template"]["spec"]]:
                    volume = next(v for v in p["volumes"] if v["name"] == "required-fields-inputs")
                    self.assertEqual(volume["configMap"]["name"], cm["metadata"]["name"])
                self.assertEqual(cm["data"]["input-profile.json"], values["requiredFieldsSync"]["inputProfileJson"])
                self.assertEqual(executor["args"], ["required-fields", "apply", "--target", "fixture", "--command-config", "/required-fields-inputs/command.json", "--intent", "7", "--plan-hash", h("plan"), "--output", "/reports/result.json"])
                self.assertEqual(verifier["image"], values["requiredFieldsSync"]["companionImage"])

    def test_lifecycle_no_blind_retry_or_journal_cleanup(self):
        docs = self.render(fixture())
        job = self.selected(docs, "Job")[0]
        self.assertEqual(job["metadata"]["annotations"]["argocd.argoproj.io/hook"], "PostSync")
        self.assertNotIn("argocd.argoproj.io/hook-delete-policy", job["metadata"]["annotations"])
        self.assertEqual([job["spec"][k] for k in ["suspend", "backoffLimit", "parallelism", "completions"]], [True, 0, 1, 1])
        self.assertNotIn("ttlSecondsAfterFinished", job["spec"])
        self.assertEqual(job["spec"]["template"]["spec"]["restartPolicy"], "Never")
        self.assertFalse(self.selected(docs, "PersistentVolumeClaim"))
        self.assertFalse(self.selected(docs, "Lease"))
        self.assertFalse(self.selected(docs, "Secret"))

    def test_companion_has_no_credentials_or_report_writer_mount(self):
        docs = self.render(fixture())
        pod = self.selected(docs, "Job")[0]["spec"]["template"]["spec"]
        self.assertIs(pod["automountServiceAccountToken"], False)
        self.assertIs(pod["shareProcessNamespace"], False)
        executor, companion = pod["containers"]
        self.assertEqual({v["name"] for v in companion["volumeMounts"]}, {"required-fields-inputs", "verifier-work"})
        self.assertTrue({"executor-credentials", "executor-api"} <= {v["name"] for v in executor["volumeMounts"]})
        for c in pod["containers"]:
            self.assertNotIn("envFrom", c)
            self.assertFalse(c["securityContext"]["allowPrivilegeEscalation"])
            self.assertTrue(c["securityContext"]["readOnlyRootFilesystem"])
        role = self.selected(docs, "Role")[0]
        write_rules = [r for r in role["rules"] if set(r["verbs"]) - {"get", "list"}]
        self.assertEqual(write_rules, [{"apiGroups": ["coordination.k8s.io"], "resources": ["leases"], "resourceNames": ["fixture-coordinator"], "verbs": ["get", "update"]}])
        self.assertEqual(self.selected(docs, "NetworkPolicy")[0]["spec"]["egress"], [])

    def test_disabled_and_non_authoritative_writers_cannot_be_enabled(self):
        for key, value in [("enabled", True), ("mode", "apply"), ("mode", "plan"), ("authorityRelease", "another-region"), ("releaseClass", "v2"), ("releaseClass", "olap"), ("releaseClass", "custom"), ("releaseClass", "infraswitch"), ("companionImage", "fixture.invalid/verifier:latest"), ("planHash", "0" * 64)]:
            with self.subTest(key=key, value=value):
                v = fixture(); v["requiredFieldsSync"][key] = value
                self.render(v, succeeds=False)

    def test_mismatched_bytes_or_claimed_certification_refuse(self):
        for mutation in ["settings", "target", "image", "membership", "v2", "certified", "barrier", "retention", "missing-artifact", "oversized"]:
            with self.subTest(mutation=mutation):
                v = fixture(); s = v["requiredFieldsSync"]
                intent = json.loads(s["intentJson"]); deployment = json.loads(s["deploymentJson"])
                if mutation == "settings": s["inputProfileJson"] = '{}'
                if mutation == "target": intent["target"]["workspace"] = "wrong"
                if mutation == "image": intent["executor_image"] = h("wrong")
                if mutation == "membership": del intent["readers"]["shared"]
                if mutation == "v2": intent["feature_keys"].append("V2")
                if mutation == "certified": deployment["gates"]["v3"] = "passed"
                if mutation == "barrier": deployment["external_writer_exclusion"] = "lease-is-enough"
                if mutation == "retention": deployment["retention"] = "job-empty-dir"
                if mutation == "missing-artifact": del deployment["verifier_artifact_sha256"]
                if mutation == "oversized": s["inputProfileJson"] = "x" * 65537
                s["intentJson"] = encoded(intent)
                deployment["intent_bytes_sha256"] = digest(s["intentJson"])
                s["deploymentJson"] = encoded(deployment)
                self.render(v, succeeds=False)

    def test_new_intent_has_new_name_without_deleting_old_job(self):
        first = fixture(); second = copy.deepcopy(first)
        s = second["requiredFieldsSync"]; intent = json.loads(s["intentJson"])
        intent["generation"] += 1; s["intentJson"] = encoded(intent)
        deployment = json.loads(s["deploymentJson"]); deployment["intent_bytes_sha256"] = digest(s["intentJson"])
        s["deploymentJson"] = encoded(deployment)
        a = self.selected(self.render(first), "Job")[0]["metadata"]["name"]
        b = self.selected(self.render(second), "Job")[0]["metadata"]["name"]
        self.assertNotEqual(a, b)
        self.assertEqual(a, self.selected(self.render(first), "Job")[0]["metadata"]["name"])


if __name__ == "__main__":
    unittest.main()
