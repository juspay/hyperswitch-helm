
# Hyperswitch Helm Chart

This Helm chart is designed to facilitate the deployment of Hyperswitch services, including the AppServer, Control Center, Scheduler services, and the Demo app.

## Configuration

### Build Hyperloader JS
Please follow the steps below to build your custom HyperloaderJS:

1. Before running the command, please check `envSdkUrl` and `envBackendUrl`:

```bash
export envSdkUrl=https://hyperswitch-sdk/
export envBackendUrl=https://hyperswitch/
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
After running the above commands, a /dist folder will be created. This folder will contain Hyperloader.js.

4. Host all the contents of the /dist folder. Ensure that you can reach `https://your_host/0.5.6/v0/Hyperloader.js`. For eg: You can copy all the contents of dist into an AWS s3 bucket under the folder `0.5.6/v0` and make the bucket public. You will able to access `https://your_s3_host/0.5.6/v0/Hyperloader.js`. 


### Update Configuration
To deploy the Helm chart, you need to update following values for each service in `values.yaml`

|Service         |Configuration Key              |Description                  |
|----------------|-------------------------------|-----------------------------|
|App Server|`application.server.server_base_url` |Set to the hostname of your Hyperswitch backend for redirection scenarios.|
|          |`application.server.secrets.admin_api_key`            |Used for all admin operations. Replace `"admin_api_key"` with your actual admin API key.            |
| Control Center| `application.dashboard.env.apiBaseUrl` | Set to the hostname of your Hyperswitch backend to access the Hyperswitch backend. |
| | `application.dashboard.env.sdkBaseUrl` | Set to the URL of your hosted Hyperloader to access the Hyperswitch SDK. |
| Hyperswitch Demo Store | `application.sdkDemo.env.hyperswitchServerUrl` | Set to the hostname of your Hyperswitch backend to access the Hyperswitch backend. |
| | `application.sdkDemo.env.hyperSwitchClientUrl` | Set to the URL of your hosted Hyperloader to access the Hyperswitch SDK. |

## Installation
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

Run helm upgrade to restart pods with updated config
```bash
helm upgrade --install hyperswitch-v1 . -n hyperswitch
```
Now open the Demo APP and make a payment with test card.

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
