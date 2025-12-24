# hyperswitch-web

![Version: 0.2.14](https://img.shields.io/badge/Version-0.2.14-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.126.0](https://img.shields.io/badge/AppVersion-0.126.0-informational?style=flat-square)

Helm chart for Hyperswitch SDK static Server. This chart allow end user to deploy standalone
[SDK](https://github.com/juspay/hyperswitch-web) with different way:
  - prebuilt nginx static server (deployment - required a specific docker build)
  - autobuild nginx static server (statefulset and assets saved in PVC)

The prebuilt image is suitable for production, no building time.
Autobuild is suitable to quick start, assets are built in initContainer and saved in PVC. Nginx container will serve
assets

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoBuild.buildParam.disableCSP | string | `"false"` |  |
| autoBuild.buildParam.envBackendUrl | string | `"https://hyperswitch"` | node build parameter, hyperswitch server host |
| autoBuild.buildParam.envLogsUrl | string | `"https://hyperswitch-sdk-logs"` | node build parameter, hyperswitch SDK logs host |
| autoBuild.buildParam.envSdkUrl | string | `"https://hyperswitch-sdk"` | node build parameter, hyperswitch-web sdk host (same as ingress host) |
| autoBuild.enable | bool | `true` | enable npm auto build |
| autoBuild.forceBuild | bool | `false` | force rebuild assets even these files exist |
| autoBuild.gitCloneParam.gitRepo | string | `"https://github.com/juspay/hyperswitch-web"` | hyperswitch-web repository |
| autoBuild.gitCloneParam.gitVersion | string | `"0.126.0"` | hyperswitch-web repository tag |
| autoBuild.image | string | `"juspaydotin/hyperswitch-web"` | docker image to use for the build |
| autoBuild.imageRegistry | string | `"docker.juspay.io"` | docker image registry for the build |
| autoBuild.nginxConfig.extraPath | string | `"v1"` | nginx static server extra path ( like https://<host>/0.15.8/v0 ) |
| autoBuild.nginxConfig.image | string | `"nginx"` | nginx static server image |
| autoBuild.nginxConfig.imageRegistry | string | `"docker.io"` | docker image registry for the build |
| autoBuild.nginxConfig.pullPolicy | string | `"IfNotPresent"` | nginx static server pull policy |
| autoBuild.nginxConfig.tag | string | `"1.25.3"` | nginx static server tag |
| autoBuild.pullPolicy | string | `"IfNotPresent"` | docker image pull policy |
| env | object | `{"enableLogging":"false","sdkEnv":"sandbox","sdkTagVersion":"","sdkVersion":"v1","sentryDsn":"","visaApiCertificatePem":"","visaApiKeyId":""}` | Environment variables for hyperswitch-web application |
| env.enableLogging | string | `"false"` | Enable/disable logging |
| env.sdkEnv | string | `"sandbox"` | hyperswitch-web environment (sandbox/prod) |
| env.sdkTagVersion | string | `""` | SDK tag version |
| env.sdkVersion | string | `"v1"` | SDK version |
| env.sentryDsn | string | `""` | Sentry DSN for error tracking |
| env.visaApiCertificatePem | string | `""` | Visa API certificate PEM |
| env.visaApiKeyId | string | `""` | Visa API key ID |
| envFrom[0].configMapRef.name | string | `"hyperswitch-web-nginx"` |  |
| global.imageRegistry | string | `nil` |  |
| ingress.annotations | object | `{}` | ingress annotations |
| ingress.className | string | `"nginx"` | ingress class name |
| ingress.enabled | bool | `true` | enable/disable ingress |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | ingress hosts list |
| ingress.tls | list | `[]` | tls configurations list |
| podAnnotations | object | `{}` | pod annotations |
| podLabels | object | `{}` | pod labels |
| podSecurityContext | object | `{}` | pod security context |
| replicaCount | int | `1` | deployment/statefulset replicas |
| sdkDemo.annotations | object | `{}` |  |
| sdkDemo.enabled | bool | `true` |  |
| sdkDemo.env.binary | string | `"sdk"` |  |
| sdkDemo.env.host | string | `"hyperswitch-sdk-demo"` |  |
| sdkDemo.labels.app | string | `"hyperswitch-sdk-demo"` |  |
| sdkDemo.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution | object | `{}` |  |
| sdkDemo.podAnnotations.traffic_sidecar_istio_io_excludeOutboundIPRanges | string | `"10.23.6.12/32"` |  |
| sdkDemo.progressDeadlineSeconds | int | `600` |  |
| sdkDemo.replicas | int | `1` |  |
| sdkDemo.serviceAccountAnnotations."eks.amazonaws.com/role-arn" | string | `nil` |  |
| sdkDemo.strategy.rollingUpdate.maxSurge | int | `1` |  |
| sdkDemo.strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| sdkDemo.strategy.type | string | `"RollingUpdate"` |  |
| sdkDemo.terminationGracePeriodSeconds | int | `30` |  |
| securityContext | object | `{}` | security context |
| service.port | int | `9050` | service port |
| service.type | string | `"ClusterIP"` | service type |
| services.router.host | string | `"http://localhost:8080"` |  |
| services.sdkDemo.hyperswitchPublishableKey | string | `"pub_key"` |  |
| services.sdkDemo.hyperswitchSecretKey | string | `"secret_key"` |  |
| services.sdkDemo.image | string | `"juspaydotin/hyperswitch-web:v1.0.10"` |  |
| services.sdkDemo.imageRegistry | string | `"docker.juspay.io"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
