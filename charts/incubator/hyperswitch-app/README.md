# hyperswitch-app

A Helm chart for Kubernetes to deploy hyperswitch application

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

# Deploy on Kubernetes using Helm

This section outlines cloud-provider agnostic deployment steps for easy installation of the Hyperswitch stack on your K8s cluster

## Installation

### Step 1 - Clone repo and Update Configurations

Clone the [hyperswitch-stack](https://github.com/juspay/hyperswitch-helm) repo and start updating the configs

```
git clone https://github.com/juspay/hyperswitch-helm.git
cd hyperswitch-helm/charts/incubator/hyperswitch-stack
```

### Step 2 - Install Hyperswitch

Before installing the service make sure you labels your kubernetes nodes and create a namespace `hyperswitch`
```bash
kubectl label nodes <your-node-name> node-type=generic-compute
kubectl create namespace hyperswitch
```
Use below command to install hyperswitch services with above configs

```bash
helm install hyperswitch-v1 . -n hyperswitch
```

That's it! Hyperswitch should be up and running on your AWS account  :tada: :tada:

## Post-Deployment Checklist

After deploying the Helm chart, you should verify that everything is working correctly

### App Server

* [ ] &#x20;Check that `hyperswitch_server/health` returns `health is good`

### Control Center

* [ ] &#x20;Verify if you are able to sign in or sign up
* [ ] &#x20;Verify if you are able to [create API key](https://opensource.hyperswitch.io/run-hyperswitch-locally/account-setup/using-hyperswitch-control-center#user-content-create-an-api-key)
* [ ] &#x20;Verify if you are able to [configure a new payment processor](https://opensource.hyperswitch.io/run-hyperswitch-locally/account-setup/using-hyperswitch-control-center#add-a-payment-processor)

## Test a payment

Hyperswitch Demo store will mimic the behavior of your checkout page. Please follow below steps to initiate demo app

### Step 1 - Deploy card vault

### Card Vault Installation

If you intend to save cards of your customers for future usage then you need a Card Vault. This helm chart doesn't cover inbuilt card vault support as it will violate PCI compliance. You can install manually by following the steps [here](https://opensource.hyperswitch.io/going-live/pci-compliance/card-vault-installation) or use [this doc to deploy card vault in aws](https://opensource.hyperswitch.io/hyperswitch-open-source/deploy-hyperswitch-on-aws/deploy-card-vault)

### Step 2 - Configure below details again in your `values.yaml`

| Service                | Configuration Key                                   | Description                                                                                                          |
| ---------------------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| SdkDemo                       | `hyperswitch-sdk.autoBuild.buildParam.envSdkUrl`      | <p>Set to the URL of your hosted Hyperloader to access the Hyperswitch SDK.<br>Eg:https://{your_host}</p> |
|                        | `application.services.sdkDemo.hyperswitchPublishableKey` | This should be set to your merchant publishable key. You will get this once you create a merchant.                   |
|                        | `application.services.sdkDemo.hyperswitchSecretKey`      | This should be set to your merchant secret key. You can create this from the control center or via the REST API.     |

### Step 3 - Run helm upgrade to restart pods with updated config

```
helm upgrade --install hyperswitch-v1 . -n hyperswitch -f values.yaml
```

### Step 4 - Make a payment using our Demo App

Use the Hyperswitch Demo app and [make a payment with test card](https://opensource.hyperswitch.io/hyperswitch-open-source/test-a-payment).

Refer our [postman collection](https://www.postman.com/hyperswitch/workspace/hyperswitch/folder/25176183-0103918c-6611-459b-9faf-354dee8e4437) to try out REST APIs

### Get Repo Info
```bash
helm repo add hyperswitch-helm https://juspay.github.io/hyperswitch-helm
helm repo update
```
### Contribution guidelines
When you want others to use the changes you have added you need to package it and then index it
```bash
helm package .
helm repo index . --url https://juspay.github.io/hyperswitch-helm/<version>
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../hyperswitch-card-vault | hyperswitch-card-vault | 0.1.0 |
| https://charts.bitnami.com/bitnami | clickhouse | 6.3.3 |
| https://charts.bitnami.com/bitnami | kafka | 31.0.0 |
| https://charts.bitnami.com/bitnami | postgresql | 13.2.27 |
| https://charts.bitnami.com/bitnami | redis | 18.6.1 |
| https://codecentric.github.io/helm-charts | mailhog | 4.0.0 |
| https://grafana.github.io/helm-charts | loki-stack | 2.10.2 |
| https://helm.vector.dev | vector | 0.37.0 |

   
## Values
       
               
<h3>Control Center configs</h3>
<table height="400px" >

<thead>
	<th>Key</th>
	<th>Default</th>
	<th>Description</th>
</thead>

<tbody>
	
<tr>
    <td id="application--controlCenter--env--default__endpoints__agreement_url"><div style="max-width: 300px;"><a href="./values.yaml#L731">application.controlCenter.env.default__endpoints__agreement_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"</pre> </div>
</td>
    <td>Hyperswitch terms and conditions url</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__endpoints__agreement_version"><div style="max-width: 300px;"><a href="./values.yaml#L737">application.controlCenter.env.default__endpoints__agreement_version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"1.0.0"</pre> </div>
</td>
    <td>Agreement version</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__endpoints__dss_certificate_url"><div style="max-width: 300px;"><a href="./values.yaml#L734">application.controlCenter.env.default__endpoints__dss_certificate_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://app.hyperswitch.io/certificates/PCI_DSS_v4-0_AOC_Juspay_2024.pdf"</pre> </div>
</td>
    <td>PCI DSS certificate url</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__endpoints__favicon_url"><div style="max-width: 300px;"><a href="./values.yaml#L725">application.controlCenter.env.default__endpoints__favicon_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Endpoints favicon url</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__endpoints__logo_url"><div style="max-width: 300px;"><a href="./values.yaml#L722">application.controlCenter.env.default__endpoints__logo_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Endpoints logo url</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__endpoints__mixpanel_token"><div style="max-width: 300px;"><a href="./values.yaml#L728">application.controlCenter.env.default__endpoints__mixpanel_token</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dd4da7f62941557e716fbc0a19f9cc7e"</pre> </div>
</td>
    <td>Mixpanel token</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__branding"><div style="max-width: 300px;"><a href="./values.yaml#L791">application.controlCenter.env.default__features__branding</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables customization of branding elements like logos, colors.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__email"><div style="max-width: 300px;"><a href="./values.yaml#L746">application.controlCenter.env.default__features__email</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables user sign-in and sign-up using magic links instead of passwords. When enabled, users can request a magic link via email that logs them into their account or creates a new account if they are signing up.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__feedback"><div style="max-width: 300px;"><a href="./values.yaml#L770">application.controlCenter.env.default__features__feedback</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the ability for users to provide direct product feedback from within the dashboard. When enabled, a feedback modal will be available in the UI that allows users to rate features, report bugs, and suggest improvements. Disabling this flag will remove the feedback modal and prevent collection of any user data.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__frm"><div style="max-width: 300px;"><a href="./values.yaml#L758">application.controlCenter.env.default__features__frm</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the Fraud and Risk Management (FRM) module within the dashboard. When enabled, this unlocks integrations with FRM players like Riskified and Signified.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__generate_report"><div style="max-width: 300px;"><a href="./values.yaml#L776">application.controlCenter.env.default__features__generate_report</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Controls the ability to generate detailed reports on payments, refunds, and disputes. When enabled, this allows users to pull reports covering the previous 6 months of transaction data. The reports can provide insights into trends, identify issues, and inform business decisions.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__is_live_mode"><div style="max-width: 300px;"><a href="./values.yaml#L743">application.controlCenter.env.default__features__is_live_mode</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the live mode - that the user is accessing. When enabled, it will show a visual indicator within the dashboard signaling whether the user is currently in a test environment or live production environment. In Live mode, current users are not allowed to sign up. Users must be created manually.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__mixpanel"><div style="max-width: 300px;"><a href="./values.yaml#L773">application.controlCenter.env.default__features__mixpanel</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Controls the collection and transmission of anonymous usage data to Mixpanel for analytics. When enabled, the dashboard will automatically send information about user actions and events to Mixpanel without collecting any personally identifiable information via REST API.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__payout"><div style="max-width: 300px;"><a href="./values.yaml#L761">application.controlCenter.env.default__features__payout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the payout functionality in the dashboard. When enabled, this allows users to configure payout profiles, manage recipient details, schedule disbursements, and process payout batches to pay out funds to third parties.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__quick_start"><div style="max-width: 300px;"><a href="./values.yaml#L749">application.controlCenter.env.default__features__quick_start</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the simplified onboarding flow for new users, where they connect to processors, configure payment routing and test a payment, all in one flow.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__recon"><div style="max-width: 300px;"><a href="./values.yaml#L764">application.controlCenter.env.default__features__recon</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables access to reconciliation capabilities in the Hyperswitch dashboard. When turned on, this unlocks the Reconciliation module that allows users to match payment transactions with bank/ledger entries for accounting purposes.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__sample_data"><div style="max-width: 300px;"><a href="./values.yaml#L755">application.controlCenter.env.default__features__sample_data</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the ability to load simulated sample data into the dashboard for preview purposes. When enabled, dummy transactions, analytics, and reporting data can be generated.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__surcharge"><div style="max-width: 300px;"><a href="./values.yaml#L782">application.controlCenter.env.default__features__surcharge</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the ability to apply surcharges to payments. When enabled, you can create advanced rules based on payment parameters like amount, currency, and payment method to enforce surcharges as needed.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__system_metrics"><div style="max-width: 300px;"><a href="./values.yaml#L752">application.controlCenter.env.default__features__system_metrics</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Unlocks access to system monitoring and metrics pages within the dashboard. When enabled, users can view technical performance data like payment latency, uptime, API response times, error rates, and more.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__test_live_toggle"><div style="max-width: 300px;"><a href="./values.yaml#L740">application.controlCenter.env.default__features__test_live_toggle</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables users to toggle between test and live modes when signing in. When enabled, users will see an option during sign-in to actively switch between test and live environments.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__test_processors"><div style="max-width: 300px;"><a href="./values.yaml#L767">application.controlCenter.env.default__features__test_processors</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Allows enabling sandbox/test payment processors for testing purposes. When enabled, developers and testers can add test payment processors like Stripe Test or PayPal Test to trial payment flows without touching live transactions or making processor API calls.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__totp"><div style="max-width: 300px;"><a href="./values.yaml#L795">application.controlCenter.env.default__features__totp</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables totp will mandate 2fa for all users</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__user_journey_analytics"><div style="max-width: 300px;"><a href="./values.yaml#L779">application.controlCenter.env.default__features__user_journey_analytics</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Grants access to the user journey module within the analytics section of the dashboard. This feature provides comprehensive graphical representations of payment analytics, facilitating a deeper understanding of user behavior and usage patterns.</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__theme__primary_color"><div style="max-width: 300px;"><a href="./values.yaml#L713">application.controlCenter.env.default__theme__primary_color</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#006DF9"</pre> </div>
</td>
    <td>Primary color for the theme</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__theme__primary_hover_color"><div style="max-width: 300px;"><a href="./values.yaml#L716">application.controlCenter.env.default__theme__primary_hover_color</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#005ED6"</pre> </div>
</td>
    <td>Primary hover color for the theme</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__theme__sidebar_color"><div style="max-width: 300px;"><a href="./values.yaml#L719">application.controlCenter.env.default__theme__sidebar_color</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#242F48"</pre> </div>
</td>
    <td>Secondary color for the theme</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--mixpanelToken"><div style="max-width: 300px;"><a href="./values.yaml#L710">application.controlCenter.env.mixpanelToken</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dd4da7f62941557e716fbc0a19f9cc7e"</pre> </div>
</td>
    <td>Mix panel token</td>
</tr>

</tbody>
</table>

               
<h3>App Server Secrets</h3>
<table height="400px" >

<thead>
	<th>Key</th>
	<th>Default</th>
	<th>Description</th>
</thead>

<tbody>
	
<tr>
    <td id="application--server--analytics--clickhouse--database"><div style="max-width: 300px;"><a href="./values.yaml#L269">application.server.analytics.clickhouse.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td>Clickhouse database name</td>
</tr>

	
<tr>
    <td id="application--server--analytics--clickhouse--host"><div style="max-width: 300px;"><a href="./values.yaml#L272">application.server.analytics.clickhouse.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://clickhouse:8123"</pre> </div>
</td>
    <td>Clickhouse host in http(s)://<URL>:<PORT> format</td>
</tr>

	
<tr>
    <td id="application--server--analytics--clickhouse--password"><div style="max-width: 300px;"><a href="./values.yaml#L278">application.server.analytics.clickhouse.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Clickhouse password (optional)</td>
</tr>

	
<tr>
    <td id="application--server--analytics--clickhouse--username"><div style="max-width: 300px;"><a href="./values.yaml#L275">application.server.analytics.clickhouse.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td>Clickhouse username</td>
</tr>

	
<tr>
    <td id="application--server--email--aws_region"><div style="max-width: 300px;"><a href="./values.yaml#L314">application.server.email.aws_region</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"us-east-1"</pre> </div>
</td>
    <td>AWS region used by AWS SES</td>
</tr>

	
<tr>
    <td id="application--server--email--aws_ses--email_role_arn"><div style="max-width: 300px;"><a href="./values.yaml#L318">application.server.email.aws_ses.email_role_arn</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"arn:aws:iam::123456789012:role/SendEmailRole"</pre> </div>
</td>
    <td>The amazon resource name ( arn ) of the role which has permission to send emails</td>
</tr>

	
<tr>
    <td id="application--server--email--aws_ses--sts_role_session_name"><div style="max-width: 300px;"><a href="./values.yaml#L321">application.server.email.aws_ses.sts_role_session_name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"SendEmailRole"</pre> </div>
</td>
    <td>An identifier for the assumed role session, used to uniquely identify a session.</td>
</tr>

	
<tr>
    <td id="application--server--email--prod_intent_recipient_email"><div style="max-width: 300px;"><a href="./values.yaml#L324">application.server.email.prod_intent_recipient_email</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"business@example.com"</pre> </div>
</td>
    <td>Recipient email for prod intent email</td>
</tr>

	
<tr>
    <td id="application--server--email--recon_recipient_email"><div style="max-width: 300px;"><a href="./values.yaml#L327">application.server.email.recon_recipient_email</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"recon@example.com"</pre> </div>
</td>
    <td>Recipient email for recon request email</td>
</tr>

	
<tr>
    <td id="application--server--email--sender_email"><div style="max-width: 300px;"><a href="./values.yaml#L330">application.server.email.sender_email</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"example@example.com"</pre> </div>
</td>
    <td>Sender email</td>
</tr>

	
<tr>
    <td id="application--server--email--smtp--host"><div style="max-width: 300px;"><a href="./values.yaml#L336">application.server.email.smtp.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"mailhog"</pre> </div>
</td>
    <td>Host of the smtp server</td>
</tr>

	
<tr>
    <td id="application--server--email--smtp--password"><div style="max-width: 300px;"><a href="./values.yaml#L341">application.server.email.smtp.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Password for the smtp server</td>
</tr>

	
<tr>
    <td id="application--server--secrets--admin_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L155">application.server.secrets.admin_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"test_admin"</pre> </div>
</td>
    <td>admin API key for admin authentication.</td>
</tr>

	
<tr>
    <td id="application--server--secrets--api_hash_key"><div style="max-width: 300px;"><a href="./values.yaml#L260">application.server.secrets.api_hash_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"</pre> </div>
</td>
    <td>API key hashing key.</td>
</tr>

	
<tr>
    <td id="application--server--secrets--apple_pay_merchant_cert"><div style="max-width: 300px;"><a href="./values.yaml#L230">application.server.secrets.apple_pay_merchant_cert</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
</tr>

	
<tr>
    <td id="application--server--secrets--apple_pay_merchant_cert_key"><div style="max-width: 300px;"><a href="./values.yaml#L233">application.server.secrets.apple_pay_merchant_cert_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Private key generated by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
</tr>

	
<tr>
    <td id="application--server--secrets--apple_pay_merchant_conf_merchant_cert"><div style="max-width: 300px;"><a href="./values.yaml#L242">application.server.secrets.apple_pay_merchant_conf_merchant_cert</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
</tr>

	
<tr>
    <td id="application--server--secrets--apple_pay_merchant_conf_merchant_cert_key"><div style="max-width: 300px;"><a href="./values.yaml#L245">application.server.secrets.apple_pay_merchant_conf_merchant_cert_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Private key generate by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
</tr>

	
<tr>
    <td id="application--server--secrets--apple_pay_merchant_conf_merchant_id"><div style="max-width: 300px;"><a href="./values.yaml#L248">application.server.secrets.apple_pay_merchant_conf_merchant_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Refer to config.example.toml to learn how you can generate this value</td>
</tr>

	
<tr>
    <td id="application--server--secrets--apple_pay_ppc"><div style="max-width: 300px;"><a href="./values.yaml#L236">application.server.secrets.apple_pay_ppc</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Payment Processing Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Payment Processing Certificate</td>
</tr>

	
<tr>
    <td id="application--server--secrets--apple_pay_ppc_key"><div style="max-width: 300px;"><a href="./values.yaml#L239">application.server.secrets.apple_pay_ppc_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Private key generated by Elliptic-curve prime256v1 curve. You can use `openssl ecparam -out private.key -name prime256v1 -genkey` to generate the private key</td>
</tr>

	
<tr>
    <td id="application--server--secrets--forex_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L251">application.server.secrets.forex_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Api key for making request to foreign exchange Api, Follow https://github.com/juspay/hyperswitch/tree/main/crates/analytics#setting-up-forex-apis to get the forex api key</td>
</tr>

	
<tr>
    <td id="application--server--secrets--forex_fallback_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L254">application.server.secrets.forex_fallback_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Forex Api key for the fallback service</td>
</tr>

	
<tr>
    <td id="application--server--secrets--jwt_secret"><div style="max-width: 300px;"><a href="./values.yaml#L158">application.server.secrets.jwt_secret</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"test_admin"</pre> </div>
</td>
    <td>JWT secret used for user authentication.</td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_jwekey_vault_encryption_key"><div style="max-width: 300px;"><a href="./values.yaml#L174">application.server.secrets.kms_jwekey_vault_encryption_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>The public key for the locker from locker-public-key.pub, these are only test keys, please change it when deploying to production or other environments</td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_jwekey_vault_private_key"><div style="max-width: 300px;"><a href="./values.yaml#L187">application.server.secrets.kms_jwekey_vault_private_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>The private key for the tenant from tenant-private-key.pem, these are only test keys, please change it when deploying to production or other environments</td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_key_id"><div style="max-width: 300px;"><a href="./values.yaml#L167">application.server.secrets.kms_key_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"kms_key_id"</pre> </div>
</td>
    <td>KMS key id for encryption and decryption</td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_key_region"><div style="max-width: 300px;"><a href="./values.yaml#L170">application.server.secrets.kms_key_region</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"us-east-1"</pre> </div>
</td>
    <td>AWS KMS region</td>
</tr>

	
<tr>
    <td id="application--server--secrets--master_enc_key"><div style="max-width: 300px;"><a href="./values.yaml#L161">application.server.secrets.master_enc_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"471f22516724347bcca9c20c5fa88d9821c4604e63a6aceffd24605809c9237c"</pre> </div>
</td>
    <td>Master Encryption key used to encrypt merchant wise encryption key. Should be 32-byte long.</td>
</tr>

	
<tr>
    <td id="application--server--secrets--pm_auth_key"><div style="max-width: 300px;"><a href="./values.yaml#L257">application.server.secrets.pm_auth_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td># Payment method auth key used for authorization</td>
</tr>

	
<tr>
    <td id="application--server--secrets--recon_admin_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L164">application.server.secrets.recon_admin_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"test_admin"</pre> </div>
</td>
    <td>Recon Admin API key for recon admin authentication.</td>
</tr>

	
<tr>
    <td id="application--server--secrets--redis_temp_locker_encryption_key"><div style="max-width: 300px;"><a href="./values.yaml#L227">application.server.secrets.redis_temp_locker_encryption_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Encryption key for redis temp locker</td>
</tr>

	
<tr>
    <td id="application--server--secrets--user_auth_encryption_key"><div style="max-width: 300px;"><a href="./values.yaml#L263">application.server.secrets.user_auth_encryption_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Encryption key used for encrypting data in user_authentication_methods table</td>
</tr>

</tbody>
</table>

               
<h3>Dependencies configuration</h3>
<table height="400px" >

<thead>
	<th>Key</th>
	<th>Default</th>
	<th>Description</th>
</thead>

<tbody>
	
<tr>
    <td id="clickhouse--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L1019">clickhouse.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Clickhouse password</td>
</tr>

	
<tr>
    <td id="clickhouse--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L1016">clickhouse.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td>Clickhouse username</td>
</tr>

	
<tr>
    <td id="clickhouse--config--TZ"><div style="max-width: 300px;"><a href="./values.yaml#L1025">clickhouse.config.TZ</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Asia/Kolkata"</pre> </div>
</td>
    <td>Clickhouse timezone</td>
</tr>

	
<tr>
    <td id="clickhouse--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1008">clickhouse.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Clickhouse sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="clickhouse--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L1011">clickhouse.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"clickhouse"</pre> </div>
</td>
    <td>Name of the Clickhouse sub-chart</td>
</tr>

	
<tr>
    <td id="clickhouse--logLevel"><div style="max-width: 300px;"><a href="./values.yaml#L1046">clickhouse.logLevel</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"error"</pre> </div>
</td>
    <td>Clickhouse log level</td>
</tr>

	
<tr>
    <td id="clickhouse--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L1031">clickhouse.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Clickhouse replica count</td>
</tr>

	
<tr>
    <td id="clickhouse--shards"><div style="max-width: 300px;"><a href="./values.yaml#L1028">clickhouse.shards</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Clickhouse shard count</td>
</tr>

	
<tr>
    <td id="clickhouse--ulimits--nofile--hard"><div style="max-width: 300px;"><a href="./values.yaml#L1039">clickhouse.ulimits.nofile.hard</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>262144</pre> </div>
</td>
    <td>Clickhouse hard limit</td>
</tr>

	
<tr>
    <td id="clickhouse--ulimits--nofile--soft"><div style="max-width: 300px;"><a href="./values.yaml#L1036">clickhouse.ulimits.nofile.soft</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>262144</pre> </div>
</td>
    <td>Clickhouse soft limit</td>
</tr>

	
<tr>
    <td id="clickhouse--zookeeper--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L1043">clickhouse.zookeeper.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Zookerper replica count</td>
</tr>

	
<tr>
    <td id="externalPostgresql--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L894">externalPostgresql.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Link this service to an external Postgres server</td>
</tr>

	
<tr>
    <td id="externalPostgresql--primary--auth--database"><div style="max-width: 300px;"><a href="./values.yaml#L911">externalPostgresql.primary.auth.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>master DB name</td>
</tr>

	
<tr>
    <td id="externalPostgresql--primary--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L905">externalPostgresql.primary.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>master DB password</td>
</tr>

	
<tr>
    <td id="externalPostgresql--primary--auth--plainpassword"><div style="max-width: 300px;"><a href="./values.yaml#L908">externalPostgresql.primary.auth.plainpassword</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>master DB plainpassword</td>
</tr>

	
<tr>
    <td id="externalPostgresql--primary--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L902">externalPostgresql.primary.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>master DB username</td>
</tr>

	
<tr>
    <td id="externalPostgresql--primary--host"><div style="max-width: 300px;"><a href="./values.yaml#L898">externalPostgresql.primary.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"postgresql-ext"</pre> </div>
</td>
    <td>External postgres host</td>
</tr>

	
<tr>
    <td id="externalPostgresql--readOnly--auth--database"><div style="max-width: 300px;"><a href="./values.yaml#L931">externalPostgresql.readOnly.auth.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>replica DB name</td>
</tr>

	
<tr>
    <td id="externalPostgresql--readOnly--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L925">externalPostgresql.readOnly.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>replica DB password</td>
</tr>

	
<tr>
    <td id="externalPostgresql--readOnly--auth--plainpassword"><div style="max-width: 300px;"><a href="./values.yaml#L928">externalPostgresql.readOnly.auth.plainpassword</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>replica DB plainpassword</td>
</tr>

	
<tr>
    <td id="externalPostgresql--readOnly--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L922">externalPostgresql.readOnly.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>replica DB username</td>
</tr>

	
<tr>
    <td id="externalPostgresql--readOnly--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L915">externalPostgresql.readOnly.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>External postgres read only host enabled or disabled</td>
</tr>

	
<tr>
    <td id="externalPostgresql--readOnly--host"><div style="max-width: 300px;"><a href="./values.yaml#L918">externalPostgresql.readOnly.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"postgres-service"</pre> </div>
</td>
    <td>External postgres read only host</td>
</tr>

	
<tr>
    <td id="externalRedis--auth--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L831">externalRedis.auth.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>auth enabled or disabled</td>
</tr>

	
<tr>
    <td id="externalRedis--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L837">externalRedis.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>redis password</td>
</tr>

	
<tr>
    <td id="externalRedis--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L834">externalRedis.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>redis username</td>
</tr>

	
<tr>
    <td id="externalRedis--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L824">externalRedis.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Link this service to an external Redis server</td>
</tr>

	
<tr>
    <td id="externalRedis--host"><div style="max-width: 300px;"><a href="./values.yaml#L827">externalRedis.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"redis-ext-master"</pre> </div>
</td>
    <td>External redis host</td>
</tr>

	
<tr>
    <td id="kafka--broker--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L968">kafka.broker.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for broker</td>
</tr>

	
<tr>
    <td id="kafka--controller--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L964">kafka.controller.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for controller</td>
</tr>

	
<tr>
    <td id="kafka--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L956">kafka.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Kafka sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="kafka--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L959">kafka.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"kafka0"</pre> </div>
</td>
    <td>Name of the Kafka sub-chart</td>
</tr>

	
<tr>
    <td id="kafka--listeners--client--protocol"><div style="max-width: 300px;"><a href="./values.yaml#L984">kafka.listeners.client.protocol</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PLAINTEXT"</pre> </div>
</td>
    <td>Listener client protocol</td>
</tr>

	
<tr>
    <td id="kafka--listeners--controller--protocol"><div style="max-width: 300px;"><a href="./values.yaml#L996">kafka.listeners.controller.protocol</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PLAINTEXT"</pre> </div>
</td>
    <td>Listener controller protocol</td>
</tr>

	
<tr>
    <td id="kafka--listeners--external--protocol"><div style="max-width: 300px;"><a href="./values.yaml#L992">kafka.listeners.external.protocol</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PLAINTEXT"</pre> </div>
</td>
    <td>Listener external protocol</td>
</tr>

	
<tr>
    <td id="kafka--listeners--interbroker--protocol"><div style="max-width: 300px;"><a href="./values.yaml#L988">kafka.listeners.interbroker.protocol</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PLAINTEXT"</pre> </div>
</td>
    <td>Listener interbroker protocol</td>
</tr>

	
<tr>
    <td id="kafka--provisioning--replicationFactor"><div style="max-width: 300px;"><a href="./values.yaml#L1000">kafka.provisioning.replicationFactor</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>kafka provisioning replicationFactor</td>
</tr>

	
<tr>
    <td id="kafka--service--ports--client"><div style="max-width: 300px;"><a href="./values.yaml#L979">kafka.service.ports.client</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>29092</pre> </div>
</td>
    <td>Client port for Kafka</td>
</tr>

	
<tr>
    <td id="kafka--zookeeper--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L974">kafka.zookeeper.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for zookeeper</td>
</tr>

	
<tr>
    <td id="loki-stack--grafana--adminPassword"><div style="max-width: 300px;"><a href="./values.yaml#L1099">loki-stack.grafana.adminPassword</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"admin"</pre> </div>
</td>
    <td>Name of the Grafana sub-chart</td>
</tr>

	
<tr>
    <td id="loki-stack--grafana--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1096">loki-stack.grafana.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Grafana sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="loki-stack--grafana--image--tag"><div style="max-width: 300px;"><a href="./values.yaml#L1103">loki-stack.grafana.image.tag</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"10.0.1"</pre> </div>
</td>
    <td>Grafana image tag</td>
</tr>

	
<tr>
    <td id="loki-stack--loki--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1076">loki-stack.loki.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Loki sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="loki-stack--loki--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L1079">loki-stack.loki.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"loki"</pre> </div>
</td>
    <td>Name of the Loki sub-chart</td>
</tr>

	
<tr>
    <td id="loki-stack--promtail--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1083">loki-stack.promtail.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Promtail sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="mailhog--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1067">mailhog.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Mailhog sub-chart helm installation for email testing</td>
</tr>

	
<tr>
    <td id="mailhog--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L1070">mailhog.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"mailhog"</pre> </div>
</td>
    <td>Name of the Mailhog sub-chart</td>
</tr>

	
<tr>
    <td id="postgresql--architecture"><div style="max-width: 300px;"><a href="./values.yaml#L864">postgresql.architecture</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"replication"</pre> </div>
</td>
    <td>Postgresql architecture: replication or standalone</td>
</tr>

	
<tr>
    <td id="postgresql--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L849">postgresql.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>enable Bitnami postgresql sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="postgresql--global--postgresql--auth--database"><div style="max-width: 300px;"><a href="./values.yaml#L861">postgresql.global.postgresql.auth.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>Postgresql database</td>
</tr>

	
<tr>
    <td id="postgresql--global--postgresql--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L858">postgresql.global.postgresql.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ZGJwYXNzd29yZDEx"</pre> </div>
</td>
    <td>Postgresql password</td>
</tr>

	
<tr>
    <td id="postgresql--global--postgresql--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L855">postgresql.global.postgresql.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>Postgresql username</td>
</tr>

	
<tr>
    <td id="postgresql--primary--name"><div style="max-width: 300px;"><a href="./values.yaml#L875">postgresql.primary.name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>postgres primary name</td>
</tr>

	
<tr>
    <td id="postgresql--primary--resources--requests--cpu"><div style="max-width: 300px;"><a href="./values.yaml#L880">postgresql.primary.resources.requests.cpu</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"150m"</pre> </div>
</td>
    <td>CPU resource requests</td>
</tr>

	
<tr>
    <td id="postgresql--readReplicas--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L884">postgresql.readReplicas.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of read replicas</td>
</tr>

	
<tr>
    <td id="postgresql--readReplicas--resources--requests--cpu"><div style="max-width: 300px;"><a href="./values.yaml#L889">postgresql.readReplicas.resources.requests.cpu</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"100m"</pre> </div>
</td>
    <td>CPU resource requests</td>
</tr>

	
<tr>
    <td id="postgresql--replication--numSynchronousReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L871">postgresql.replication.numSynchronousReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of synchronous replicas</td>
</tr>

	
<tr>
    <td id="postgresql--replication--synchronousCommit"><div style="max-width: 300px;"><a href="./values.yaml#L868">postgresql.replication.synchronousCommit</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"off"</pre> </div>
</td>
    <td>synchronous_commit parameter</td>
</tr>

	
<tr>
    <td id="redis--auth--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L816">redis.auth.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>enable or disable redis auth</td>
</tr>

	
<tr>
    <td id="redis--auth--sentinel"><div style="max-width: 300px;"><a href="./values.yaml#L819">redis.auth.sentinel</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>enable or disable sentinel</td>
</tr>

	
<tr>
    <td id="redis--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L804">redis.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>- enable Bitnami redis sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="redis--master--count"><div style="max-width: 300px;"><a href="./values.yaml#L808">redis.master.count</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for master</td>
</tr>

	
<tr>
    <td id="redis--replica--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L812">redis.replica.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>0</pre> </div>
</td>
    <td>Number of replicas to be used for replica</td>
</tr>

	
<tr>
    <td id="vector--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1108">vector.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Vector sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="vector--env[0]"><div style="max-width: 300px;"><a href="./values.yaml#L1112">vector.env[0]</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "name": "KAFKA_HOST",
  "value": "kafka0:29092"
}</pre> </div>
</td>
    <td>Vector environment variables</td>
</tr>

</tbody>
</table>

               
<h3>Services</h3>
<table height="400px" >

<thead>
	<th>Key</th>
	<th>Default</th>
	<th>Description</th>
</thead>

<tbody>
	
<tr>
    <td id="services--consumer--image"><div style="max-width: 300px;"><a href="./values.yaml#L15">services.consumer.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-consumer:v1.112.0"</pre> </div>
</td>
    <td>Consumer image</td>
</tr>

	
<tr>
    <td id="services--controlCenter--image"><div style="max-width: 300px;"><a href="./values.yaml#L23">services.controlCenter.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-control-center:v1.34.2"</pre> </div>
</td>
    <td>Control Center image</td>
</tr>

	
<tr>
    <td id="services--producer--image"><div style="max-width: 300px;"><a href="./values.yaml#L19">services.producer.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-producer:v1.112.0"</pre> </div>
</td>
    <td>Producer image</td>
</tr>

	
<tr>
    <td id="services--router--host"><div style="max-width: 300px;"><a href="./values.yaml#L11">services.router.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:8080"</pre> </div>
</td>
    <td>Router host</td>
</tr>

	
<tr>
    <td id="services--router--image"><div style="max-width: 300px;"><a href="./values.yaml#L8">services.router.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-router:v1.112.0"</pre> </div>
</td>
    <td>Router image</td>
</tr>

	
<tr>
    <td id="services--router--version"><div style="max-width: 300px;"><a href="./values.yaml#L5">services.router.version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v1.112.0"</pre> </div>
</td>
    <td>Router version</td>
</tr>

	
<tr>
    <td id="services--sdk--host"><div style="max-width: 300px;"><a href="./values.yaml#L27">services.sdk.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:9090"</pre> </div>
</td>
    <td>SDK host</td>
</tr>

	
<tr>
    <td id="services--sdk--subversion"><div style="max-width: 300px;"><a href="./values.yaml#L33">services.sdk.subversion</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v0"</pre> </div>
</td>
    <td>SDK subversion</td>
</tr>

	
<tr>
    <td id="services--sdk--version"><div style="max-width: 300px;"><a href="./values.yaml#L30">services.sdk.version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0.103.1"</pre> </div>
</td>
    <td>SDK version</td>
</tr>

</tbody>
</table>

   
   
<h3>Other Values</h3>
<table>

<thead>
	<th>Key</th>
	<th>Default</th>
	<th>Description</th>
</thead>

<tbody>
	
<tr>
    <td id="global--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L4">global.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="global--nodeAffinity--requiredDuringSchedulingIgnoredDuringExecution"><div style="max-width: 300px;"><a href="./values.yaml#L8">global.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L696">application.controlCenter.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "deployment.kubernetes.io/revision": "1"
}</pre> </div>
</td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--binary"><div style="max-width: 300px;"><a href="./values.yaml#L706">application.controlCenter.env.binary</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dashboard"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__authentication_analytics"><div style="max-width: 300px;"><a href="./values.yaml#L792">application.controlCenter.env.default__features__authentication_analytics</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__compliance_certificate"><div style="max-width: 300px;"><a href="./values.yaml#L798">application.controlCenter.env.default__features__compliance_certificate</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__configure_pmts"><div style="max-width: 300px;"><a href="./values.yaml#L788">application.controlCenter.env.default__features__configure_pmts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__custom_webhook_headers"><div style="max-width: 300px;"><a href="./values.yaml#L797">application.controlCenter.env.default__features__custom_webhook_headers</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__dispute_analytics"><div style="max-width: 300px;"><a href="./values.yaml#L787">application.controlCenter.env.default__features__dispute_analytics</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__dispute_evidence_upload"><div style="max-width: 300px;"><a href="./values.yaml#L783">application.controlCenter.env.default__features__dispute_evidence_upload</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__global_search"><div style="max-width: 300px;"><a href="./values.yaml#L786">application.controlCenter.env.default__features__global_search</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__live_users_counter"><div style="max-width: 300px;"><a href="./values.yaml#L796">application.controlCenter.env.default__features__live_users_counter</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__paypal_automatic_flow"><div style="max-width: 300px;"><a href="./values.yaml#L784">application.controlCenter.env.default__features__paypal_automatic_flow</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__performance_monitor"><div style="max-width: 300px;"><a href="./values.yaml#L799">application.controlCenter.env.default__features__performance_monitor</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__pm_authentication_processor"><div style="max-width: 300px;"><a href="./values.yaml#L800">application.controlCenter.env.default__features__pm_authentication_processor</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--default__features__threeds_authenticator"><div style="max-width: 300px;"><a href="./values.yaml#L785">application.controlCenter.env.default__features__threeds_authenticator</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--env--host"><div style="max-width: 300px;"><a href="./values.yaml#L707">application.controlCenter.env.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-control-center"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--controlCenter--labels"><div style="max-width: 300px;"><a href="./values.yaml#L699">application.controlCenter.labels</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "app": "hyperswitch-control-center"
}</pre> </div>
</td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
</tr>

	
<tr>
    <td id="application--controlCenter--podAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L693">application.controlCenter.podAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "traffic_sidecar_istio_io_excludeOutboundIPRanges": "10.23.6.12/32"
}</pre> </div>
</td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
</tr>

	
<tr>
    <td id="application--controlCenter--progressDeadlineSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L673">application.controlCenter.progressDeadlineSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>600</pre> </div>
</td>
    <td>Wait time allowed for the deployment before the deployment is marked as failed</td>
</tr>

	
<tr>
    <td id="application--controlCenter--replicas"><div style="max-width: 300px;"><a href="./values.yaml#L671">application.controlCenter.replicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for the application</td>
</tr>

	
<tr>
    <td id="application--controlCenter--serviceAccountAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L702">application.controlCenter.serviceAccountAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "eks.amazonaws.com/role-arn": null
}</pre> </div>
</td>
    <td>service account annotations to be used</td>
</tr>

	
<tr>
    <td id="application--controlCenter--strategy"><div style="max-width: 300px;"><a href="./values.yaml#L675">application.controlCenter.strategy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "rollingUpdate": {
    "maxSurge": 1,
    "maxUnavailable": 0
  },
  "type": "RollingUpdate"
}</pre> </div>
</td>
    <td>The strategy that can be used to replace the old pods by new ones</td>
</tr>

	
<tr>
    <td id="application--controlCenter--terminationGracePeriodSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L691">application.controlCenter.terminationGracePeriodSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>The time kubernetes will wait after sending the termination signal to the pods</td>
</tr>

	
<tr>
    <td id="application--server--analytics--source"><div style="max-width: 300px;"><a href="./values.yaml#L280">application.server.analytics.source</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"clickhouse"</pre> </div>
</td>
    <td>The Analytics source/strategy to be used</td>
</tr>

	
<tr>
    <td id="application--server--analytics--sqlx--connection_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L283">application.server.analytics.sqlx.connection_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>Timeout for database connection in seconds</td>
</tr>

	
<tr>
    <td id="application--server--analytics--sqlx--pool_size"><div style="max-width: 300px;"><a href="./values.yaml#L285">application.server.analytics.sqlx.pool_size</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Number of connections to keep open</td>
</tr>

	
<tr>
    <td id="application--server--analytics--sqlx--queue_strategy"><div style="max-width: 300px;"><a href="./values.yaml#L287">application.server.analytics.sqlx.queue_strategy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Fifo"</pre> </div>
</td>
    <td>Add the queue strategy used by the database bb8 client</td>
</tr>

	
<tr>
    <td id="application--server--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L140">application.server.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "deployment.kubernetes.io/revision": "1"
}</pre> </div>
</td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
</tr>

	
<tr>
    <td id="application--server--applepay_merchant_configs--applepay_endpoint"><div style="max-width: 300px;"><a href="./values.yaml#L290">application.server.applepay_merchant_configs.applepay_endpoint</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://apple-pay-gateway.apple.com/paymentservices/registerMerchant"</pre> </div>
</td>
    <td>Apple pay gateway merchant endpoint</td>
</tr>

	
<tr>
    <td id="application--server--cell_information--id"><div style="max-width: 300px;"><a href="./values.yaml#L293">application.server.cell_information.id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"12345"</pre> </div>
</td>
    <td>Default CellID for Global Cell Information</td>
</tr>

	
<tr>
    <td id="application--server--connector_onboarding--paypal--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L296">application.server.connector_onboarding.paypal.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--connector_request_reference_id_config--merchant_ids_send_payment_id_as_connector_request_id"><div style="max-width: 300px;"><a href="./values.yaml#L299">application.server.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"['merchant_id_1','merchant_id_2']"</pre> </div>
</td>
    <td>List of merchant ids for which the payment id should be sent as connector request id</td>
</tr>

	
<tr>
    <td id="application--server--cors--allowed_methods"><div style="max-width: 300px;"><a href="./values.yaml#L302">application.server.cors.allowed_methods</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"GET,POST,PUT,DELETE"</pre> </div>
</td>
    <td>List of methods that are allowed</td>
</tr>

	
<tr>
    <td id="application--server--cors--max_age"><div style="max-width: 300px;"><a href="./values.yaml#L304">application.server.cors.max_age</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>Maximum time (in seconds) for which this CORS request may be cached.</td>
</tr>

	
<tr>
    <td id="application--server--cors--wildcard_origin"><div style="max-width: 300px;"><a href="./values.yaml#L306">application.server.cors.wildcard_origin</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>If true, allows any origin to make requests</td>
</tr>

	
<tr>
    <td id="application--server--email--active_email_client"><div style="max-width: 300px;"><a href="./values.yaml#L309">application.server.email.active_email_client</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"SES"</pre> </div>
</td>
    <td>The currently active email client</td>
</tr>

	
<tr>
    <td id="application--server--email--allowed_unverified_days"><div style="max-width: 300px;"><a href="./values.yaml#L311">application.server.email.allowed_unverified_days</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of days the api calls ( with jwt token ) can be made without verifying the email</td>
</tr>

	
<tr>
    <td id="application--server--email--smtp--connection"><div style="max-width: 300px;"><a href="./values.yaml#L333">application.server.email.smtp.connection</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"plaintext"</pre> </div>
</td>
    <td>connection type to be used for the smtp server</td>
</tr>

	
<tr>
    <td id="application--server--email--smtp--port"><div style="max-width: 300px;"><a href="./values.yaml#L343">application.server.email.smtp.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"1025"</pre> </div>
</td>
    <td>Port of the smtp server</td>
</tr>

	
<tr>
    <td id="application--server--email--smtp--timeout"><div style="max-width: 300px;"><a href="./values.yaml#L345">application.server.email.smtp.timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>timeout for the smtp server connection</td>
</tr>

	
<tr>
    <td id="application--server--email--smtp--username"><div style="max-width: 300px;"><a href="./values.yaml#L338">application.server.email.smtp.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Username for the smtp server</td>
</tr>

	
<tr>
    <td id="application--server--encryption_management--encryption_manager"><div style="max-width: 300px;"><a href="./values.yaml#L348">application.server.encryption_management.encryption_manager</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"no_encryption"</pre> </div>
</td>
    <td>Encryption manager client to be used</td>
</tr>

	
<tr>
    <td id="application--server--env"><div style="max-width: 300px;"><a href="./values.yaml#L149">application.server.env</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "binary": "router",
  "host": "hyperswitch"
}</pre> </div>
</td>
    <td>Environmant variables that are to be used by the hyperswitch application service this will extend the existing global configuration</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--api_logs_topic"><div style="max-width: 300px;"><a href="./values.yaml#L354">application.server.events.kafka.api_logs_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-api-log-events"</pre> </div>
</td>
    <td>Kafka topic to be used for incoming api events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--attempt_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L356">application.server.events.kafka.attempt_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payment-attempt-events"</pre> </div>
</td>
    <td>Kafka topic to be used for PaymentAttempt events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--audit_events_topic"><div style="max-width: 300px;"><a href="./values.yaml#L358">application.server.events.kafka.audit_events_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-audit-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Payment Audit events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--authentication_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L360">application.server.events.kafka.authentication_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-authentication-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Authentication events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--brokers"><div style="max-width: 300px;"><a href="./values.yaml#L361">application.server.events.kafka.brokers</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"['kafka0:29092']"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--connector_logs_topic"><div style="max-width: 300px;"><a href="./values.yaml#L363">application.server.events.kafka.connector_logs_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-outgoing-connector-events"</pre> </div>
</td>
    <td>Kafka topic to be used for connector api events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--consolidated_events_topic"><div style="max-width: 300px;"><a href="./values.yaml#L365">application.server.events.kafka.consolidated_events_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-consolidated-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Consolidated events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--dispute_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L367">application.server.events.kafka.dispute_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-dispute-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Dispute events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--fraud_check_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L369">application.server.events.kafka.fraud_check_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-fraud-check-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Fraud Check events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--intent_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L371">application.server.events.kafka.intent_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payment-intent-events"</pre> </div>
</td>
    <td>Kafka topic to be used for PaymentIntent events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--outgoing_webhook_logs_topic"><div style="max-width: 300px;"><a href="./values.yaml#L373">application.server.events.kafka.outgoing_webhook_logs_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-outgoing-webhook-events"</pre> </div>
</td>
    <td>Kafka topic to be used for outgoing webhook events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--payout_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L375">application.server.events.kafka.payout_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payout-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Payouts and PayoutAttempt events</td>
</tr>

	
<tr>
    <td id="application--server--events--kafka--refund_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L377">application.server.events.kafka.refund_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-refund-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Refund events</td>
</tr>

	
<tr>
    <td id="application--server--events--source"><div style="max-width: 300px;"><a href="./values.yaml#L351">application.server.events.source</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"kafka"</pre> </div>
</td>
    <td>The event sink to push events supports kafka or logs (stdout)</td>
</tr>

	
<tr>
    <td id="application--server--forex_api--api_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L386">application.server.forex_api.api_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>20001</pre> </div>
</td>
    <td>Api timeouts once it crosses 20000 ms</td>
</tr>

	
<tr>
    <td id="application--server--forex_api--call_delay"><div style="max-width: 300px;"><a href="./values.yaml#L380">application.server.forex_api.call_delay</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>21601</pre> </div>
</td>
    <td>Api calls are made after every 6 hrs</td>
</tr>

	
<tr>
    <td id="application--server--forex_api--local_fetch_retry_count"><div style="max-width: 300px;"><a href="./values.yaml#L382">application.server.forex_api.local_fetch_retry_count</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Fetch from Local cache has retry count as 5</td>
</tr>

	
<tr>
    <td id="application--server--forex_api--local_fetch_retry_delay"><div style="max-width: 300px;"><a href="./values.yaml#L384">application.server.forex_api.local_fetch_retry_delay</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1010</pre> </div>
</td>
    <td>Retry delay for checking write condition</td>
</tr>

	
<tr>
    <td id="application--server--forex_api--redis_lock_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L388">application.server.forex_api.redis_lock_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>260001</pre> </div>
</td>
    <td>Redis remains write locked for 26000 ms once the acquire_redis_lock is called</td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payment_method_collect--enabled_payment_methods--bank_transfer"><div style="max-width: 300px;"><a href="./values.yaml#L397">application.server.generic_link.payment_method_collect.enabled_payment_methods.bank_transfer</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ach,bacs,sepa"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payment_method_collect--enabled_payment_methods--card"><div style="max-width: 300px;"><a href="./values.yaml#L396">application.server.generic_link.payment_method_collect.enabled_payment_methods.card</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"credit,debit"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payment_method_collect--enabled_payment_methods--wallet"><div style="max-width: 300px;"><a href="./values.yaml#L398">application.server.generic_link.payment_method_collect.enabled_payment_methods.wallet</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"paypal,pix,venmo"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payment_method_collect--ui_config--logo"><div style="max-width: 300px;"><a href="./values.yaml#L392">application.server.generic_link.payment_method_collect.ui_config.logo</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://app.hyperswitch.io/HyperswitchFavicon.png"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payment_method_collect--ui_config--merchant_name"><div style="max-width: 300px;"><a href="./values.yaml#L393">application.server.generic_link.payment_method_collect.ui_config.merchant_name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"HyperSwitch"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payment_method_collect--ui_config--theme"><div style="max-width: 300px;"><a href="./values.yaml#L394">application.server.generic_link.payment_method_collect.ui_config.theme</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#4285F4"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payout_link--enabled_payment_methods--card"><div style="max-width: 300px;"><a href="./values.yaml#L401">application.server.generic_link.payout_link.enabled_payment_methods.card</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"credit,debit"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payout_link--ui_config--logo"><div style="max-width: 300px;"><a href="./values.yaml#L403">application.server.generic_link.payout_link.ui_config.logo</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://app.hyperswitch.io/HyperswitchFavicon.png"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payout_link--ui_config--merchant_name"><div style="max-width: 300px;"><a href="./values.yaml#L404">application.server.generic_link.payout_link.ui_config.merchant_name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"HyperSwitch"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--generic_link--payout_link--ui_config--theme"><div style="max-width: 300px;"><a href="./values.yaml#L405">application.server.generic_link.payout_link.ui_config.theme</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#4285F4"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--grpc_client--dynamic_routing_client--host"><div style="max-width: 300px;"><a href="./values.yaml#L409">application.server.grpc_client.dynamic_routing_client.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"localhost"</pre> </div>
</td>
    <td>Client Host</td>
</tr>

	
<tr>
    <td id="application--server--grpc_client--dynamic_routing_client--port"><div style="max-width: 300px;"><a href="./values.yaml#L411">application.server.grpc_client.dynamic_routing_client.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>7000</pre> </div>
</td>
    <td>Client Port</td>
</tr>

	
<tr>
    <td id="application--server--grpc_client--dynamic_routing_client--service"><div style="max-width: 300px;"><a href="./values.yaml#L413">application.server.grpc_client.dynamic_routing_client.service</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dynamo"</pre> </div>
</td>
    <td>Client Service Name</td>
</tr>

	
<tr>
    <td id="application--server--labels"><div style="max-width: 300px;"><a href="./values.yaml#L143">application.server.labels</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "app": "hyperswitch-server"
}</pre> </div>
</td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
</tr>

	
<tr>
    <td id="application--server--lock_settings--delay_between_retries_in_milliseconds"><div style="max-width: 300px;"><a href="./values.yaml#L417">application.server.lock_settings.delay_between_retries_in_milliseconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>500</pre> </div>
</td>
    <td>Delay between retries in milliseconds</td>
</tr>

	
<tr>
    <td id="application--server--lock_settings--redis_lock_expiry_seconds"><div style="max-width: 300px;"><a href="./values.yaml#L419">application.server.lock_settings.redis_lock_expiry_seconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>180</pre> </div>
</td>
    <td>Seconds before the redis lock expires</td>
</tr>

	
<tr>
    <td id="application--server--locker--host"><div style="max-width: 300px;"><a href="./values.yaml#L425">application.server.locker.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://hyperswitch-vault"</pre> </div>
</td>
    <td>Locker host</td>
</tr>

	
<tr>
    <td id="application--server--locker--host_rs"><div style="max-width: 300px;"><a href="./values.yaml#L427">application.server.locker.host_rs</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>Rust Locker host</td>
</tr>

	
<tr>
    <td id="application--server--locker--locker_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L429">application.server.locker.locker_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Boolean to enable or disable saving cards in locker</td>
</tr>

	
<tr>
    <td id="application--server--locker--locker_signing_key_id"><div style="max-width: 300px;"><a href="./values.yaml#L431">application.server.locker.locker_signing_key_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"1"</pre> </div>
</td>
    <td>Key_id to sign basilisk hs locker</td>
</tr>

	
<tr>
    <td id="application--server--locker--mock_locker"><div style="max-width: 300px;"><a href="./values.yaml#L433">application.server.locker.mock_locker</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Emulate a locker locally using Postgres</td>
</tr>

	
<tr>
    <td id="application--server--locker--ttl_for_storage_in_secs"><div style="max-width: 300px;"><a href="./values.yaml#L435">application.server.locker.ttl_for_storage_in_secs</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>220752000</pre> </div>
</td>
    <td>Time to live for storage entries in locker</td>
</tr>

	
<tr>
    <td id="application--server--log--console--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L438">application.server.log.console.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--log--console--level"><div style="max-width: 300px;"><a href="./values.yaml#L440">application.server.log.console.level</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"DEBUG"</pre> </div>
</td>
    <td>Log level for console logs, ERROR, WARN, INFO, DEBUG</td>
</tr>

	
<tr>
    <td id="application--server--log--console--log_format"><div style="max-width: 300px;"><a href="./values.yaml#L441">application.server.log.console.log_format</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"json"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--log--file--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L443">application.server.log.file.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--log--file--level"><div style="max-width: 300px;"><a href="./values.yaml#L444">application.server.log.file.level</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"DEBUG"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--log--file--log_format"><div style="max-width: 300px;"><a href="./values.yaml#L445">application.server.log.file.log_format</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"json"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--bg_metrics_collection_interval_in_secs"><div style="max-width: 300px;"><a href="./values.yaml#L449">application.server.log.telemetry.bg_metrics_collection_interval_in_secs</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>15</pre> </div>
</td>
    <td>Interval for collecting the metrics in background thread</td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--ignore_errors"><div style="max-width: 300px;"><a href="./values.yaml#L451">application.server.log.telemetry.ignore_errors</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>boolean [true or false], whether to ignore errors during traces or metrics pipeline setup</td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--metrics_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L453">application.server.log.telemetry.metrics_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>boolean [true or false], whether metrics are enabled</td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--otel_exporter_otlp_endpoint"><div style="max-width: 300px;"><a href="./values.yaml#L455">application.server.log.telemetry.otel_exporter_otlp_endpoint</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:4317"</pre> </div>
</td>
    <td>endpoint to send metrics and traces to, can include port number</td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--otel_exporter_otlp_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L457">application.server.log.telemetry.otel_exporter_otlp_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5000</pre> </div>
</td>
    <td>timeout (in milliseconds) for sending metrics and traces</td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--route_to_trace"><div style="max-width: 300px;"><a href="./values.yaml#L458">application.server.log.telemetry.route_to_trace</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"['*/confirm']"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--sampling_rate"><div style="max-width: 300px;"><a href="./values.yaml#L459">application.server.log.telemetry.sampling_rate</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>0.1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--traces_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L461">application.server.log.telemetry.traces_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>boolean [true or false], whether traces are enabled</td>
</tr>

	
<tr>
    <td id="application--server--log--telemetry--use_xray_generator"><div style="max-width: 300px;"><a href="./values.yaml#L463">application.server.log.telemetry.use_xray_generator</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Set this to true for AWS X-ray compatible traces</td>
</tr>

	
<tr>
    <td id="application--server--master_database--connection_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L467">application.server.master_database.connection_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>Timeout for database connection in seconds</td>
</tr>

	
<tr>
    <td id="application--server--master_database--pool_size"><div style="max-width: 300px;"><a href="./values.yaml#L469">application.server.master_database.pool_size</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"20"</pre> </div>
</td>
    <td>Number of connections to keep open</td>
</tr>

	
<tr>
    <td id="application--server--master_database--queue_strategy"><div style="max-width: 300px;"><a href="./values.yaml#L471">application.server.master_database.queue_strategy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Fifo"</pre> </div>
</td>
    <td>Add the queue strategy used by the database bb8 client</td>
</tr>

	
<tr>
    <td id="application--server--multitenancy--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L473">application.server.multitenancy.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--multitenancy--global_tenant--clickhouse_database"><div style="max-width: 300px;"><a href="./values.yaml#L475">application.server.multitenancy.global_tenant.clickhouse_database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--multitenancy--global_tenant--redis_key_prefix"><div style="max-width: 300px;"><a href="./values.yaml#L476">application.server.multitenancy.global_tenant.redis_key_prefix</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--multitenancy--global_tenant--schema"><div style="max-width: 300px;"><a href="./values.yaml#L477">application.server.multitenancy.global_tenant.schema</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"public"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--multitenancy--tenants--public--base_url"><div style="max-width: 300px;"><a href="./values.yaml#L480">application.server.multitenancy.tenants.public.base_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:8080"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--multitenancy--tenants--public--clickhouse_database"><div style="max-width: 300px;"><a href="./values.yaml#L481">application.server.multitenancy.tenants.public.clickhouse_database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--multitenancy--tenants--public--redis_key_prefix"><div style="max-width: 300px;"><a href="./values.yaml#L482">application.server.multitenancy.tenants.public.redis_key_prefix</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--multitenancy--tenants--public--schema"><div style="max-width: 300px;"><a href="./values.yaml#L483">application.server.multitenancy.tenants.public.schema</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"public"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--auth--auth"><div style="max-width: 300px;"><a href="./values.yaml#L486">application.server.opensearch.auth.auth</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"basic"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L488">application.server.opensearch.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"admin"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--auth--region"><div style="max-width: 300px;"><a href="./values.yaml#L489">application.server.opensearch.auth.region</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"eu-central-1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L487">application.server.opensearch.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"admin"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--host"><div style="max-width: 300px;"><a href="./values.yaml#L490">application.server.opensearch.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://localhost:9200"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--indexes--disputes"><div style="max-width: 300px;"><a href="./values.yaml#L492">application.server.opensearch.indexes.disputes</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-dispute-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--indexes--payment_attempts"><div style="max-width: 300px;"><a href="./values.yaml#L493">application.server.opensearch.indexes.payment_attempts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payment-attempt-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--indexes--payment_intents"><div style="max-width: 300px;"><a href="./values.yaml#L494">application.server.opensearch.indexes.payment_intents</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payment-intent-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--indexes--refunds"><div style="max-width: 300px;"><a href="./values.yaml#L495">application.server.opensearch.indexes.refunds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-refund-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--indexes--sessionizer_disputes"><div style="max-width: 300px;"><a href="./values.yaml#L496">application.server.opensearch.indexes.sessionizer_disputes</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sessionizer-dispute-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--indexes--sessionizer_payment_attempts"><div style="max-width: 300px;"><a href="./values.yaml#L497">application.server.opensearch.indexes.sessionizer_payment_attempts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sessionizer-payment-attempt-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--indexes--sessionizer_payment_intents"><div style="max-width: 300px;"><a href="./values.yaml#L498">application.server.opensearch.indexes.sessionizer_payment_intents</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sessionizer-payment-intent-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--opensearch--indexes--sessionizer_refunds"><div style="max-width: 300px;"><a href="./values.yaml#L499">application.server.opensearch.indexes.sessionizer_refunds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sessionizer-refund-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--payment_method_auth--redis_expiry"><div style="max-width: 300px;"><a href="./values.yaml#L502">application.server.payment_method_auth.redis_expiry</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>900</pre> </div>
</td>
    <td>Redis expiry time in milliseconds</td>
</tr>

	
<tr>
    <td id="application--server--paze_decrypt_keys--paze_private_key"><div style="max-width: 300px;"><a href="./values.yaml#L505">application.server.paze_decrypt_keys.paze_private_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PAZE_PRIVATE_KEY"</pre> </div>
</td>
    <td>Base 64 Encoded Private Key File cakey.pem generated for Paze -> Command to create private key: openssl req -newkey rsa:2048 -x509 -keyout cakey.pem -out cacert.pem -days 365</td>
</tr>

	
<tr>
    <td id="application--server--paze_decrypt_keys--paze_private_key_passphrase"><div style="max-width: 300px;"><a href="./values.yaml#L507">application.server.paze_decrypt_keys.paze_private_key_passphrase</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PAZE_PRIVATE_KEY_PASSPHRASE"</pre> </div>
</td>
    <td>PEM Passphrase used for generating Private Key File cakey.pem</td>
</tr>

	
<tr>
    <td id="application--server--podAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L137">application.server.podAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "traffic_sidecar_istio_io_excludeOutboundIPRanges": "10.23.6.12/32"
}</pre> </div>
</td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
</tr>

	
<tr>
    <td id="application--server--progressDeadlineSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L93">application.server.progressDeadlineSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>600</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--proxy--bypass_proxy_urls"><div style="max-width: 300px;"><a href="./values.yaml#L510">application.server.proxy.bypass_proxy_urls</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td>A list of URLs that should bypass the proxy</td>
</tr>

	
<tr>
    <td id="application--server--proxy--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L511">application.server.proxy.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--proxy--http_url"><div style="max-width: 300px;"><a href="./values.yaml#L513">application.server.proxy.http_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://proxy_http_url"</pre> </div>
</td>
    <td>Outgoing proxy http URL to proxy the HTTP traffic</td>
</tr>

	
<tr>
    <td id="application--server--proxy--https_url"><div style="max-width: 300px;"><a href="./values.yaml#L515">application.server.proxy.https_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://proxy_https_url"</pre> </div>
</td>
    <td>Outgoing proxy https URL to proxy the HTTPS traffic</td>
</tr>

	
<tr>
    <td id="application--server--redis--auto_pipeline"><div style="max-width: 300px;"><a href="./values.yaml#L519">application.server.redis.auto_pipeline</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Whether or not the client should automatically pipeline commands across tasks when possible.</td>
</tr>

	
<tr>
    <td id="application--server--redis--cluster_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L521">application.server.redis.cluster_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>boolean</td>
</tr>

	
<tr>
    <td id="application--server--redis--cluster_urls"><div style="max-width: 300px;"><a href="./values.yaml#L523">application.server.redis.cluster_urls</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"['redis.cluster.uri-1:8080', 'redis.cluster.uri-2:4115']"</pre> </div>
</td>
    <td>List of redis cluster urls</td>
</tr>

	
<tr>
    <td id="application--server--redis--default_command_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L525">application.server.redis.default_command_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>An optional timeout to apply to all commands. In seconds</td>
</tr>

	
<tr>
    <td id="application--server--redis--default_hash_ttl"><div style="max-width: 300px;"><a href="./values.yaml#L527">application.server.redis.default_hash_ttl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>900</pre> </div>
</td>
    <td>Default TTL for hashes entries, in seconds</td>
</tr>

	
<tr>
    <td id="application--server--redis--default_ttl"><div style="max-width: 300px;"><a href="./values.yaml#L529">application.server.redis.default_ttl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>300</pre> </div>
</td>
    <td>Default TTL for entries, in seconds</td>
</tr>

	
<tr>
    <td id="application--server--redis--disable_auto_backpressure"><div style="max-width: 300px;"><a href="./values.yaml#L531">application.server.redis.disable_auto_backpressure</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Whether or not to disable the automatic backpressure features when pipelining is enabled.</td>
</tr>

	
<tr>
    <td id="application--server--redis--host"><div style="max-width: 300px;"><a href="./values.yaml#L532">application.server.redis.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"127.0.0.1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--redis--max_feed_count"><div style="max-width: 300px;"><a href="./values.yaml#L534">application.server.redis.max_feed_count</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>200</pre> </div>
</td>
    <td>The maximum number of frames that will be fed to a socket before flushing.</td>
</tr>

	
<tr>
    <td id="application--server--redis--max_in_flight_commands"><div style="max-width: 300px;"><a href="./values.yaml#L536">application.server.redis.max_in_flight_commands</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5000</pre> </div>
</td>
    <td>The maximum number of in-flight commands (per connection) before backpressure will be applied.</td>
</tr>

	
<tr>
    <td id="application--server--redis--pool_size"><div style="max-width: 300px;"><a href="./values.yaml#L538">application.server.redis.pool_size</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Number of connections to keep open</td>
</tr>

	
<tr>
    <td id="application--server--redis--port"><div style="max-width: 300px;"><a href="./values.yaml#L539">application.server.redis.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>6379</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--redis--reconnect_delay"><div style="max-width: 300px;"><a href="./values.yaml#L541">application.server.redis.reconnect_delay</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Delay between reconnection attempts, in milliseconds</td>
</tr>

	
<tr>
    <td id="application--server--redis--reconnect_max_attempts"><div style="max-width: 300px;"><a href="./values.yaml#L543">application.server.redis.reconnect_max_attempts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Maximum number of reconnection attempts to make before failing. Set to 0 to retry forever.</td>
</tr>

	
<tr>
    <td id="application--server--redis--stream_read_count"><div style="max-width: 300px;"><a href="./values.yaml#L545">application.server.redis.stream_read_count</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Default number of entries to read from stream if not provided in stream read options</td>
</tr>

	
<tr>
    <td id="application--server--redis--unresponsive_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L547">application.server.redis.unresponsive_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>An optional timeout for Unresponsive commands in seconds. This should be less than default_command_timeout.</td>
</tr>

	
<tr>
    <td id="application--server--redis--use_legacy_version"><div style="max-width: 300px;"><a href="./values.yaml#L549">application.server.redis.use_legacy_version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>RESP protocol for fred crate (set this to true if using RESPv2 or redis version < 6)</td>
</tr>

	
<tr>
    <td id="application--server--replica_database--connection_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L553">application.server.replica_database.connection_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>Timeout for database connection in seconds</td>
</tr>

	
<tr>
    <td id="application--server--replica_database--pool_size"><div style="max-width: 300px;"><a href="./values.yaml#L555">application.server.replica_database.pool_size</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"20"</pre> </div>
</td>
    <td>Number of connections to keep open</td>
</tr>

	
<tr>
    <td id="application--server--replica_database--queue_strategy"><div style="max-width: 300px;"><a href="./values.yaml#L557">application.server.replica_database.queue_strategy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Fifo"</pre> </div>
</td>
    <td>Add the queue strategy used by the database bb8 client</td>
</tr>

	
<tr>
    <td id="application--server--replicas"><div style="max-width: 300px;"><a href="./values.yaml#L91">application.server.replicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for the application</td>
</tr>

	
<tr>
    <td id="application--server--report_download_config--dispute_function"><div style="max-width: 300px;"><a href="./values.yaml#L560">application.server.report_download_config.dispute_function</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"report_download_config_dispute_function"</pre> </div>
</td>
    <td>Config to download dispute report</td>
</tr>

	
<tr>
    <td id="application--server--report_download_config--payment_function"><div style="max-width: 300px;"><a href="./values.yaml#L562">application.server.report_download_config.payment_function</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"report_download_config_payment_function"</pre> </div>
</td>
    <td>Config to download payment report</td>
</tr>

	
<tr>
    <td id="application--server--report_download_config--refund_function"><div style="max-width: 300px;"><a href="./values.yaml#L564">application.server.report_download_config.refund_function</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"report_download_config_refund_function"</pre> </div>
</td>
    <td>Config to download refund report</td>
</tr>

	
<tr>
    <td id="application--server--report_download_config--region"><div style="max-width: 300px;"><a href="./values.yaml#L566">application.server.report_download_config.region</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"report_download_config_region"</pre> </div>
</td>
    <td>Region of the bucket</td>
</tr>

	
<tr>
    <td id="application--server--run_env"><div style="max-width: 300px;"><a href="./values.yaml#L568">application.server.run_env</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sandbox"</pre> </div>
</td>
    <td>Processor URLs will be decided based on this config, Eg: sandbox or production</td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_connector_onboarding_paypal_client_id"><div style="max-width: 300px;"><a href="./values.yaml#L220">application.server.secrets.kms_connector_onboarding_paypal_client_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_connector_onboarding_paypal_client_secret"><div style="max-width: 300px;"><a href="./values.yaml#L222">application.server.secrets.kms_connector_onboarding_paypal_client_secret</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_connector_onboarding_paypal_partner_id"><div style="max-width: 300px;"><a href="./values.yaml#L224">application.server.secrets.kms_connector_onboarding_paypal_partner_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_jwekey_rust_locker_encryption_key"><div style="max-width: 300px;"><a href="./values.yaml#L218">application.server.secrets.kms_jwekey_rust_locker_encryption_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--secrets--kms_jwekey_tunnel_private_key"><div style="max-width: 300px;"><a href="./values.yaml#L216">application.server.secrets.kms_jwekey_tunnel_private_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--secrets_management--hc_vault--token"><div style="max-width: 300px;"><a href="./values.yaml#L574">application.server.secrets_management.hc_vault.token</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"vault_token"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--secrets_management--hc_vault--url"><div style="max-width: 300px;"><a href="./values.yaml#L573">application.server.secrets_management.hc_vault.url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://vault:8200"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--secrets_management--secrets_manager"><div style="max-width: 300px;"><a href="./values.yaml#L571">application.server.secrets_management.secrets_manager</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"no_encryption"</pre> </div>
</td>
    <td>Secrets manager client to be used</td>
</tr>

	
<tr>
    <td id="application--server--server--host"><div style="max-width: 300px;"><a href="./values.yaml#L577">application.server.server.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0.0.0.0"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--server--port"><div style="max-width: 300px;"><a href="./values.yaml#L578">application.server.server.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>8080</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--server--request_body_limit"><div style="max-width: 300px;"><a href="./values.yaml#L580">application.server.server.request_body_limit</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>32768</pre> </div>
</td>
    <td>HTTP Request body limit. Defaults to 32kB</td>
</tr>

	
<tr>
    <td id="application--server--server--shutdown_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L583">application.server.server.shutdown_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>For more details: https://actix.rs/docs/server/#graceful-shutdown</td>
</tr>

	
<tr>
    <td id="application--server--server--workers"><div style="max-width: 300px;"><a href="./values.yaml#L584">application.server.server.workers</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>8</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--serviceAccountAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L146">application.server.serviceAccountAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "eks.amazonaws.com/role-arn": "my-role-arn"
}</pre> </div>
</td>
    <td>service account annotations to be used</td>
</tr>

	
<tr>
    <td id="application--server--strategy--rollingUpdate--maxSurge"><div style="max-width: 300px;"><a href="./values.yaml#L97">application.server.strategy.rollingUpdate.maxSurge</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--strategy--rollingUpdate--maxUnavailable"><div style="max-width: 300px;"><a href="./values.yaml#L98">application.server.strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>0</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--strategy--type"><div style="max-width: 300px;"><a href="./values.yaml#L99">application.server.strategy.type</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"RollingUpdate"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--terminationGracePeriodSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L135">application.server.terminationGracePeriodSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>The time kubernetes will wait after sending the termination signal to the pods</td>
</tr>

	
<tr>
    <td id="application--server--user--base_url"><div style="max-width: 300px;"><a href="./values.yaml#L586">application.server.user.base_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:9000"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--user--force_two_factor_auth"><div style="max-width: 300px;"><a href="./values.yaml#L587">application.server.user.force_two_factor_auth</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--user--password_validity_in_days"><div style="max-width: 300px;"><a href="./values.yaml#L588">application.server.user.password_validity_in_days</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"90"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--user--totp_issuer_name"><div style="max-width: 300px;"><a href="./values.yaml#L589">application.server.user.totp_issuer_name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Hyperswitch Sandbox"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="application--server--user--two_factor_auth_expiry_in_secs"><div style="max-width: 300px;"><a href="./values.yaml#L590">application.server.user.two_factor_auth_expiry_in_secs</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"300"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="autoscaling--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L945">autoscaling.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="autoscaling--maxReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L947">autoscaling.maxReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="autoscaling--minReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L946">autoscaling.minReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="autoscaling--targetCPUUtilizationPercentage"><div style="max-width: 300px;"><a href="./values.yaml#L948">autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>80</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="clickhouse--image--tag"><div style="max-width: 300px;"><a href="./values.yaml#L1021">clickhouse.image.tag</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>24.3</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="clickhouse--resourcesPreset"><div style="max-width: 300px;"><a href="./values.yaml#L1012">clickhouse.resourcesPreset</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"none"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L951">hyperswitch-card-vault.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="initDB--checkPGisUp--image"><div style="max-width: 300px;"><a href="./values.yaml#L936">initDB.checkPGisUp.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"postgres:16-alpine3.19"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="initDB--checkPGisUp--maxAttempt"><div style="max-width: 300px;"><a href="./values.yaml#L937">initDB.checkPGisUp.maxAttempt</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="initDB--enable"><div style="max-width: 300px;"><a href="./values.yaml#L934">initDB.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="initDB--migration--image"><div style="max-width: 300px;"><a href="./values.yaml#L939">initDB.migration.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"christophwurst/diesel-cli:latest"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="kafka--extraConfig"><div style="max-width: 300px;"><a href="./values.yaml#L1001">kafka.extraConfig</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"offsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\n"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="loadBalancer--targetSecurityGroup"><div style="max-width: 300px;"><a href="./values.yaml#L942">loadBalancer.targetSecurityGroup</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"loadBalancer-sg"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="redisMiscConfig--checkRedisIsUp--initContainer--enable"><div style="max-width: 300px;"><a href="./values.yaml#L842">redisMiscConfig.checkRedisIsUp.initContainer.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="redisMiscConfig--checkRedisIsUp--initContainer--image"><div style="max-width: 300px;"><a href="./values.yaml#L843">redisMiscConfig.checkRedisIsUp.initContainer.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"redis:7.2.4"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="redisMiscConfig--checkRedisIsUp--initContainer--maxAttempt"><div style="max-width: 300px;"><a href="./values.yaml#L844">redisMiscConfig.checkRedisIsUp.initContainer.maxAttempt</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--external--postgresql--config--database"><div style="max-width: 300px;"><a href="./values.yaml#L125">hyperswitch-card-vault.external.postgresql.config.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--external--postgresql--config--host"><div style="max-width: 300px;"><a href="./values.yaml#L121">hyperswitch-card-vault.external.postgresql.config.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--external--postgresql--config--password"><div style="max-width: 300px;"><a href="./values.yaml#L124">hyperswitch-card-vault.external.postgresql.config.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--external--postgresql--config--port"><div style="max-width: 300px;"><a href="./values.yaml#L122">hyperswitch-card-vault.external.postgresql.config.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--external--postgresql--config--username"><div style="max-width: 300px;"><a href="./values.yaml#L123">hyperswitch-card-vault.external.postgresql.config.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--external--postgresql--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L119">hyperswitch-card-vault.external.postgresql.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--initDB--checkPGisUp--image"><div style="max-width: 300px;"><a href="./values.yaml#L132">hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"postgres:16-alpine3.19"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--initDB--checkPGisUp--maxAttempt"><div style="max-width: 300px;"><a href="./values.yaml#L133">hyperswitch-card-vault.initDB.checkPGisUp.maxAttempt</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--initDB--enable"><div style="max-width: 300px;"><a href="./values.yaml#L130">hyperswitch-card-vault.initDB.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--initDB--migration--image"><div style="max-width: 300px;"><a href="./values.yaml#L135">hyperswitch-card-vault.initDB.migration.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"christophwurst/diesel-cli:latest"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--postgresql--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L102">hyperswitch-card-vault.postgresql.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--postgresql--global--postgresql--auth--architecture"><div style="max-width: 300px;"><a href="./values.yaml#L110">hyperswitch-card-vault.postgresql.global.postgresql.auth.architecture</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"standalone"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--postgresql--global--postgresql--auth--database"><div style="max-width: 300px;"><a href="./values.yaml#L109">hyperswitch-card-vault.postgresql.global.postgresql.auth.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"locker-db"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--postgresql--global--postgresql--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L108">hyperswitch-card-vault.postgresql.global.postgresql.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"V2tkS1ptTkhSbnBqZDI4OUNnPT0K"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--postgresql--global--postgresql--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L107">hyperswitch-card-vault.postgresql.global.postgresql.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"db_user"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--postgresql--nameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L103">hyperswitch-card-vault.postgresql.nameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"locker-db"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--postgresql--primary--name"><div style="max-width: 300px;"><a href="./values.yaml#L112">hyperswitch-card-vault.postgresql.primary.name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--postgresql--primary--resources--requests--cpu"><div style="max-width: 300px;"><a href="./values.yaml#L115">hyperswitch-card-vault.postgresql.primary.resources.requests.cpu</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"100m"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--server--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L13">hyperswitch-card-vault.server.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--server--extra--env"><div style="max-width: 300px;"><a href="./values.yaml#L98">hyperswitch-card-vault.server.extra.env</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--server--image"><div style="max-width: 300px;"><a href="./values.yaml#L16">hyperswitch-card-vault.server.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-card-vault:v0.4.0"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--server--nodeAffinity--requiredDuringSchedulingIgnoredDuringExecution"><div style="max-width: 300px;"><a href="./values.yaml#L25">hyperswitch-card-vault.server.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--server--pod--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L21">hyperswitch-card-vault.server.pod.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--server--secrets--locker_private_key"><div style="max-width: 300px;"><a href="./values.yaml#L54">hyperswitch-card-vault.server.secrets.locker_private_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>The private key for the locker from locker-private-key.pem</td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--server--secrets--master_key"><div style="max-width: 300px;"><a href="./values.yaml#L41">hyperswitch-card-vault.server.secrets.master_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"a164665dd3a545c194aa297e4d2cdbd19aa3c59865907e9ffffb7b8d9fcb476208f84fe53bbc7801f2b8eb1aab633fb24ad0bb99b275066fb56516ef"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-card-vault--server--secrets--tenant_public_key"><div style="max-width: 300px;"><a href="./values.yaml#L84">hyperswitch-card-vault.server.secrets.tenant_public_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>The public key for the tenant from tenant-public-key.pem</td>
</tr>

</tbody>
</table>

