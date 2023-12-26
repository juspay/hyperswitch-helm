
# Hyperswitch Helm Chart

This Helm chart is designed to facilitate the deployment of Hyperswitch services, including the AppServer, Control Center, Scheduler services, and the Demo web application.

## Installation Steps

### Build HyperLoader.js (WEB SDK)
Follow the steps below to build your custom HyperLoader.js:

1. Before running the command, please update the following envs with respective values `envSdkUrl` and `envBackendUrl`:

```bash
export envSdkUrl=https://hyperswitch-sdk #do not add / at the end
export envBackendUrl=https://hyperswitch #do not add / at the end
```
2. Clone the Hyperswitch web repository and checkout to version v0.5.6:
```bash
git clone --branch v0.5.6 https://github.com/juspay/hyperswitch-web
cd hyperswitch-web
```
3. Install Node.js version 18, install the project dependencies, and build the project:
```bash
n install 18
npm install
npm run re:build
envSdkUrl=$envSdkUrl envBackendUrl=$envBackendUrl npm run build:integ
```
After running the above commands, a /dist/integ folder will be created. This folder will contain HyperLoader.js.

4. Host all the contents of the /dist/integ folder. Ensure that you can reach `https://{{your_host}}/0.5.6/v0/HyperLoader.js`. 
```
For eg: You can copy all the contents of /dist/integ into an AWS s3 bucket under the folder `0.5.6/v0` and make the bucket public. You will able to access `https://{{your_s3_host}}/0.5.6/v0/HyperLoader.js`.
 ```
### Card Vault installation
If you intend to save cards of your customers for future usage then you need a Card Vault. This helm chart doesn't cover inbuilt card vault support as it will violate PCI compliance. You can install manually by following the steps [here](https://opensource.hyperswitch.io/going-live/pci-compliance/card-vault-installation) or use [this doc to deploy card vault in aws](https://opensource.hyperswitch.io/hyperswitch-open-source/deploy-hyperswitch-on-aws/deploy-card-vault)

### Update Configuration
To deploy the Helm chart, you need to update following values for each service in `values.yaml`

|Service         |Configuration Key              |Description                  |
|----------------|-------------------------------|-----------------------------|
|App Server|`application.server.server_base_url` |Set to the hostname of your Hyperswitch backend for redirection scenarios.|
|          |`application.server.secrets.admin_api_key`            |Used for all admin operations. Replace `"admin_api_key"` with your actual admin API key.            |
|          |`application.server.locker.host`            |[Card Vault](https://opensource.hyperswitch.io/going-live/pci-compliance/card-vault-installation) Hostname            |
|          |`redis.host`            |Hostname of your redis service. it should run in default port 6379            |
|          |`db.name`            |Postgres Database name.            |
|          |`db.host`            |Database Host name            |
|          |`db.replica_host`    |Database Read Replica Host name      |
|          |`db.user_name`            |Database username            |
|          |`db.password`            |Database password            |
| Control Center| `application.dashboard.env.apiBaseUrl` | Set to the hostname of your Hyperswitch backend, so that Control center can access the Hyperswitch backend. |
| | `application.dashboard.env.sdkBaseUrl` | Set to the URL of your hosted Hyperloader, so that you can test Hyperswitch Web SDK  in the Control Center. <br/> Eg: https://{{your_host}}/0.5.6/v0/HyperLoader.js |
| Hyperswitch Demo Store | `application.sdkDemo.env.hyperswitchServerUrl` | Set to the hostname of your Hyperswitch backend to access the Hyperswitch backend. |
| | `application.sdkDemo.env.hyperSwitchClientUrl` | Set to the URL of your hosted Hyperloader to access the Hyperswitch SDK. <br/> Eg: https://{{your_host}}/0.5.6/v0 |

## Installation
### Prerequisite
- [ ] Postgres database created and schema migration completed
```bash
git clone https://github.com/juspay/hyperswitch.git
diesel migration --database-url postgres://{{user}}:{{password}}@localhost:5432/hyperswitch run 
```
- [ ] Active redis service

Use below command to install hyperswitch services with above configs
```bash
helm install hyperswitch-v1 . -n hyperswitch
```

## Post-Deployment Checklist

After deploying the Helm chart, you should verify that everything is working correctly:

### AppServer

- [ ] Check that `hyperswitch_server/health` returns `health is good`.

### Control Center

- [ ] Verify if you are able to sign in or sign up.
- [ ] Verify if you are able to [create API key](https://opensource.hyperswitch.io/run-hyperswitch-locally/account-setup/using-hyperswitch-control-center#user-content-create-an-api-key).
- [ ] Verify if you are able to [configure a new payment processor](https://opensource.hyperswitch.io/run-hyperswitch-locally/account-setup/using-hyperswitch-control-center#add-a-payment-processor).

By following these steps, you can ensure that your Hyperswitch services are correctly deployed and configured.

## Make a payment
 Hyperswitch Demo store will mimic the behaviour of your checkout page. But demo store needs merchant API Key and Publishable Key to work. Please configure below details again in your `values.yaml` 
 |Service         |Configuration Key              |Description                  |
|----------------|-------------------------------|-----------------------------|
| Hyperswitch Demo Store | `application.sdkDemo.env.hyperswitchPublishableKey` | This should be set to your merchant publishable key. You will get this once you create a merchant. |
| | `application.sdkDemo.env.hyperswitchSecretKey` | This should be set to your merchant secret key. You can create this from the control center or via the REST API. |

<b> Run helm upgrade to restart pods with updated config </b>
```bash
helm upgrade --install hyperswitch-v1 . -n hyperswitch -f values.yaml
```
Now open the Demo APP and [make a payment with test card](https://opensource.hyperswitch.io/hyperswitch-open-source/test-a-payment).

Refer our [postman collection](https://www.postman.com/hyperswitch/workspace/hyperswitch/folder/25176183-0103918c-6611-459b-9faf-354dee8e4437) to try out REST APIs

## Get Repo Info

```bash
helm repo add hyperswitch-helm https://juspay.github.io/hyperswitch-helm
helm repo update
```

## Contribution guidelines
When you want others to use the changes you have added you need to package it and then index it

```bash
helm package .
helm repo index . --url https://juspay.github.io/hyperswitch-helm
```
