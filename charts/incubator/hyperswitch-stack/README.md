<p align="center">
  <img src="https://raw.githubusercontent.com/juspay/hyperswitch/refs/heads/main/docs/imgs/hyperswitch-logo-dark.svg#gh-dark-mode-only" alt="Hyperswitch-Logo" width="40%" />
  <img src="https://raw.githubusercontent.com/juspay/hyperswitch/refs/heads/main/docs/imgs/hyperswitch-logo-light.svg#gh-light-mode-only" alt="Hyperswitch-Logo" width="40%" />
</p>

<h1 align="center">The open-source payments switch</h1>

<div align="center" >
The single API to access payment ecosystems across 130+ countries</div>

<p align="center">
  <a href="#try-a-payment">Try a Payment</a> •
  <a href="#quick-setup">Setup in k8s</a> •
  <a href="https://api-reference.hyperswitch.io/introduction"> API Docs </a>
   <br>
  <a href="#community-contributions">Community and Contributions</a> •
  <a href="#copyright-and-license">Copyright and License</a>
</p>

<p align="center">
  <a href="https://github.com/juspay/hyperswitch/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/juspay/hyperswitch" />
  </a>
</p>
<p align="center">
  <a href="https://www.linkedin.com/company/hyperswitch/">
    <img src="https://img.shields.io/badge/follow-hyperswitch-blue?logo=linkedin&labelColor=grey"/>
  </a>
  <a href="https://x.com/hyperswitchio">
    <img src="https://img.shields.io/badge/follow-%40hyperswitchio-white?logo=x&labelColor=grey"/>
  </a>
  <a href="https://join.slack.com/t/hyperswitch-io/shared_invite/zt-2jqxmpsbm-WXUENx022HjNEy~Ark7Orw">
    <img src="https://img.shields.io/badge/chat-on_slack-blue?logo=slack&labelColor=grey&color=%233f0e40"/>
  </a>
</p>

<hr>

Hyperswitch is a community-led, open payments switch designed to empower digital businesses by providing fast, reliable, and affordable access to the best payments infrastructure.

Here are the components of Hyperswitch that deliver the whole solution:

* [Hyperswitch Backend](https://github.com/juspay/hyperswitch): Powering Payment Processing

* [SDK (Frontend)](https://github.com/juspay/hyperswitch-web): Simplifying Integration and Powering the UI

* [Control Centre](https://github.com/juspay/hyperswitch-control-center): Managing Operations with Ease

Jump in and contribute to these repositories to help improve and expand Hyperswitch!

<img src="https://raw.githubusercontent.com/juspay/hyperswitch/refs/heads/main/docs/imgs/switch.png" />

<a href="https://app.hyperswitch.io/">
  <h2 id="try-a-payment">⚡️ Try a Payment</h2>
</a>

To quickly experience the ease of Hyperswitch, sign up on the [Hyperswitch Control Center](https://app.hyperswitch.io/) and try a payment. Once you've completed your first transaction, you’ve successfully made your first payment with Hyperswitch!

<a href="#Quick Setup">
  <h2 id="quick-setup">⚡️ Quick Setup</h2>
</a>

# Deploy on Kubernetes using Helm

This section outlines cloud-provider agnostic deployment steps for easy installation of the Hyperswitch stack on your K8s cluster

## Installation

### Step 1 - Clone repo and Update Configurations

Clone the [hyperswitch-stack](https://github.com/juspay/hyperswitch-helm) repo and start updating the configs

```bash
helm repo add hyperswitch-helm https://juspay.github.io/hyperswitch-helm
helm repo update
```

### Step 2 - Install Hyperswitch

Before installing the service make sure you labels your kubernetes nodes and create a namespace `hyperswitch`
```bash
kubectl label nodes <your-node-name> node-type=generic-compute
kubectl create namespace hyperswitch
```
Use below command to install hyperswitch services with above configs

```bash
helm install hypers-v1 hyperswitch/hyperswitch-stack -n hyperswitch
```

That's it! Hyperswitch should be up and running on your Cluster  :tada: :tada:

## Post-Deployment Checklist

After deploying the Helm chart, you should verify that everything is working correctly

### App Server

* [ ] &#x20;Check that `hyperswitch_server/health` returns `health is good`

### Control Center

* [ ] &#x20;Verify if you are able to sign in or sign up
* [ ] &#x20;Verify if you are able to [create API key](https://docs.hyperswitch.io/hyperswitch-open-source/account-setup/using-hyperswitch-control-center#user-content-create-an-api-key)
* [ ] &#x20;Verify if you are able to [configure a new payment processor](https://docs.hyperswitch.io/hyperswitch-open-source/account-setup/using-hyperswitch-control-center#add-a-payment-processor)

## Test a payment

Hyperswitch Control center will mimic the behavior of your checkout page. Please follow below steps to test a payment with the deployed app

### Step 1 - Deploy card vault

### Card Vault Installation

By default card vault and its dependencies are installed, however you need to create master key, custodian keys and unlock the locker to start saving cards.

<details>
  <summary>
    <b> Step 1: Generating the keys </b>
  </summary>
  <p>
  To generate the master key and the custodian keys use the following command after cloning the repository.
   
    # Generate master key
    git clone https://github.com/juspay/hyperswitch-card-vault.git
    cd hyperswitch-card-vault
    cargo run --bin utils -- master-key
    To generate the JWE and JWS keys run the following commands

    # Generating the private keys
    openssl genrsa -out locker-private-key.pem 2048
    openssl genrsa -out tenant-private-key.pem 2048

    # Generating the public keys
    openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem
    openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem 
</p>
</details>
<details>
  <summary>
    <b> Step 2: Update the keys in deployment </b>
  </summary>
  <p>

    # Update below values in hyperswitch-stack/values.yaml
    # The public key for the locker from locker-public-key.pem
    hyperswitch-app.application.server.secrets.kms_jwekey_vault_encryption_key: |
      -----BEGIN PUBLIC KEY-----
      ...
      -----END PUBLIC KEY-----
    # The private key for the tenant from tenant-private-key.pem
    hyperswitch-app.application.server.secrets.kms_jwekey_vault_private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      ...
      -----END RSA PRIVATE KEY-----
    # The private key for the locker from locker-private-key.pem
    hyperswitch-card-vault.server.secrets.locker_private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      ...
      -----END RSA PRIVATE KEY-----
    # The public key for the tenant from tenant-public-key.pem
    hyperswitch-card-vault.server.secrets.tenant_public_key: |
      -----BEGIN PUBLIC KEY-----
      ...
      -----END PUBLIC KEY-----

   </p>
</details>
<details>
  <summary> <b> Step 3: Unlock the locker </b> </summary>
  <p>
  Once the locker is up and running, use the 2 key custodian keys generated earlier securely to unlock the locker for use.
  Go to the respective locker Pod, open its shell and run below cURLs

  The following cURLs are to be used to provide keys

    # temporary turn of saving to history to run the following commands
    unset HISTFILE

    # key 1
    curl -X 'POST' \
      'localhost:8080/custodian/key1' \
      -H 'accept: text/plain' \
      -H 'Content-Type: application/json' \
      -d '{
      "key": <key 1>
    }'

    # key 2
    curl -X 'POST' \
      'localhost:8080/custodian/key2' \
      -H 'accept: text/plain' \
      -H 'Content-Type: application/json' \
      -d '{
      "key": <key 2>
    }'

    # decrypt
    curl -X 'POST' 'localhost:8080/custodian/decrypt'
   
  If the last cURL replies with `Decrypted Successfully`, we are ready to use the locker.
   </p>
</details>

### Step 2 - Make a payment using our Control Center

Use the Hyperswitch Control Center and [make a payment with test card](https://docs.hyperswitch.io/hyperswitch-open-source/account-setup/test-a-payment).

Refer our [postman collection](https://www.postman.com/hyperswitch/workspace/hyperswitch/folder/25176183-0103918c-6611-459b-9faf-354dee8e4437) to try out REST APIs

<a href="#community-contributions">
  <h2 id="community-contributions">✅ Community & Contributions</h2>
</a>

The community and core team are available in [GitHub Discussions](https://github.com/juspay/hyperswitch/discussions), where you can ask for support, discuss roadmap, and share ideas.

Join our Conversation in [Slack](https://join.slack.com/t/hyperswitch-io/shared_invite/zt-2jqxmpsbm-WXUENx022HjNEy~Ark7Orw), [Discord](https://discord.gg/wJZ7DVW8mm), [Twitter](https://x.com/hyperswitchio)

When you want others to use the changes you have added you need to package it and then index it
```bash
helm package .
helm repo index . --url https://juspay.github.io/hyperswitch-helm/<version>
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../hyperswitch-app | hyperswitch-app | 0.2.0 |
| file://../hyperswitch-sdk | hyperswitch-web | 0.2.0 |

   
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
    <td id="hyperswitch-app--application--controlCenter--env--default__endpoints__agreement_url"><div style="max-width: 300px;"><a href="./values.yaml#L731">hyperswitch-app.application.controlCenter.env.default__endpoints__agreement_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"</pre> </div>
</td>
    <td>Hyperswitch terms and conditions url</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__endpoints__agreement_version"><div style="max-width: 300px;"><a href="./values.yaml#L737">hyperswitch-app.application.controlCenter.env.default__endpoints__agreement_version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"1.0.0"</pre> </div>
</td>
    <td>Agreement version</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__endpoints__dss_certificate_url"><div style="max-width: 300px;"><a href="./values.yaml#L734">hyperswitch-app.application.controlCenter.env.default__endpoints__dss_certificate_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://app.hyperswitch.io/certificates/PCI_DSS_v4-0_AOC_Juspay_2024.pdf"</pre> </div>
</td>
    <td>PCI DSS certificate url</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__endpoints__favicon_url"><div style="max-width: 300px;"><a href="./values.yaml#L725">hyperswitch-app.application.controlCenter.env.default__endpoints__favicon_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Endpoints favicon url</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__endpoints__logo_url"><div style="max-width: 300px;"><a href="./values.yaml#L722">hyperswitch-app.application.controlCenter.env.default__endpoints__logo_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Endpoints logo url</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__endpoints__mixpanel_token"><div style="max-width: 300px;"><a href="./values.yaml#L728">hyperswitch-app.application.controlCenter.env.default__endpoints__mixpanel_token</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dd4da7f62941557e716fbc0a19f9cc7e"</pre> </div>
</td>
    <td>Mixpanel token</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__branding"><div style="max-width: 300px;"><a href="./values.yaml#L791">hyperswitch-app.application.controlCenter.env.default__features__branding</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables customization of branding elements like logos, colors.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__email"><div style="max-width: 300px;"><a href="./values.yaml#L746">hyperswitch-app.application.controlCenter.env.default__features__email</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables user sign-in and sign-up using magic links instead of passwords. When enabled, users can request a magic link via email that logs them into their account or creates a new account if they are signing up.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__feedback"><div style="max-width: 300px;"><a href="./values.yaml#L770">hyperswitch-app.application.controlCenter.env.default__features__feedback</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the ability for users to provide direct product feedback from within the dashboard. When enabled, a feedback modal will be available in the UI that allows users to rate features, report bugs, and suggest improvements. Disabling this flag will remove the feedback modal and prevent collection of any user data.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__frm"><div style="max-width: 300px;"><a href="./values.yaml#L758">hyperswitch-app.application.controlCenter.env.default__features__frm</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the Fraud and Risk Management (FRM) module within the dashboard. When enabled, this unlocks integrations with FRM players like Riskified and Signified.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__generate_report"><div style="max-width: 300px;"><a href="./values.yaml#L776">hyperswitch-app.application.controlCenter.env.default__features__generate_report</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Controls the ability to generate detailed reports on payments, refunds, and disputes. When enabled, this allows users to pull reports covering the previous 6 months of transaction data. The reports can provide insights into trends, identify issues, and inform business decisions.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__is_live_mode"><div style="max-width: 300px;"><a href="./values.yaml#L743">hyperswitch-app.application.controlCenter.env.default__features__is_live_mode</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the live mode - that the user is accessing. When enabled, it will show a visual indicator within the dashboard signaling whether the user is currently in a test environment or live production environment. In Live mode, current users are not allowed to sign up. Users must be created manually.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__mixpanel"><div style="max-width: 300px;"><a href="./values.yaml#L773">hyperswitch-app.application.controlCenter.env.default__features__mixpanel</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Controls the collection and transmission of anonymous usage data to Mixpanel for analytics. When enabled, the dashboard will automatically send information about user actions and events to Mixpanel without collecting any personally identifiable information via REST API.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__payout"><div style="max-width: 300px;"><a href="./values.yaml#L761">hyperswitch-app.application.controlCenter.env.default__features__payout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the payout functionality in the dashboard. When enabled, this allows users to configure payout profiles, manage recipient details, schedule disbursements, and process payout batches to pay out funds to third parties.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__quick_start"><div style="max-width: 300px;"><a href="./values.yaml#L749">hyperswitch-app.application.controlCenter.env.default__features__quick_start</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the simplified onboarding flow for new users, where they connect to processors, configure payment routing and test a payment, all in one flow.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__recon"><div style="max-width: 300px;"><a href="./values.yaml#L764">hyperswitch-app.application.controlCenter.env.default__features__recon</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables access to reconciliation capabilities in the Hyperswitch dashboard. When turned on, this unlocks the Reconciliation module that allows users to match payment transactions with bank/ledger entries for accounting purposes.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__sample_data"><div style="max-width: 300px;"><a href="./values.yaml#L755">hyperswitch-app.application.controlCenter.env.default__features__sample_data</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the ability to load simulated sample data into the dashboard for preview purposes. When enabled, dummy transactions, analytics, and reporting data can be generated.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__surcharge"><div style="max-width: 300px;"><a href="./values.yaml#L782">hyperswitch-app.application.controlCenter.env.default__features__surcharge</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables the ability to apply surcharges to payments. When enabled, you can create advanced rules based on payment parameters like amount, currency, and payment method to enforce surcharges as needed.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__system_metrics"><div style="max-width: 300px;"><a href="./values.yaml#L752">hyperswitch-app.application.controlCenter.env.default__features__system_metrics</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Unlocks access to system monitoring and metrics pages within the dashboard. When enabled, users can view technical performance data like payment latency, uptime, API response times, error rates, and more.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__test_live_toggle"><div style="max-width: 300px;"><a href="./values.yaml#L740">hyperswitch-app.application.controlCenter.env.default__features__test_live_toggle</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables users to toggle between test and live modes when signing in. When enabled, users will see an option during sign-in to actively switch between test and live environments.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__test_processors"><div style="max-width: 300px;"><a href="./values.yaml#L767">hyperswitch-app.application.controlCenter.env.default__features__test_processors</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Allows enabling sandbox/test payment processors for testing purposes. When enabled, developers and testers can add test payment processors like Stripe Test or PayPal Test to trial payment flows without touching live transactions or making processor API calls.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__totp"><div style="max-width: 300px;"><a href="./values.yaml#L795">hyperswitch-app.application.controlCenter.env.default__features__totp</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Enables totp will mandate 2fa for all users</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__user_journey_analytics"><div style="max-width: 300px;"><a href="./values.yaml#L779">hyperswitch-app.application.controlCenter.env.default__features__user_journey_analytics</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td>Grants access to the user journey module within the analytics section of the dashboard. This feature provides comprehensive graphical representations of payment analytics, facilitating a deeper understanding of user behavior and usage patterns.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__theme__primary_color"><div style="max-width: 300px;"><a href="./values.yaml#L713">hyperswitch-app.application.controlCenter.env.default__theme__primary_color</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#006DF9"</pre> </div>
</td>
    <td>Primary color for the theme</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__theme__primary_hover_color"><div style="max-width: 300px;"><a href="./values.yaml#L716">hyperswitch-app.application.controlCenter.env.default__theme__primary_hover_color</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#005ED6"</pre> </div>
</td>
    <td>Primary hover color for the theme</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__theme__sidebar_color"><div style="max-width: 300px;"><a href="./values.yaml#L719">hyperswitch-app.application.controlCenter.env.default__theme__sidebar_color</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#242F48"</pre> </div>
</td>
    <td>Secondary color for the theme</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--mixpanelToken"><div style="max-width: 300px;"><a href="./values.yaml#L710">hyperswitch-app.application.controlCenter.env.mixpanelToken</a></div></td>
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
    <td id="hyperswitch-app--application--server--analytics--clickhouse--database"><div style="max-width: 300px;"><a href="./values.yaml#L269">hyperswitch-app.application.server.analytics.clickhouse.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td>Clickhouse database name</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--analytics--clickhouse--host"><div style="max-width: 300px;"><a href="./values.yaml#L272">hyperswitch-app.application.server.analytics.clickhouse.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://clickhouse:8123"</pre> </div>
</td>
    <td>Clickhouse host in http(s)://<URL>:<PORT> format</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--analytics--clickhouse--password"><div style="max-width: 300px;"><a href="./values.yaml#L278">hyperswitch-app.application.server.analytics.clickhouse.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Clickhouse password (optional)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--analytics--clickhouse--username"><div style="max-width: 300px;"><a href="./values.yaml#L275">hyperswitch-app.application.server.analytics.clickhouse.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td>Clickhouse username</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--aws_region"><div style="max-width: 300px;"><a href="./values.yaml#L314">hyperswitch-app.application.server.email.aws_region</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"us-east-1"</pre> </div>
</td>
    <td>AWS region used by AWS SES</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--aws_ses--email_role_arn"><div style="max-width: 300px;"><a href="./values.yaml#L318">hyperswitch-app.application.server.email.aws_ses.email_role_arn</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"arn:aws:iam::123456789012:role/SendEmailRole"</pre> </div>
</td>
    <td>The amazon resource name ( arn ) of the role which has permission to send emails</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--aws_ses--sts_role_session_name"><div style="max-width: 300px;"><a href="./values.yaml#L321">hyperswitch-app.application.server.email.aws_ses.sts_role_session_name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"SendEmailRole"</pre> </div>
</td>
    <td>An identifier for the assumed role session, used to uniquely identify a session.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--prod_intent_recipient_email"><div style="max-width: 300px;"><a href="./values.yaml#L324">hyperswitch-app.application.server.email.prod_intent_recipient_email</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"business@example.com"</pre> </div>
</td>
    <td>Recipient email for prod intent email</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--recon_recipient_email"><div style="max-width: 300px;"><a href="./values.yaml#L327">hyperswitch-app.application.server.email.recon_recipient_email</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"recon@example.com"</pre> </div>
</td>
    <td>Recipient email for recon request email</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--sender_email"><div style="max-width: 300px;"><a href="./values.yaml#L330">hyperswitch-app.application.server.email.sender_email</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"example@example.com"</pre> </div>
</td>
    <td>Sender email</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--smtp--host"><div style="max-width: 300px;"><a href="./values.yaml#L336">hyperswitch-app.application.server.email.smtp.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"mailhog"</pre> </div>
</td>
    <td>Host of the smtp server</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--smtp--password"><div style="max-width: 300px;"><a href="./values.yaml#L341">hyperswitch-app.application.server.email.smtp.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Password for the smtp server</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--admin_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L155">hyperswitch-app.application.server.secrets.admin_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"test_admin"</pre> </div>
</td>
    <td>admin API key for admin authentication.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--api_hash_key"><div style="max-width: 300px;"><a href="./values.yaml#L260">hyperswitch-app.application.server.secrets.api_hash_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"</pre> </div>
</td>
    <td>API key hashing key.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--apple_pay_merchant_cert"><div style="max-width: 300px;"><a href="./values.yaml#L230">hyperswitch-app.application.server.secrets.apple_pay_merchant_cert</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--apple_pay_merchant_cert_key"><div style="max-width: 300px;"><a href="./values.yaml#L233">hyperswitch-app.application.server.secrets.apple_pay_merchant_cert_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Private key generated by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--apple_pay_merchant_conf_merchant_cert"><div style="max-width: 300px;"><a href="./values.yaml#L242">hyperswitch-app.application.server.secrets.apple_pay_merchant_conf_merchant_cert</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--apple_pay_merchant_conf_merchant_cert_key"><div style="max-width: 300px;"><a href="./values.yaml#L245">hyperswitch-app.application.server.secrets.apple_pay_merchant_conf_merchant_cert_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Private key generate by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--apple_pay_merchant_conf_merchant_id"><div style="max-width: 300px;"><a href="./values.yaml#L248">hyperswitch-app.application.server.secrets.apple_pay_merchant_conf_merchant_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Refer to config.example.toml to learn how you can generate this value</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--apple_pay_ppc"><div style="max-width: 300px;"><a href="./values.yaml#L236">hyperswitch-app.application.server.secrets.apple_pay_ppc</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Payment Processing Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Payment Processing Certificate</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--apple_pay_ppc_key"><div style="max-width: 300px;"><a href="./values.yaml#L239">hyperswitch-app.application.server.secrets.apple_pay_ppc_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Private key generated by Elliptic-curve prime256v1 curve. You can use `openssl ecparam -out private.key -name prime256v1 -genkey` to generate the private key</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--forex_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L251">hyperswitch-app.application.server.secrets.forex_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Api key for making request to foreign exchange Api, Follow https://github.com/juspay/hyperswitch/tree/main/crates/analytics#setting-up-forex-apis to get the forex api key</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--forex_fallback_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L254">hyperswitch-app.application.server.secrets.forex_fallback_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Forex Api key for the fallback service</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--jwt_secret"><div style="max-width: 300px;"><a href="./values.yaml#L158">hyperswitch-app.application.server.secrets.jwt_secret</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"test_admin"</pre> </div>
</td>
    <td>JWT secret used for user authentication.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_jwekey_vault_encryption_key"><div style="max-width: 300px;"><a href="./values.yaml#L174">hyperswitch-app.application.server.secrets.kms_jwekey_vault_encryption_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>The public key for the locker from locker-public-key.pub, these are only test keys, please change it when deploying to production or other environments</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_jwekey_vault_private_key"><div style="max-width: 300px;"><a href="./values.yaml#L187">hyperswitch-app.application.server.secrets.kms_jwekey_vault_private_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>The private key for the tenant from tenant-private-key.pem, these are only test keys, please change it when deploying to production or other environments</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_key_id"><div style="max-width: 300px;"><a href="./values.yaml#L167">hyperswitch-app.application.server.secrets.kms_key_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"kms_key_id"</pre> </div>
</td>
    <td>KMS key id for encryption and decryption</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_key_region"><div style="max-width: 300px;"><a href="./values.yaml#L170">hyperswitch-app.application.server.secrets.kms_key_region</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"us-east-1"</pre> </div>
</td>
    <td>AWS KMS region</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--master_enc_key"><div style="max-width: 300px;"><a href="./values.yaml#L161">hyperswitch-app.application.server.secrets.master_enc_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"471f22516724347bcca9c20c5fa88d9821c4604e63a6aceffd24605809c9237c"</pre> </div>
</td>
    <td>Master Encryption key used to encrypt merchant wise encryption key. Should be 32-byte long.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--pm_auth_key"><div style="max-width: 300px;"><a href="./values.yaml#L257">hyperswitch-app.application.server.secrets.pm_auth_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td># Payment method auth key used for authorization</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--recon_admin_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L164">hyperswitch-app.application.server.secrets.recon_admin_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"test_admin"</pre> </div>
</td>
    <td>Recon Admin API key for recon admin authentication.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--redis_temp_locker_encryption_key"><div style="max-width: 300px;"><a href="./values.yaml#L227">hyperswitch-app.application.server.secrets.redis_temp_locker_encryption_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td>Encryption key for redis temp locker</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--user_auth_encryption_key"><div style="max-width: 300px;"><a href="./values.yaml#L263">hyperswitch-app.application.server.secrets.user_auth_encryption_key</a></div></td>
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
    <td id="hyperswitch-app--clickhouse--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L1019">hyperswitch-app.clickhouse.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Clickhouse password</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L1016">hyperswitch-app.clickhouse.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td>Clickhouse username</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--config--TZ"><div style="max-width: 300px;"><a href="./values.yaml#L1025">hyperswitch-app.clickhouse.config.TZ</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Asia/Kolkata"</pre> </div>
</td>
    <td>Clickhouse timezone</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1008">hyperswitch-app.clickhouse.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Clickhouse sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L1011">hyperswitch-app.clickhouse.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"clickhouse"</pre> </div>
</td>
    <td>Name of the Clickhouse sub-chart</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--logLevel"><div style="max-width: 300px;"><a href="./values.yaml#L1046">hyperswitch-app.clickhouse.logLevel</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"error"</pre> </div>
</td>
    <td>Clickhouse log level</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L1031">hyperswitch-app.clickhouse.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Clickhouse replica count</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--shards"><div style="max-width: 300px;"><a href="./values.yaml#L1028">hyperswitch-app.clickhouse.shards</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Clickhouse shard count</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--ulimits--nofile--hard"><div style="max-width: 300px;"><a href="./values.yaml#L1039">hyperswitch-app.clickhouse.ulimits.nofile.hard</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>262144</pre> </div>
</td>
    <td>Clickhouse hard limit</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--ulimits--nofile--soft"><div style="max-width: 300px;"><a href="./values.yaml#L1036">hyperswitch-app.clickhouse.ulimits.nofile.soft</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>262144</pre> </div>
</td>
    <td>Clickhouse soft limit</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--zookeeper--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L1043">hyperswitch-app.clickhouse.zookeeper.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Zookerper replica count</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L894">hyperswitch-app.externalPostgresql.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Link this service to an external Postgres server</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--primary--auth--database"><div style="max-width: 300px;"><a href="./values.yaml#L911">hyperswitch-app.externalPostgresql.primary.auth.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>master DB name</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--primary--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L905">hyperswitch-app.externalPostgresql.primary.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>master DB password</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--primary--auth--plainpassword"><div style="max-width: 300px;"><a href="./values.yaml#L908">hyperswitch-app.externalPostgresql.primary.auth.plainpassword</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>master DB plainpassword</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--primary--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L902">hyperswitch-app.externalPostgresql.primary.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>master DB username</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--primary--host"><div style="max-width: 300px;"><a href="./values.yaml#L898">hyperswitch-app.externalPostgresql.primary.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"postgresql-ext"</pre> </div>
</td>
    <td>External postgres host</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--readOnly--auth--database"><div style="max-width: 300px;"><a href="./values.yaml#L931">hyperswitch-app.externalPostgresql.readOnly.auth.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>replica DB name</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--readOnly--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L925">hyperswitch-app.externalPostgresql.readOnly.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>replica DB password</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--readOnly--auth--plainpassword"><div style="max-width: 300px;"><a href="./values.yaml#L928">hyperswitch-app.externalPostgresql.readOnly.auth.plainpassword</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>replica DB plainpassword</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--readOnly--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L922">hyperswitch-app.externalPostgresql.readOnly.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>replica DB username</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--readOnly--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L915">hyperswitch-app.externalPostgresql.readOnly.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>External postgres read only host enabled or disabled</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalPostgresql--readOnly--host"><div style="max-width: 300px;"><a href="./values.yaml#L918">hyperswitch-app.externalPostgresql.readOnly.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"postgres-service"</pre> </div>
</td>
    <td>External postgres read only host</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalRedis--auth--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L831">hyperswitch-app.externalRedis.auth.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>auth enabled or disabled</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalRedis--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L837">hyperswitch-app.externalRedis.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>redis password</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalRedis--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L834">hyperswitch-app.externalRedis.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>redis username</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalRedis--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L824">hyperswitch-app.externalRedis.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Link this service to an external Redis server</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--externalRedis--host"><div style="max-width: 300px;"><a href="./values.yaml#L827">hyperswitch-app.externalRedis.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"redis-ext-master"</pre> </div>
</td>
    <td>External redis host</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--broker--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L968">hyperswitch-app.kafka.broker.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for broker</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--controller--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L964">hyperswitch-app.kafka.controller.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for controller</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L956">hyperswitch-app.kafka.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Kafka sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L959">hyperswitch-app.kafka.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"kafka0"</pre> </div>
</td>
    <td>Name of the Kafka sub-chart</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--listeners--client--protocol"><div style="max-width: 300px;"><a href="./values.yaml#L984">hyperswitch-app.kafka.listeners.client.protocol</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PLAINTEXT"</pre> </div>
</td>
    <td>Listener client protocol</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--listeners--controller--protocol"><div style="max-width: 300px;"><a href="./values.yaml#L996">hyperswitch-app.kafka.listeners.controller.protocol</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PLAINTEXT"</pre> </div>
</td>
    <td>Listener controller protocol</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--listeners--external--protocol"><div style="max-width: 300px;"><a href="./values.yaml#L992">hyperswitch-app.kafka.listeners.external.protocol</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PLAINTEXT"</pre> </div>
</td>
    <td>Listener external protocol</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--listeners--interbroker--protocol"><div style="max-width: 300px;"><a href="./values.yaml#L988">hyperswitch-app.kafka.listeners.interbroker.protocol</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PLAINTEXT"</pre> </div>
</td>
    <td>Listener interbroker protocol</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--provisioning--replicationFactor"><div style="max-width: 300px;"><a href="./values.yaml#L1000">hyperswitch-app.kafka.provisioning.replicationFactor</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>kafka provisioning replicationFactor</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--service--ports--client"><div style="max-width: 300px;"><a href="./values.yaml#L979">hyperswitch-app.kafka.service.ports.client</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>29092</pre> </div>
</td>
    <td>Client port for Kafka</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--zookeeper--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L974">hyperswitch-app.kafka.zookeeper.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for zookeeper</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--loki-stack--grafana--adminPassword"><div style="max-width: 300px;"><a href="./values.yaml#L1099">hyperswitch-app.loki-stack.grafana.adminPassword</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"admin"</pre> </div>
</td>
    <td>Name of the Grafana sub-chart</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--loki-stack--grafana--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1096">hyperswitch-app.loki-stack.grafana.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Grafana sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--loki-stack--grafana--image--tag"><div style="max-width: 300px;"><a href="./values.yaml#L1103">hyperswitch-app.loki-stack.grafana.image.tag</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"10.0.1"</pre> </div>
</td>
    <td>Grafana image tag</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--loki-stack--loki--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1076">hyperswitch-app.loki-stack.loki.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Loki sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--loki-stack--loki--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L1079">hyperswitch-app.loki-stack.loki.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"loki"</pre> </div>
</td>
    <td>Name of the Loki sub-chart</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--loki-stack--promtail--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1083">hyperswitch-app.loki-stack.promtail.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Promtail sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--mailhog--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1067">hyperswitch-app.mailhog.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Mailhog sub-chart helm installation for email testing</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--mailhog--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L1070">hyperswitch-app.mailhog.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"mailhog"</pre> </div>
</td>
    <td>Name of the Mailhog sub-chart</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--architecture"><div style="max-width: 300px;"><a href="./values.yaml#L864">hyperswitch-app.postgresql.architecture</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"replication"</pre> </div>
</td>
    <td>Postgresql architecture: replication or standalone</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L849">hyperswitch-app.postgresql.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>enable Bitnami postgresql sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--global--postgresql--auth--database"><div style="max-width: 300px;"><a href="./values.yaml#L861">hyperswitch-app.postgresql.global.postgresql.auth.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>Postgresql database</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--global--postgresql--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L858">hyperswitch-app.postgresql.global.postgresql.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ZGJwYXNzd29yZDEx"</pre> </div>
</td>
    <td>Postgresql password</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--global--postgresql--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L855">hyperswitch-app.postgresql.global.postgresql.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch"</pre> </div>
</td>
    <td>Postgresql username</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--primary--name"><div style="max-width: 300px;"><a href="./values.yaml#L875">hyperswitch-app.postgresql.primary.name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>postgres primary name</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--primary--resources--requests--cpu"><div style="max-width: 300px;"><a href="./values.yaml#L880">hyperswitch-app.postgresql.primary.resources.requests.cpu</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"150m"</pre> </div>
</td>
    <td>CPU resource requests</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--readReplicas--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L884">hyperswitch-app.postgresql.readReplicas.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of read replicas</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--readReplicas--resources--requests--cpu"><div style="max-width: 300px;"><a href="./values.yaml#L889">hyperswitch-app.postgresql.readReplicas.resources.requests.cpu</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"100m"</pre> </div>
</td>
    <td>CPU resource requests</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--replication--numSynchronousReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L871">hyperswitch-app.postgresql.replication.numSynchronousReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of synchronous replicas</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--postgresql--replication--synchronousCommit"><div style="max-width: 300px;"><a href="./values.yaml#L868">hyperswitch-app.postgresql.replication.synchronousCommit</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"off"</pre> </div>
</td>
    <td>synchronous_commit parameter</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--redis--auth--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L816">hyperswitch-app.redis.auth.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>enable or disable redis auth</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--redis--auth--sentinel"><div style="max-width: 300px;"><a href="./values.yaml#L819">hyperswitch-app.redis.auth.sentinel</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>enable or disable sentinel</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--redis--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L804">hyperswitch-app.redis.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>- enable Bitnami redis sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--redis--master--count"><div style="max-width: 300px;"><a href="./values.yaml#L808">hyperswitch-app.redis.master.count</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for master</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--redis--replica--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L812">hyperswitch-app.redis.replica.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>0</pre> </div>
</td>
    <td>Number of replicas to be used for replica</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--vector--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L1108">hyperswitch-app.vector.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Enable Bitnami Vector sub-chart helm installation</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--vector--env[0]"><div style="max-width: 300px;"><a href="./values.yaml#L1112">hyperswitch-app.vector.env[0]</a></div></td>
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
    <td id="hyperswitch-app--services--consumer--image"><div style="max-width: 300px;"><a href="./values.yaml#L15">hyperswitch-app.services.consumer.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-consumer:v1.112.0"</pre> </div>
</td>
    <td>Consumer image</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--controlCenter--image"><div style="max-width: 300px;"><a href="./values.yaml#L23">hyperswitch-app.services.controlCenter.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-control-center:v1.34.2"</pre> </div>
</td>
    <td>Control Center image</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--producer--image"><div style="max-width: 300px;"><a href="./values.yaml#L19">hyperswitch-app.services.producer.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-producer:v1.112.0"</pre> </div>
</td>
    <td>Producer image</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--router--host"><div style="max-width: 300px;"><a href="./values.yaml#L11">hyperswitch-app.services.router.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:8080"</pre> </div>
</td>
    <td>Router host</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--router--image"><div style="max-width: 300px;"><a href="./values.yaml#L8">hyperswitch-app.services.router.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-router:v1.112.0"</pre> </div>
</td>
    <td>Router image</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--router--version"><div style="max-width: 300px;"><a href="./values.yaml#L5">hyperswitch-app.services.router.version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v1.112.0"</pre> </div>
</td>
    <td>Router version</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--sdk--host"><div style="max-width: 300px;"><a href="./values.yaml#L27">hyperswitch-app.services.sdk.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:9090"</pre> </div>
</td>
    <td>SDK host</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--sdk--subversion"><div style="max-width: 300px;"><a href="./values.yaml#L33">hyperswitch-app.services.sdk.subversion</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v0"</pre> </div>
</td>
    <td>SDK subversion</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--sdk--version"><div style="max-width: 300px;"><a href="./values.yaml#L30">hyperswitch-app.services.sdk.version</a></div></td>
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
    <td id="affinity"><div style="max-width: 300px;"><a href="./values.yaml#L98">affinity</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="autoscaling--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L75">autoscaling.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="autoscaling--maxReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L77">autoscaling.maxReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>100</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="autoscaling--minReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L76">autoscaling.minReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="autoscaling--targetCPUUtilizationPercentage"><div style="max-width: 300px;"><a href="./values.yaml#L78">autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>80</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L15">fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--locker--locker_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L190">hyperswitch-app.application.server.locker.locker_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--replicas"><div style="max-width: 300px;"><a href="./values.yaml#L184">hyperswitch-app.application.server.replicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--run_env"><div style="max-width: 300px;"><a href="./values.yaml#L191">hyperswitch-app.application.server.run_env</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sandbox"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--forex_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L187">hyperswitch-app.application.server.secrets.forex_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"forex_api_key"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--forex_fallback_api_key"><div style="max-width: 300px;"><a href="./values.yaml#L188">hyperswitch-app.application.server.secrets.forex_fallback_api_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"forex_fallback_api_key"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--autoscaling--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L193">hyperswitch-app.autoscaling.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--autoscaling--maxReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L195">hyperswitch-app.autoscaling.maxReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>4</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--autoscaling--minReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L194">hyperswitch-app.autoscaling.minReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--autoscaling--targetCPUUtilizationPercentage"><div style="max-width: 300px;"><a href="./values.yaml#L196">hyperswitch-app.autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>80</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L199">hyperswitch-app.hyperswitch-card-vault.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--initDB--enable"><div style="max-width: 300px;"><a href="./values.yaml#L205">hyperswitch-app.hyperswitch-card-vault.initDB.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--image"><div style="max-width: 300px;"><a href="./values.yaml#L201">hyperswitch-app.hyperswitch-card-vault.server.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-card-vault:v0.4.0"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--secrets--master_key"><div style="max-width: 300px;"><a href="./values.yaml#L203">hyperswitch-app.hyperswitch-card-vault.server.secrets.master_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"7fe40608201400da9db95bb5cc090b2280405617a5ab42f2f6f94e6213d773e95585bf685f79bdc6368fc1e3aa7df984e3dafc6516bcee35bf64b52f"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--initDB--enable"><div style="max-width: 300px;"><a href="./values.yaml#L164">hyperswitch-app.initDB.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--loadBalancer--targetSecurityGroup"><div style="max-width: 300px;"><a href="./values.yaml#L166">hyperswitch-app.loadBalancer.targetSecurityGroup</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"lg-security-group"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--consumer--image"><div style="max-width: 300px;"><a href="./values.yaml#L173">hyperswitch-app.services.consumer.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-consumer:v1.112.0-standalone"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--controlCenter--image"><div style="max-width: 300px;"><a href="./values.yaml#L177">hyperswitch-app.services.controlCenter.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-control-center:v1.34.2"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--producer--image"><div style="max-width: 300px;"><a href="./values.yaml#L175">hyperswitch-app.services.producer.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-producer:v1.112.0-standalone"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--router--host"><div style="max-width: 300px;"><a href="./values.yaml#L171">hyperswitch-app.services.router.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:8080"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--router--image"><div style="max-width: 300px;"><a href="./values.yaml#L170">hyperswitch-app.services.router.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-router:v1.112.0-standalone"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--router--version"><div style="max-width: 300px;"><a href="./values.yaml#L169">hyperswitch-app.services.router.version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v1.112.0"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--sdk--host"><div style="max-width: 300px;"><a href="./values.yaml#L179">hyperswitch-app.services.sdk.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:9090"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--sdk--subversion"><div style="max-width: 300px;"><a href="./values.yaml#L181">hyperswitch-app.services.sdk.subversion</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v0"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--services--sdk--version"><div style="max-width: 300px;"><a href="./values.yaml#L180">hyperswitch-app.services.sdk.version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0.103.1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--buildParam--envBackendUrl"><div style="max-width: 300px;"><a href="./values.yaml#L130">hyperswitch-web.autoBuild.buildParam.envBackendUrl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:8080"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--buildParam--envLogsUrl"><div style="max-width: 300px;"><a href="./values.yaml#L131">hyperswitch-web.autoBuild.buildParam.envLogsUrl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:3103"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--buildParam--envSdkUrl"><div style="max-width: 300px;"><a href="./values.yaml#L129">hyperswitch-web.autoBuild.buildParam.envSdkUrl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:9090"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--enable"><div style="max-width: 300px;"><a href="./values.yaml#L122">hyperswitch-web.autoBuild.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--forceBuild"><div style="max-width: 300px;"><a href="./values.yaml#L123">hyperswitch-web.autoBuild.forceBuild</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--gitCloneParam--gitVersion"><div style="max-width: 300px;"><a href="./values.yaml#L125">hyperswitch-web.autoBuild.gitCloneParam.gitVersion</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0.103.1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--nginxConfig--extraPath"><div style="max-width: 300px;"><a href="./values.yaml#L127">hyperswitch-web.autoBuild.nginxConfig.extraPath</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v0"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L112">hyperswitch-web.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L111">hyperswitch-web.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-web"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--image--pullPolicy"><div style="max-width: 300px;"><a href="./values.yaml#L116">hyperswitch-web.image.pullPolicy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Always"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/backend-protocol""><div style="max-width: 300px;"><a href="./values.yaml#L141">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/backend-protocol"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"HTTP"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/backend-protocol-version""><div style="max-width: 300px;"><a href="./values.yaml#L142">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/backend-protocol-version"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"HTTP1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/group--name""><div style="max-width: 300px;"><a href="./values.yaml#L143">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/group.name"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-web-alb-ingress-group"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/ip-address-type""><div style="max-width: 300px;"><a href="./values.yaml#L144">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/ip-address-type"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ipv4"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/listen-ports""><div style="max-width: 300px;"><a href="./values.yaml#L145">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/listen-ports"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"[{\"HTTP\": 80}]"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/load-balancer-name""><div style="max-width: 300px;"><a href="./values.yaml#L146">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/load-balancer-name"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-web"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/scheme""><div style="max-width: 300px;"><a href="./values.yaml#L147">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/scheme"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"internet-facing"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/security-groups""><div style="max-width: 300px;"><a href="./values.yaml#L148">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/security-groups"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"lg-security-group"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/tags""><div style="max-width: 300px;"><a href="./values.yaml#L149">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/tags"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"stack=hyperswitch-lb"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations--"alb--ingress--kubernetes--io/target-type""><div style="max-width: 300px;"><a href="./values.yaml#L150">hyperswitch-web.ingress.annotations."alb.ingress.kubernetes.io/target-type"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ip"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--apiVersion"><div style="max-width: 300px;"><a href="./values.yaml#L139">hyperswitch-web.ingress.apiVersion</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"networking.k8s.io/v1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--className"><div style="max-width: 300px;"><a href="./values.yaml#L138">hyperswitch-web.ingress.className</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"alb"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L137">hyperswitch-web.ingress.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--hosts[0]--http"><div style="max-width: 300px;"><a href="./values.yaml#L152">hyperswitch-web.ingress.hosts[0].http</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--hosts[0]--paths[0]--backend--service--name"><div style="max-width: 300px;"><a href="./values.yaml#L158">hyperswitch-web.ingress.hosts[0].paths[0].backend.service.name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-web"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--hosts[0]--paths[0]--backend--service--port--number"><div style="max-width: 300px;"><a href="./values.yaml#L160">hyperswitch-web.ingress.hosts[0].paths[0].backend.service.port.number</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>80</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--hosts[0]--paths[0]--path"><div style="max-width: 300px;"><a href="./values.yaml#L154">hyperswitch-web.ingress.hosts[0].paths[0].path</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"/"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--hosts[0]--paths[0]--pathType"><div style="max-width: 300px;"><a href="./values.yaml#L155">hyperswitch-web.ingress.hosts[0].paths[0].pathType</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Prefix"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--loadBalancer--targetSecurityGroup"><div style="max-width: 300px;"><a href="./values.yaml#L135">hyperswitch-web.loadBalancer.targetSecurityGroup</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"loadbalancer-sg"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--podAnnotations--"helm--sh/hook""><div style="max-width: 300px;"><a href="./values.yaml#L118">hyperswitch-web.podAnnotations."helm.sh/hook"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"post-install,post-upgrade"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--podAnnotations--"helm--sh/hook-delete-policy""><div style="max-width: 300px;"><a href="./values.yaml#L120">hyperswitch-web.podAnnotations."helm.sh/hook-delete-policy"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hook-succeeded"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--podAnnotations--"helm--sh/hook-weight""><div style="max-width: 300px;"><a href="./values.yaml#L119">hyperswitch-web.podAnnotations."helm.sh/hook-weight"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"-5"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L114">hyperswitch-web.sdkDemo.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--service--port"><div style="max-width: 300px;"><a href="./values.yaml#L133">hyperswitch-web.service.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>9090</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="image--pullPolicy"><div style="max-width: 300px;"><a href="./values.yaml#L9">image.pullPolicy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"IfNotPresent"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="image--repository"><div style="max-width: 300px;"><a href="./values.yaml#L8">image.repository</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"nginx"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="image--tag"><div style="max-width: 300px;"><a href="./values.yaml#L11">image.tag</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="imagePullSecrets"><div style="max-width: 300px;"><a href="./values.yaml#L13">imagePullSecrets</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="ingress--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L49">ingress.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="ingress--className"><div style="max-width: 300px;"><a href="./values.yaml#L48">ingress.className</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="ingress--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L47">ingress.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="ingress--hosts[0]--host"><div style="max-width: 300px;"><a href="./values.yaml#L53">ingress.hosts[0].host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="ingress--hosts[0]--paths[0]--path"><div style="max-width: 300px;"><a href="./values.yaml#L55">ingress.hosts[0].paths[0].path</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"/"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="ingress--hosts[0]--paths[0]--pathType"><div style="max-width: 300px;"><a href="./values.yaml#L56">ingress.hosts[0].paths[0].pathType</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ImplementationSpecific"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="ingress--tls"><div style="max-width: 300px;"><a href="./values.yaml#L57">ingress.tls</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="loadBalancer--targetSecurityGroup"><div style="max-width: 300px;"><a href="./values.yaml#L102">loadBalancer.targetSecurityGroup</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"lg-security-group"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="nameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L14">nameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="nodeSelector"><div style="max-width: 300px;"><a href="./values.yaml#L94">nodeSelector</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="podAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L28">podAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="podLabels"><div style="max-width: 300px;"><a href="./values.yaml#L29">podLabels</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="podSecurityContext"><div style="max-width: 300px;"><a href="./values.yaml#L31">podSecurityContext</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L5">replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="resources"><div style="max-width: 300px;"><a href="./values.yaml#L62">resources</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="securityContext"><div style="max-width: 300px;"><a href="./values.yaml#L34">securityContext</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="service--port"><div style="max-width: 300px;"><a href="./values.yaml#L44">service.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>80</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="service--type"><div style="max-width: 300px;"><a href="./values.yaml#L43">service.type</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ClusterIP"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="serviceAccount--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L23">serviceAccount.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="serviceAccount--automount"><div style="max-width: 300px;"><a href="./values.yaml#L21">serviceAccount.automount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="serviceAccount--create"><div style="max-width: 300px;"><a href="./values.yaml#L19">serviceAccount.create</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="serviceAccount--name"><div style="max-width: 300px;"><a href="./values.yaml#L26">serviceAccount.name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="services--router--host"><div style="max-width: 300px;"><a href="./values.yaml#L106">services.router.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:8080"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="services--sdk--host"><div style="max-width: 300px;"><a href="./values.yaml#L108">services.sdk.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:9090"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="tolerations"><div style="max-width: 300px;"><a href="./values.yaml#L96">tolerations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="volumeMounts"><div style="max-width: 300px;"><a href="./values.yaml#L89">volumeMounts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="volumes"><div style="max-width: 300px;"><a href="./values.yaml#L82">volumes</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L696">hyperswitch-app.application.controlCenter.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "deployment.kubernetes.io/revision": "1"
}</pre> </div>
</td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--binary"><div style="max-width: 300px;"><a href="./values.yaml#L706">hyperswitch-app.application.controlCenter.env.binary</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dashboard"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__authentication_analytics"><div style="max-width: 300px;"><a href="./values.yaml#L792">hyperswitch-app.application.controlCenter.env.default__features__authentication_analytics</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__compliance_certificate"><div style="max-width: 300px;"><a href="./values.yaml#L798">hyperswitch-app.application.controlCenter.env.default__features__compliance_certificate</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__configure_pmts"><div style="max-width: 300px;"><a href="./values.yaml#L788">hyperswitch-app.application.controlCenter.env.default__features__configure_pmts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__custom_webhook_headers"><div style="max-width: 300px;"><a href="./values.yaml#L797">hyperswitch-app.application.controlCenter.env.default__features__custom_webhook_headers</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__dispute_analytics"><div style="max-width: 300px;"><a href="./values.yaml#L787">hyperswitch-app.application.controlCenter.env.default__features__dispute_analytics</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__dispute_evidence_upload"><div style="max-width: 300px;"><a href="./values.yaml#L783">hyperswitch-app.application.controlCenter.env.default__features__dispute_evidence_upload</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__global_search"><div style="max-width: 300px;"><a href="./values.yaml#L786">hyperswitch-app.application.controlCenter.env.default__features__global_search</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__live_users_counter"><div style="max-width: 300px;"><a href="./values.yaml#L796">hyperswitch-app.application.controlCenter.env.default__features__live_users_counter</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__paypal_automatic_flow"><div style="max-width: 300px;"><a href="./values.yaml#L784">hyperswitch-app.application.controlCenter.env.default__features__paypal_automatic_flow</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__performance_monitor"><div style="max-width: 300px;"><a href="./values.yaml#L799">hyperswitch-app.application.controlCenter.env.default__features__performance_monitor</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__pm_authentication_processor"><div style="max-width: 300px;"><a href="./values.yaml#L800">hyperswitch-app.application.controlCenter.env.default__features__pm_authentication_processor</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--default__features__threeds_authenticator"><div style="max-width: 300px;"><a href="./values.yaml#L785">hyperswitch-app.application.controlCenter.env.default__features__threeds_authenticator</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"false"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--env--host"><div style="max-width: 300px;"><a href="./values.yaml#L707">hyperswitch-app.application.controlCenter.env.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-control-center"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--labels"><div style="max-width: 300px;"><a href="./values.yaml#L699">hyperswitch-app.application.controlCenter.labels</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "app": "hyperswitch-control-center"
}</pre> </div>
</td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--podAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L693">hyperswitch-app.application.controlCenter.podAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "traffic_sidecar_istio_io_excludeOutboundIPRanges": "10.23.6.12/32"
}</pre> </div>
</td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--progressDeadlineSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L673">hyperswitch-app.application.controlCenter.progressDeadlineSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>600</pre> </div>
</td>
    <td>Wait time allowed for the deployment before the deployment is marked as failed</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--replicas"><div style="max-width: 300px;"><a href="./values.yaml#L671">hyperswitch-app.application.controlCenter.replicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for the application</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--serviceAccountAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L702">hyperswitch-app.application.controlCenter.serviceAccountAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "eks.amazonaws.com/role-arn": null
}</pre> </div>
</td>
    <td>service account annotations to be used</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--controlCenter--strategy"><div style="max-width: 300px;"><a href="./values.yaml#L675">hyperswitch-app.application.controlCenter.strategy</a></div></td>
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
    <td id="hyperswitch-app--application--controlCenter--terminationGracePeriodSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L691">hyperswitch-app.application.controlCenter.terminationGracePeriodSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>The time kubernetes will wait after sending the termination signal to the pods</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--analytics--source"><div style="max-width: 300px;"><a href="./values.yaml#L280">hyperswitch-app.application.server.analytics.source</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"clickhouse"</pre> </div>
</td>
    <td>The Analytics source/strategy to be used</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--analytics--sqlx--connection_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L283">hyperswitch-app.application.server.analytics.sqlx.connection_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>Timeout for database connection in seconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--analytics--sqlx--pool_size"><div style="max-width: 300px;"><a href="./values.yaml#L285">hyperswitch-app.application.server.analytics.sqlx.pool_size</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Number of connections to keep open</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--analytics--sqlx--queue_strategy"><div style="max-width: 300px;"><a href="./values.yaml#L287">hyperswitch-app.application.server.analytics.sqlx.queue_strategy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Fifo"</pre> </div>
</td>
    <td>Add the queue strategy used by the database bb8 client</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L140">hyperswitch-app.application.server.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "deployment.kubernetes.io/revision": "1"
}</pre> </div>
</td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--applepay_merchant_configs--applepay_endpoint"><div style="max-width: 300px;"><a href="./values.yaml#L290">hyperswitch-app.application.server.applepay_merchant_configs.applepay_endpoint</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://apple-pay-gateway.apple.com/paymentservices/registerMerchant"</pre> </div>
</td>
    <td>Apple pay gateway merchant endpoint</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--cell_information--id"><div style="max-width: 300px;"><a href="./values.yaml#L293">hyperswitch-app.application.server.cell_information.id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"12345"</pre> </div>
</td>
    <td>Default CellID for Global Cell Information</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--connector_onboarding--paypal--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L296">hyperswitch-app.application.server.connector_onboarding.paypal.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--connector_request_reference_id_config--merchant_ids_send_payment_id_as_connector_request_id"><div style="max-width: 300px;"><a href="./values.yaml#L299">hyperswitch-app.application.server.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"['merchant_id_1','merchant_id_2']"</pre> </div>
</td>
    <td>List of merchant ids for which the payment id should be sent as connector request id</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--cors--allowed_methods"><div style="max-width: 300px;"><a href="./values.yaml#L302">hyperswitch-app.application.server.cors.allowed_methods</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"GET,POST,PUT,DELETE"</pre> </div>
</td>
    <td>List of methods that are allowed</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--cors--max_age"><div style="max-width: 300px;"><a href="./values.yaml#L304">hyperswitch-app.application.server.cors.max_age</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>Maximum time (in seconds) for which this CORS request may be cached.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--cors--wildcard_origin"><div style="max-width: 300px;"><a href="./values.yaml#L306">hyperswitch-app.application.server.cors.wildcard_origin</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>If true, allows any origin to make requests</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--active_email_client"><div style="max-width: 300px;"><a href="./values.yaml#L309">hyperswitch-app.application.server.email.active_email_client</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"SES"</pre> </div>
</td>
    <td>The currently active email client</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--allowed_unverified_days"><div style="max-width: 300px;"><a href="./values.yaml#L311">hyperswitch-app.application.server.email.allowed_unverified_days</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of days the api calls ( with jwt token ) can be made without verifying the email</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--smtp--connection"><div style="max-width: 300px;"><a href="./values.yaml#L333">hyperswitch-app.application.server.email.smtp.connection</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"plaintext"</pre> </div>
</td>
    <td>connection type to be used for the smtp server</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--smtp--port"><div style="max-width: 300px;"><a href="./values.yaml#L343">hyperswitch-app.application.server.email.smtp.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"1025"</pre> </div>
</td>
    <td>Port of the smtp server</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--smtp--timeout"><div style="max-width: 300px;"><a href="./values.yaml#L345">hyperswitch-app.application.server.email.smtp.timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>timeout for the smtp server connection</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--email--smtp--username"><div style="max-width: 300px;"><a href="./values.yaml#L338">hyperswitch-app.application.server.email.smtp.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>Username for the smtp server</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--encryption_management--encryption_manager"><div style="max-width: 300px;"><a href="./values.yaml#L348">hyperswitch-app.application.server.encryption_management.encryption_manager</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"no_encryption"</pre> </div>
</td>
    <td>Encryption manager client to be used</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--env"><div style="max-width: 300px;"><a href="./values.yaml#L149">hyperswitch-app.application.server.env</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "binary": "router",
  "host": "hyperswitch"
}</pre> </div>
</td>
    <td>Environmant variables that are to be used by the hyperswitch application service this will extend the existing global configuration</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--api_logs_topic"><div style="max-width: 300px;"><a href="./values.yaml#L354">hyperswitch-app.application.server.events.kafka.api_logs_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-api-log-events"</pre> </div>
</td>
    <td>Kafka topic to be used for incoming api events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--attempt_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L356">hyperswitch-app.application.server.events.kafka.attempt_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payment-attempt-events"</pre> </div>
</td>
    <td>Kafka topic to be used for PaymentAttempt events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--audit_events_topic"><div style="max-width: 300px;"><a href="./values.yaml#L358">hyperswitch-app.application.server.events.kafka.audit_events_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-audit-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Payment Audit events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--authentication_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L360">hyperswitch-app.application.server.events.kafka.authentication_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-authentication-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Authentication events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--brokers"><div style="max-width: 300px;"><a href="./values.yaml#L361">hyperswitch-app.application.server.events.kafka.brokers</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"['kafka0:29092']"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--connector_logs_topic"><div style="max-width: 300px;"><a href="./values.yaml#L363">hyperswitch-app.application.server.events.kafka.connector_logs_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-outgoing-connector-events"</pre> </div>
</td>
    <td>Kafka topic to be used for connector api events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--consolidated_events_topic"><div style="max-width: 300px;"><a href="./values.yaml#L365">hyperswitch-app.application.server.events.kafka.consolidated_events_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-consolidated-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Consolidated events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--dispute_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L367">hyperswitch-app.application.server.events.kafka.dispute_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-dispute-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Dispute events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--fraud_check_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L369">hyperswitch-app.application.server.events.kafka.fraud_check_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-fraud-check-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Fraud Check events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--intent_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L371">hyperswitch-app.application.server.events.kafka.intent_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payment-intent-events"</pre> </div>
</td>
    <td>Kafka topic to be used for PaymentIntent events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--outgoing_webhook_logs_topic"><div style="max-width: 300px;"><a href="./values.yaml#L373">hyperswitch-app.application.server.events.kafka.outgoing_webhook_logs_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-outgoing-webhook-events"</pre> </div>
</td>
    <td>Kafka topic to be used for outgoing webhook events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--payout_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L375">hyperswitch-app.application.server.events.kafka.payout_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payout-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Payouts and PayoutAttempt events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--kafka--refund_analytics_topic"><div style="max-width: 300px;"><a href="./values.yaml#L377">hyperswitch-app.application.server.events.kafka.refund_analytics_topic</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-refund-events"</pre> </div>
</td>
    <td>Kafka topic to be used for Refund events</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--events--source"><div style="max-width: 300px;"><a href="./values.yaml#L351">hyperswitch-app.application.server.events.source</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"kafka"</pre> </div>
</td>
    <td>The event sink to push events supports kafka or logs (stdout)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--forex_api--api_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L386">hyperswitch-app.application.server.forex_api.api_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>20001</pre> </div>
</td>
    <td>Api timeouts once it crosses 20000 ms</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--forex_api--call_delay"><div style="max-width: 300px;"><a href="./values.yaml#L380">hyperswitch-app.application.server.forex_api.call_delay</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>21601</pre> </div>
</td>
    <td>Api calls are made after every 6 hrs</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--forex_api--local_fetch_retry_count"><div style="max-width: 300px;"><a href="./values.yaml#L382">hyperswitch-app.application.server.forex_api.local_fetch_retry_count</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Fetch from Local cache has retry count as 5</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--forex_api--local_fetch_retry_delay"><div style="max-width: 300px;"><a href="./values.yaml#L384">hyperswitch-app.application.server.forex_api.local_fetch_retry_delay</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1010</pre> </div>
</td>
    <td>Retry delay for checking write condition</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--forex_api--redis_lock_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L388">hyperswitch-app.application.server.forex_api.redis_lock_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>260001</pre> </div>
</td>
    <td>Redis remains write locked for 26000 ms once the acquire_redis_lock is called</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payment_method_collect--enabled_payment_methods--bank_transfer"><div style="max-width: 300px;"><a href="./values.yaml#L397">hyperswitch-app.application.server.generic_link.payment_method_collect.enabled_payment_methods.bank_transfer</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ach,bacs,sepa"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payment_method_collect--enabled_payment_methods--card"><div style="max-width: 300px;"><a href="./values.yaml#L396">hyperswitch-app.application.server.generic_link.payment_method_collect.enabled_payment_methods.card</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"credit,debit"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payment_method_collect--enabled_payment_methods--wallet"><div style="max-width: 300px;"><a href="./values.yaml#L398">hyperswitch-app.application.server.generic_link.payment_method_collect.enabled_payment_methods.wallet</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"paypal,pix,venmo"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payment_method_collect--ui_config--logo"><div style="max-width: 300px;"><a href="./values.yaml#L392">hyperswitch-app.application.server.generic_link.payment_method_collect.ui_config.logo</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://app.hyperswitch.io/HyperswitchFavicon.png"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payment_method_collect--ui_config--merchant_name"><div style="max-width: 300px;"><a href="./values.yaml#L393">hyperswitch-app.application.server.generic_link.payment_method_collect.ui_config.merchant_name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"HyperSwitch"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payment_method_collect--ui_config--theme"><div style="max-width: 300px;"><a href="./values.yaml#L394">hyperswitch-app.application.server.generic_link.payment_method_collect.ui_config.theme</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#4285F4"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payout_link--enabled_payment_methods--card"><div style="max-width: 300px;"><a href="./values.yaml#L401">hyperswitch-app.application.server.generic_link.payout_link.enabled_payment_methods.card</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"credit,debit"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payout_link--ui_config--logo"><div style="max-width: 300px;"><a href="./values.yaml#L403">hyperswitch-app.application.server.generic_link.payout_link.ui_config.logo</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://app.hyperswitch.io/HyperswitchFavicon.png"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payout_link--ui_config--merchant_name"><div style="max-width: 300px;"><a href="./values.yaml#L404">hyperswitch-app.application.server.generic_link.payout_link.ui_config.merchant_name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"HyperSwitch"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--generic_link--payout_link--ui_config--theme"><div style="max-width: 300px;"><a href="./values.yaml#L405">hyperswitch-app.application.server.generic_link.payout_link.ui_config.theme</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"#4285F4"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--grpc_client--dynamic_routing_client--host"><div style="max-width: 300px;"><a href="./values.yaml#L409">hyperswitch-app.application.server.grpc_client.dynamic_routing_client.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"localhost"</pre> </div>
</td>
    <td>Client Host</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--grpc_client--dynamic_routing_client--port"><div style="max-width: 300px;"><a href="./values.yaml#L411">hyperswitch-app.application.server.grpc_client.dynamic_routing_client.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>7000</pre> </div>
</td>
    <td>Client Port</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--grpc_client--dynamic_routing_client--service"><div style="max-width: 300px;"><a href="./values.yaml#L413">hyperswitch-app.application.server.grpc_client.dynamic_routing_client.service</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dynamo"</pre> </div>
</td>
    <td>Client Service Name</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--labels"><div style="max-width: 300px;"><a href="./values.yaml#L143">hyperswitch-app.application.server.labels</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "app": "hyperswitch-server"
}</pre> </div>
</td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--lock_settings--delay_between_retries_in_milliseconds"><div style="max-width: 300px;"><a href="./values.yaml#L417">hyperswitch-app.application.server.lock_settings.delay_between_retries_in_milliseconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>500</pre> </div>
</td>
    <td>Delay between retries in milliseconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--lock_settings--redis_lock_expiry_seconds"><div style="max-width: 300px;"><a href="./values.yaml#L419">hyperswitch-app.application.server.lock_settings.redis_lock_expiry_seconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>180</pre> </div>
</td>
    <td>Seconds before the redis lock expires</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--locker--host"><div style="max-width: 300px;"><a href="./values.yaml#L425">hyperswitch-app.application.server.locker.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://hyperswitch-vault"</pre> </div>
</td>
    <td>Locker host</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--locker--host_rs"><div style="max-width: 300px;"><a href="./values.yaml#L427">hyperswitch-app.application.server.locker.host_rs</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>Rust Locker host</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--locker--locker_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L429">hyperswitch-app.application.server.locker.locker_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Boolean to enable or disable saving cards in locker</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--locker--locker_signing_key_id"><div style="max-width: 300px;"><a href="./values.yaml#L431">hyperswitch-app.application.server.locker.locker_signing_key_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"1"</pre> </div>
</td>
    <td>Key_id to sign basilisk hs locker</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--locker--mock_locker"><div style="max-width: 300px;"><a href="./values.yaml#L433">hyperswitch-app.application.server.locker.mock_locker</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Emulate a locker locally using Postgres</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--locker--ttl_for_storage_in_secs"><div style="max-width: 300px;"><a href="./values.yaml#L435">hyperswitch-app.application.server.locker.ttl_for_storage_in_secs</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>220752000</pre> </div>
</td>
    <td>Time to live for storage entries in locker</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--console--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L438">hyperswitch-app.application.server.log.console.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--console--level"><div style="max-width: 300px;"><a href="./values.yaml#L440">hyperswitch-app.application.server.log.console.level</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"DEBUG"</pre> </div>
</td>
    <td>Log level for console logs, ERROR, WARN, INFO, DEBUG</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--console--log_format"><div style="max-width: 300px;"><a href="./values.yaml#L441">hyperswitch-app.application.server.log.console.log_format</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"json"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--file--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L443">hyperswitch-app.application.server.log.file.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--file--level"><div style="max-width: 300px;"><a href="./values.yaml#L444">hyperswitch-app.application.server.log.file.level</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"DEBUG"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--file--log_format"><div style="max-width: 300px;"><a href="./values.yaml#L445">hyperswitch-app.application.server.log.file.log_format</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"json"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--bg_metrics_collection_interval_in_secs"><div style="max-width: 300px;"><a href="./values.yaml#L449">hyperswitch-app.application.server.log.telemetry.bg_metrics_collection_interval_in_secs</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>15</pre> </div>
</td>
    <td>Interval for collecting the metrics in background thread</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--ignore_errors"><div style="max-width: 300px;"><a href="./values.yaml#L451">hyperswitch-app.application.server.log.telemetry.ignore_errors</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>boolean [true or false], whether to ignore errors during traces or metrics pipeline setup</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--metrics_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L453">hyperswitch-app.application.server.log.telemetry.metrics_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>boolean [true or false], whether metrics are enabled</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--otel_exporter_otlp_endpoint"><div style="max-width: 300px;"><a href="./values.yaml#L455">hyperswitch-app.application.server.log.telemetry.otel_exporter_otlp_endpoint</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:4317"</pre> </div>
</td>
    <td>endpoint to send metrics and traces to, can include port number</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--otel_exporter_otlp_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L457">hyperswitch-app.application.server.log.telemetry.otel_exporter_otlp_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5000</pre> </div>
</td>
    <td>timeout (in milliseconds) for sending metrics and traces</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--route_to_trace"><div style="max-width: 300px;"><a href="./values.yaml#L458">hyperswitch-app.application.server.log.telemetry.route_to_trace</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"['*/confirm']"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--sampling_rate"><div style="max-width: 300px;"><a href="./values.yaml#L459">hyperswitch-app.application.server.log.telemetry.sampling_rate</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>0.1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--traces_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L461">hyperswitch-app.application.server.log.telemetry.traces_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>boolean [true or false], whether traces are enabled</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--log--telemetry--use_xray_generator"><div style="max-width: 300px;"><a href="./values.yaml#L463">hyperswitch-app.application.server.log.telemetry.use_xray_generator</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Set this to true for AWS X-ray compatible traces</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--master_database--connection_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L467">hyperswitch-app.application.server.master_database.connection_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>Timeout for database connection in seconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--master_database--pool_size"><div style="max-width: 300px;"><a href="./values.yaml#L469">hyperswitch-app.application.server.master_database.pool_size</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"20"</pre> </div>
</td>
    <td>Number of connections to keep open</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--master_database--queue_strategy"><div style="max-width: 300px;"><a href="./values.yaml#L471">hyperswitch-app.application.server.master_database.queue_strategy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Fifo"</pre> </div>
</td>
    <td>Add the queue strategy used by the database bb8 client</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--multitenancy--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L473">hyperswitch-app.application.server.multitenancy.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--multitenancy--global_tenant--clickhouse_database"><div style="max-width: 300px;"><a href="./values.yaml#L475">hyperswitch-app.application.server.multitenancy.global_tenant.clickhouse_database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--multitenancy--global_tenant--redis_key_prefix"><div style="max-width: 300px;"><a href="./values.yaml#L476">hyperswitch-app.application.server.multitenancy.global_tenant.redis_key_prefix</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--multitenancy--global_tenant--schema"><div style="max-width: 300px;"><a href="./values.yaml#L477">hyperswitch-app.application.server.multitenancy.global_tenant.schema</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"public"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--multitenancy--tenants--public--base_url"><div style="max-width: 300px;"><a href="./values.yaml#L480">hyperswitch-app.application.server.multitenancy.tenants.public.base_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:8080"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--multitenancy--tenants--public--clickhouse_database"><div style="max-width: 300px;"><a href="./values.yaml#L481">hyperswitch-app.application.server.multitenancy.tenants.public.clickhouse_database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"default"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--multitenancy--tenants--public--redis_key_prefix"><div style="max-width: 300px;"><a href="./values.yaml#L482">hyperswitch-app.application.server.multitenancy.tenants.public.redis_key_prefix</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--multitenancy--tenants--public--schema"><div style="max-width: 300px;"><a href="./values.yaml#L483">hyperswitch-app.application.server.multitenancy.tenants.public.schema</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"public"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--auth--auth"><div style="max-width: 300px;"><a href="./values.yaml#L486">hyperswitch-app.application.server.opensearch.auth.auth</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"basic"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L488">hyperswitch-app.application.server.opensearch.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"admin"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--auth--region"><div style="max-width: 300px;"><a href="./values.yaml#L489">hyperswitch-app.application.server.opensearch.auth.region</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"eu-central-1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L487">hyperswitch-app.application.server.opensearch.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"admin"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--host"><div style="max-width: 300px;"><a href="./values.yaml#L490">hyperswitch-app.application.server.opensearch.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://localhost:9200"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--indexes--disputes"><div style="max-width: 300px;"><a href="./values.yaml#L492">hyperswitch-app.application.server.opensearch.indexes.disputes</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-dispute-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--indexes--payment_attempts"><div style="max-width: 300px;"><a href="./values.yaml#L493">hyperswitch-app.application.server.opensearch.indexes.payment_attempts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payment-attempt-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--indexes--payment_intents"><div style="max-width: 300px;"><a href="./values.yaml#L494">hyperswitch-app.application.server.opensearch.indexes.payment_intents</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-payment-intent-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--indexes--refunds"><div style="max-width: 300px;"><a href="./values.yaml#L495">hyperswitch-app.application.server.opensearch.indexes.refunds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-refund-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--indexes--sessionizer_disputes"><div style="max-width: 300px;"><a href="./values.yaml#L496">hyperswitch-app.application.server.opensearch.indexes.sessionizer_disputes</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sessionizer-dispute-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--indexes--sessionizer_payment_attempts"><div style="max-width: 300px;"><a href="./values.yaml#L497">hyperswitch-app.application.server.opensearch.indexes.sessionizer_payment_attempts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sessionizer-payment-attempt-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--indexes--sessionizer_payment_intents"><div style="max-width: 300px;"><a href="./values.yaml#L498">hyperswitch-app.application.server.opensearch.indexes.sessionizer_payment_intents</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sessionizer-payment-intent-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--opensearch--indexes--sessionizer_refunds"><div style="max-width: 300px;"><a href="./values.yaml#L499">hyperswitch-app.application.server.opensearch.indexes.sessionizer_refunds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sessionizer-refund-events"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--payment_method_auth--redis_expiry"><div style="max-width: 300px;"><a href="./values.yaml#L502">hyperswitch-app.application.server.payment_method_auth.redis_expiry</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>900</pre> </div>
</td>
    <td>Redis expiry time in milliseconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--paze_decrypt_keys--paze_private_key"><div style="max-width: 300px;"><a href="./values.yaml#L505">hyperswitch-app.application.server.paze_decrypt_keys.paze_private_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PAZE_PRIVATE_KEY"</pre> </div>
</td>
    <td>Base 64 Encoded Private Key File cakey.pem generated for Paze -> Command to create private key: openssl req -newkey rsa:2048 -x509 -keyout cakey.pem -out cacert.pem -days 365</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--paze_decrypt_keys--paze_private_key_passphrase"><div style="max-width: 300px;"><a href="./values.yaml#L507">hyperswitch-app.application.server.paze_decrypt_keys.paze_private_key_passphrase</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"PAZE_PRIVATE_KEY_PASSPHRASE"</pre> </div>
</td>
    <td>PEM Passphrase used for generating Private Key File cakey.pem</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--podAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L137">hyperswitch-app.application.server.podAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "traffic_sidecar_istio_io_excludeOutboundIPRanges": "10.23.6.12/32"
}</pre> </div>
</td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--progressDeadlineSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L93">hyperswitch-app.application.server.progressDeadlineSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>600</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--proxy--bypass_proxy_urls"><div style="max-width: 300px;"><a href="./values.yaml#L510">hyperswitch-app.application.server.proxy.bypass_proxy_urls</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td>A list of URLs that should bypass the proxy</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--proxy--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L511">hyperswitch-app.application.server.proxy.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--proxy--http_url"><div style="max-width: 300px;"><a href="./values.yaml#L513">hyperswitch-app.application.server.proxy.http_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://proxy_http_url"</pre> </div>
</td>
    <td>Outgoing proxy http URL to proxy the HTTP traffic</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--proxy--https_url"><div style="max-width: 300px;"><a href="./values.yaml#L515">hyperswitch-app.application.server.proxy.https_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://proxy_https_url"</pre> </div>
</td>
    <td>Outgoing proxy https URL to proxy the HTTPS traffic</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--auto_pipeline"><div style="max-width: 300px;"><a href="./values.yaml#L519">hyperswitch-app.application.server.redis.auto_pipeline</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Whether or not the client should automatically pipeline commands across tasks when possible.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--cluster_enabled"><div style="max-width: 300px;"><a href="./values.yaml#L521">hyperswitch-app.application.server.redis.cluster_enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>boolean</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--cluster_urls"><div style="max-width: 300px;"><a href="./values.yaml#L523">hyperswitch-app.application.server.redis.cluster_urls</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"['redis.cluster.uri-1:8080', 'redis.cluster.uri-2:4115']"</pre> </div>
</td>
    <td>List of redis cluster urls</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--default_command_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L525">hyperswitch-app.application.server.redis.default_command_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>An optional timeout to apply to all commands. In seconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--default_hash_ttl"><div style="max-width: 300px;"><a href="./values.yaml#L527">hyperswitch-app.application.server.redis.default_hash_ttl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>900</pre> </div>
</td>
    <td>Default TTL for hashes entries, in seconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--default_ttl"><div style="max-width: 300px;"><a href="./values.yaml#L529">hyperswitch-app.application.server.redis.default_ttl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>300</pre> </div>
</td>
    <td>Default TTL for entries, in seconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--disable_auto_backpressure"><div style="max-width: 300px;"><a href="./values.yaml#L531">hyperswitch-app.application.server.redis.disable_auto_backpressure</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>Whether or not to disable the automatic backpressure features when pipelining is enabled.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--host"><div style="max-width: 300px;"><a href="./values.yaml#L532">hyperswitch-app.application.server.redis.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"127.0.0.1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--max_feed_count"><div style="max-width: 300px;"><a href="./values.yaml#L534">hyperswitch-app.application.server.redis.max_feed_count</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>200</pre> </div>
</td>
    <td>The maximum number of frames that will be fed to a socket before flushing.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--max_in_flight_commands"><div style="max-width: 300px;"><a href="./values.yaml#L536">hyperswitch-app.application.server.redis.max_in_flight_commands</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5000</pre> </div>
</td>
    <td>The maximum number of in-flight commands (per connection) before backpressure will be applied.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--pool_size"><div style="max-width: 300px;"><a href="./values.yaml#L538">hyperswitch-app.application.server.redis.pool_size</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Number of connections to keep open</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--port"><div style="max-width: 300px;"><a href="./values.yaml#L539">hyperswitch-app.application.server.redis.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>6379</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--reconnect_delay"><div style="max-width: 300px;"><a href="./values.yaml#L541">hyperswitch-app.application.server.redis.reconnect_delay</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Delay between reconnection attempts, in milliseconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--reconnect_max_attempts"><div style="max-width: 300px;"><a href="./values.yaml#L543">hyperswitch-app.application.server.redis.reconnect_max_attempts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>Maximum number of reconnection attempts to make before failing. Set to 0 to retry forever.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--stream_read_count"><div style="max-width: 300px;"><a href="./values.yaml#L545">hyperswitch-app.application.server.redis.stream_read_count</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Default number of entries to read from stream if not provided in stream read options</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--unresponsive_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L547">hyperswitch-app.application.server.redis.unresponsive_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>An optional timeout for Unresponsive commands in seconds. This should be less than default_command_timeout.</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--redis--use_legacy_version"><div style="max-width: 300px;"><a href="./values.yaml#L549">hyperswitch-app.application.server.redis.use_legacy_version</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>RESP protocol for fred crate (set this to true if using RESPv2 or redis version < 6)</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--replica_database--connection_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L553">hyperswitch-app.application.server.replica_database.connection_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td>Timeout for database connection in seconds</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--replica_database--pool_size"><div style="max-width: 300px;"><a href="./values.yaml#L555">hyperswitch-app.application.server.replica_database.pool_size</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"20"</pre> </div>
</td>
    <td>Number of connections to keep open</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--replica_database--queue_strategy"><div style="max-width: 300px;"><a href="./values.yaml#L557">hyperswitch-app.application.server.replica_database.queue_strategy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Fifo"</pre> </div>
</td>
    <td>Add the queue strategy used by the database bb8 client</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--replicas"><div style="max-width: 300px;"><a href="./values.yaml#L91">hyperswitch-app.application.server.replicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>Number of replicas to be used for the application</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--report_download_config--dispute_function"><div style="max-width: 300px;"><a href="./values.yaml#L560">hyperswitch-app.application.server.report_download_config.dispute_function</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"report_download_config_dispute_function"</pre> </div>
</td>
    <td>Config to download dispute report</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--report_download_config--payment_function"><div style="max-width: 300px;"><a href="./values.yaml#L562">hyperswitch-app.application.server.report_download_config.payment_function</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"report_download_config_payment_function"</pre> </div>
</td>
    <td>Config to download payment report</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--report_download_config--refund_function"><div style="max-width: 300px;"><a href="./values.yaml#L564">hyperswitch-app.application.server.report_download_config.refund_function</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"report_download_config_refund_function"</pre> </div>
</td>
    <td>Config to download refund report</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--report_download_config--region"><div style="max-width: 300px;"><a href="./values.yaml#L566">hyperswitch-app.application.server.report_download_config.region</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"report_download_config_region"</pre> </div>
</td>
    <td>Region of the bucket</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--run_env"><div style="max-width: 300px;"><a href="./values.yaml#L568">hyperswitch-app.application.server.run_env</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sandbox"</pre> </div>
</td>
    <td>Processor URLs will be decided based on this config, Eg: sandbox or production</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_connector_onboarding_paypal_client_id"><div style="max-width: 300px;"><a href="./values.yaml#L220">hyperswitch-app.application.server.secrets.kms_connector_onboarding_paypal_client_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_connector_onboarding_paypal_client_secret"><div style="max-width: 300px;"><a href="./values.yaml#L222">hyperswitch-app.application.server.secrets.kms_connector_onboarding_paypal_client_secret</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_connector_onboarding_paypal_partner_id"><div style="max-width: 300px;"><a href="./values.yaml#L224">hyperswitch-app.application.server.secrets.kms_connector_onboarding_paypal_partner_id</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_jwekey_rust_locker_encryption_key"><div style="max-width: 300px;"><a href="./values.yaml#L218">hyperswitch-app.application.server.secrets.kms_jwekey_rust_locker_encryption_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets--kms_jwekey_tunnel_private_key"><div style="max-width: 300px;"><a href="./values.yaml#L216">hyperswitch-app.application.server.secrets.kms_jwekey_tunnel_private_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"dummy_val"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets_management--hc_vault--token"><div style="max-width: 300px;"><a href="./values.yaml#L574">hyperswitch-app.application.server.secrets_management.hc_vault.token</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"vault_token"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets_management--hc_vault--url"><div style="max-width: 300px;"><a href="./values.yaml#L573">hyperswitch-app.application.server.secrets_management.hc_vault.url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://vault:8200"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--secrets_management--secrets_manager"><div style="max-width: 300px;"><a href="./values.yaml#L571">hyperswitch-app.application.server.secrets_management.secrets_manager</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"no_encryption"</pre> </div>
</td>
    <td>Secrets manager client to be used</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--server--host"><div style="max-width: 300px;"><a href="./values.yaml#L577">hyperswitch-app.application.server.server.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0.0.0.0"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--server--port"><div style="max-width: 300px;"><a href="./values.yaml#L578">hyperswitch-app.application.server.server.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>8080</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--server--request_body_limit"><div style="max-width: 300px;"><a href="./values.yaml#L580">hyperswitch-app.application.server.server.request_body_limit</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>32768</pre> </div>
</td>
    <td>HTTP Request body limit. Defaults to 32kB</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--server--shutdown_timeout"><div style="max-width: 300px;"><a href="./values.yaml#L583">hyperswitch-app.application.server.server.shutdown_timeout</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>For more details: https://actix.rs/docs/server/#graceful-shutdown</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--server--workers"><div style="max-width: 300px;"><a href="./values.yaml#L584">hyperswitch-app.application.server.server.workers</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>8</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--serviceAccountAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L146">hyperswitch-app.application.server.serviceAccountAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "eks.amazonaws.com/role-arn": "my-role-arn"
}</pre> </div>
</td>
    <td>service account annotations to be used</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--strategy--rollingUpdate--maxSurge"><div style="max-width: 300px;"><a href="./values.yaml#L97">hyperswitch-app.application.server.strategy.rollingUpdate.maxSurge</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--strategy--rollingUpdate--maxUnavailable"><div style="max-width: 300px;"><a href="./values.yaml#L98">hyperswitch-app.application.server.strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>0</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--strategy--type"><div style="max-width: 300px;"><a href="./values.yaml#L99">hyperswitch-app.application.server.strategy.type</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"RollingUpdate"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--terminationGracePeriodSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L135">hyperswitch-app.application.server.terminationGracePeriodSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td>The time kubernetes will wait after sending the termination signal to the pods</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--user--base_url"><div style="max-width: 300px;"><a href="./values.yaml#L586">hyperswitch-app.application.server.user.base_url</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:9000"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--user--force_two_factor_auth"><div style="max-width: 300px;"><a href="./values.yaml#L587">hyperswitch-app.application.server.user.force_two_factor_auth</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--user--password_validity_in_days"><div style="max-width: 300px;"><a href="./values.yaml#L588">hyperswitch-app.application.server.user.password_validity_in_days</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"90"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--user--totp_issuer_name"><div style="max-width: 300px;"><a href="./values.yaml#L589">hyperswitch-app.application.server.user.totp_issuer_name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"Hyperswitch Sandbox"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--application--server--user--two_factor_auth_expiry_in_secs"><div style="max-width: 300px;"><a href="./values.yaml#L590">hyperswitch-app.application.server.user.two_factor_auth_expiry_in_secs</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"300"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--autoscaling--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L945">hyperswitch-app.autoscaling.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--autoscaling--maxReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L947">hyperswitch-app.autoscaling.maxReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>10</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--autoscaling--minReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L946">hyperswitch-app.autoscaling.minReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--autoscaling--targetCPUUtilizationPercentage"><div style="max-width: 300px;"><a href="./values.yaml#L948">hyperswitch-app.autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>80</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--image--tag"><div style="max-width: 300px;"><a href="./values.yaml#L1021">hyperswitch-app.clickhouse.image.tag</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>24.3</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--clickhouse--resourcesPreset"><div style="max-width: 300px;"><a href="./values.yaml#L1012">hyperswitch-app.clickhouse.resourcesPreset</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"none"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L951">hyperswitch-app.hyperswitch-card-vault.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--initDB--checkPGisUp--image"><div style="max-width: 300px;"><a href="./values.yaml#L936">hyperswitch-app.initDB.checkPGisUp.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"postgres:16-alpine3.19"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--initDB--checkPGisUp--maxAttempt"><div style="max-width: 300px;"><a href="./values.yaml#L937">hyperswitch-app.initDB.checkPGisUp.maxAttempt</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--initDB--enable"><div style="max-width: 300px;"><a href="./values.yaml#L934">hyperswitch-app.initDB.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--initDB--migration--image"><div style="max-width: 300px;"><a href="./values.yaml#L939">hyperswitch-app.initDB.migration.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"christophwurst/diesel-cli:latest"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--kafka--extraConfig"><div style="max-width: 300px;"><a href="./values.yaml#L1001">hyperswitch-app.kafka.extraConfig</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"offsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\n"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--loadBalancer--targetSecurityGroup"><div style="max-width: 300px;"><a href="./values.yaml#L942">hyperswitch-app.loadBalancer.targetSecurityGroup</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"loadBalancer-sg"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--redisMiscConfig--checkRedisIsUp--initContainer--enable"><div style="max-width: 300px;"><a href="./values.yaml#L842">hyperswitch-app.redisMiscConfig.checkRedisIsUp.initContainer.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--redisMiscConfig--checkRedisIsUp--initContainer--image"><div style="max-width: 300px;"><a href="./values.yaml#L843">hyperswitch-app.redisMiscConfig.checkRedisIsUp.initContainer.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"redis:7.2.4"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--redisMiscConfig--checkRedisIsUp--initContainer--maxAttempt"><div style="max-width: 300px;"><a href="./values.yaml#L844">hyperswitch-app.redisMiscConfig.checkRedisIsUp.initContainer.maxAttempt</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--external--postgresql--config--database"><div style="max-width: 300px;"><a href="./values.yaml#L125">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--external--postgresql--config--host"><div style="max-width: 300px;"><a href="./values.yaml#L121">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--external--postgresql--config--password"><div style="max-width: 300px;"><a href="./values.yaml#L124">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--external--postgresql--config--port"><div style="max-width: 300px;"><a href="./values.yaml#L122">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--external--postgresql--config--username"><div style="max-width: 300px;"><a href="./values.yaml#L123">hyperswitch-app.hyperswitch-card-vault.external.postgresql.config.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--external--postgresql--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L119">hyperswitch-app.hyperswitch-card-vault.external.postgresql.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--initDB--checkPGisUp--image"><div style="max-width: 300px;"><a href="./values.yaml#L132">hyperswitch-app.hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"postgres:16-alpine3.19"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--initDB--checkPGisUp--maxAttempt"><div style="max-width: 300px;"><a href="./values.yaml#L133">hyperswitch-app.hyperswitch-card-vault.initDB.checkPGisUp.maxAttempt</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--initDB--enable"><div style="max-width: 300px;"><a href="./values.yaml#L130">hyperswitch-app.hyperswitch-card-vault.initDB.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--initDB--migration--image"><div style="max-width: 300px;"><a href="./values.yaml#L135">hyperswitch-app.hyperswitch-card-vault.initDB.migration.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"christophwurst/diesel-cli:latest"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--postgresql--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L102">hyperswitch-app.hyperswitch-card-vault.postgresql.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--postgresql--global--postgresql--auth--architecture"><div style="max-width: 300px;"><a href="./values.yaml#L110">hyperswitch-app.hyperswitch-card-vault.postgresql.global.postgresql.auth.architecture</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"standalone"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--postgresql--global--postgresql--auth--database"><div style="max-width: 300px;"><a href="./values.yaml#L109">hyperswitch-app.hyperswitch-card-vault.postgresql.global.postgresql.auth.database</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"locker-db"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--postgresql--global--postgresql--auth--password"><div style="max-width: 300px;"><a href="./values.yaml#L108">hyperswitch-app.hyperswitch-card-vault.postgresql.global.postgresql.auth.password</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"V2tkS1ptTkhSbnBqZDI4OUNnPT0K"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--postgresql--global--postgresql--auth--username"><div style="max-width: 300px;"><a href="./values.yaml#L107">hyperswitch-app.hyperswitch-card-vault.postgresql.global.postgresql.auth.username</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"db_user"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--postgresql--nameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L103">hyperswitch-app.hyperswitch-card-vault.postgresql.nameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"locker-db"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--postgresql--primary--name"><div style="max-width: 300px;"><a href="./values.yaml#L112">hyperswitch-app.hyperswitch-card-vault.postgresql.primary.name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--postgresql--primary--resources--requests--cpu"><div style="max-width: 300px;"><a href="./values.yaml#L115">hyperswitch-app.hyperswitch-card-vault.postgresql.primary.resources.requests.cpu</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"100m"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L13">hyperswitch-app.hyperswitch-card-vault.server.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--extra--env"><div style="max-width: 300px;"><a href="./values.yaml#L98">hyperswitch-app.hyperswitch-card-vault.server.extra.env</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--image"><div style="max-width: 300px;"><a href="./values.yaml#L16">hyperswitch-app.hyperswitch-card-vault.server.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-card-vault:v0.4.0"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--nodeAffinity--requiredDuringSchedulingIgnoredDuringExecution"><div style="max-width: 300px;"><a href="./values.yaml#L25">hyperswitch-app.hyperswitch-card-vault.server.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--pod--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L21">hyperswitch-app.hyperswitch-card-vault.server.pod.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--secrets--locker_private_key"><div style="max-width: 300px;"><a href="./values.yaml#L54">hyperswitch-app.hyperswitch-card-vault.server.secrets.locker_private_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>The private key for the locker from locker-private-key.pem</td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--secrets--master_key"><div style="max-width: 300px;"><a href="./values.yaml#L41">hyperswitch-app.hyperswitch-card-vault.server.secrets.master_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"a164665dd3a545c194aa297e4d2cdbd19aa3c59865907e9ffffb7b8d9fcb476208f84fe53bbc7801f2b8eb1aab633fb24ad0bb99b275066fb56516ef"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-app--hyperswitch-card-vault--server--secrets--tenant_public_key"><div style="max-width: 300px;"><a href="./values.yaml#L84">hyperswitch-app.hyperswitch-card-vault.server.secrets.tenant_public_key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td>The public key for the tenant from tenant-public-key.pem</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--affinity"><div style="max-width: 300px;"><a href="./values.yaml#L196">hyperswitch-web.affinity</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td>Affinity rules</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--buildImage"><div style="max-width: 300px;"><a href="./values.yaml#L54">hyperswitch-web.autoBuild.buildImage</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-web"</pre> </div>
</td>
    <td>docker image to use for the build</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--buildParam--envBackendUrl"><div style="max-width: 300px;"><a href="./values.yaml#L64">hyperswitch-web.autoBuild.buildParam.envBackendUrl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://hyperswitch"</pre> </div>
</td>
    <td>node build parameter, hyperswitch server host</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--buildParam--envLogsUrl"><div style="max-width: 300px;"><a href="./values.yaml#L66">hyperswitch-web.autoBuild.buildParam.envLogsUrl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://hyperswitch-sdk-logs"</pre> </div>
</td>
    <td>node build parameter, hyperswitch SDK logs host</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--buildParam--envSdkUrl"><div style="max-width: 300px;"><a href="./values.yaml#L62">hyperswitch-web.autoBuild.buildParam.envSdkUrl</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://hyperswitch-sdk"</pre> </div>
</td>
    <td>node build parameter, hyperswitch-web sdk host (same as ingress host)</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--enable"><div style="max-width: 300px;"><a href="./values.yaml#L50">hyperswitch-web.autoBuild.enable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>enable npm auto build</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--forceBuild"><div style="max-width: 300px;"><a href="./values.yaml#L52">hyperswitch-web.autoBuild.forceBuild</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>force rebuild assets even these files exist</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--gitCloneParam--gitRepo"><div style="max-width: 300px;"><a href="./values.yaml#L57">hyperswitch-web.autoBuild.gitCloneParam.gitRepo</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"https://github.com/juspay/hyperswitch-web"</pre> </div>
</td>
    <td>hyperswitch-web repository</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--gitCloneParam--gitVersion"><div style="max-width: 300px;"><a href="./values.yaml#L59">hyperswitch-web.autoBuild.gitCloneParam.gitVersion</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0.71.11"</pre> </div>
</td>
    <td>hyperswitch-web repository tag</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--nginxConfig--extraPath"><div style="max-width: 300px;"><a href="./values.yaml#L69">hyperswitch-web.autoBuild.nginxConfig.extraPath</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v0"</pre> </div>
</td>
    <td>nginx static server extra path ( like https://<host>/0.15.8/v0 )</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--nginxConfig--image"><div style="max-width: 300px;"><a href="./values.yaml#L71">hyperswitch-web.autoBuild.nginxConfig.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"nginx"</pre> </div>
</td>
    <td>nginx static server image</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoBuild--nginxConfig--tag"><div style="max-width: 300px;"><a href="./values.yaml#L73">hyperswitch-web.autoBuild.nginxConfig.tag</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"1.25.3"</pre> </div>
</td>
    <td>nginx static server tag</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoscaling--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L164">hyperswitch-web.autoscaling.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>false</pre> </div>
</td>
    <td>enable autoscaling</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoscaling--maxReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L168">hyperswitch-web.autoscaling.maxReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>5</pre> </div>
</td>
    <td>autoscaling max replicas</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoscaling--minReplicas"><div style="max-width: 300px;"><a href="./values.yaml#L166">hyperswitch-web.autoscaling.minReplicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>autoscaling min replicas</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoscaling--targetCPUUtilizationPercentage"><div style="max-width: 300px;"><a href="./values.yaml#L170">hyperswitch-web.autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>80</pre> </div>
</td>
    <td>autoscaling target CPU utilization</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--autoscaling--targetMemoryUtilizationPercentage"><div style="max-width: 300px;"><a href="./values.yaml#L172">hyperswitch-web.autoscaling.targetMemoryUtilizationPercentage</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>80</pre> </div>
</td>
    <td>autoscaling target memory utilization</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--envFrom[0]--configMapRef--name"><div style="max-width: 300px;"><a href="./values.yaml#L187">hyperswitch-web.envFrom[0].configMapRef.name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-web-nginx"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--fullnameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L92">hyperswitch-web.fullnameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>chart full name override</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--image--nginxConfig--extraPath"><div style="max-width: 300px;"><a href="./values.yaml#L85">hyperswitch-web.image.nginxConfig.extraPath</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"v0"</pre> </div>
</td>
    <td>nginx extra path used to set liveness and readiness probe /0.80.0/v0</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--image--pullPolicy"><div style="max-width: 300px;"><a href="./values.yaml#L80">hyperswitch-web.image.pullPolicy</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"IfNotPresent"</pre> </div>
</td>
    <td>prebuild image pull policy</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--image--repository"><div style="max-width: 300px;"><a href="./values.yaml#L78">hyperswitch-web.image.repository</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"nginx"</pre> </div>
</td>
    <td>prebuild SDK image</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--image--tag"><div style="max-width: 300px;"><a href="./values.yaml#L82">hyperswitch-web.image.tag</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"0.35.4"</pre> </div>
</td>
    <td>prebuild image tag, the image tag whose default is the chart appVersion.</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--imagePullSecrets"><div style="max-width: 300px;"><a href="./values.yaml#L88">hyperswitch-web.imagePullSecrets</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td>image pull secret</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L136">hyperswitch-web.ingress.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td>ingress annotations</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--className"><div style="max-width: 300px;"><a href="./values.yaml#L134">hyperswitch-web.ingress.className</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"nginx"</pre> </div>
</td>
    <td>ingress class name</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L132">hyperswitch-web.ingress.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>enable/disable ingress</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--hosts"><div style="max-width: 300px;"><a href="./values.yaml#L140">hyperswitch-web.ingress.hosts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[
  {
    "host": "chart-example.local",
    "paths": [
      {
        "path": "/",
        "pathType": "ImplementationSpecific"
      }
    ]
  }
]</pre> </div>
</td>
    <td>ingress hosts list</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--ingress--tls"><div style="max-width: 300px;"><a href="./values.yaml#L146">hyperswitch-web.ingress.tls</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td>tls configurations list</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--loadBalancer--targetSecurityGroup"><div style="max-width: 300px;"><a href="./values.yaml#L200">hyperswitch-web.loadBalancer.targetSecurityGroup</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"loadBalancer-sg"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--nameOverride"><div style="max-width: 300px;"><a href="./values.yaml#L90">hyperswitch-web.nameOverride</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>chart override</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--nodeSelector"><div style="max-width: 300px;"><a href="./values.yaml#L190">hyperswitch-web.nodeSelector</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td>Node selector</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--podAnnotations"><div style="max-width: 300px;"><a href="./values.yaml#L105">hyperswitch-web.podAnnotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td>pod annotations</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--podLabels"><div style="max-width: 300px;"><a href="./values.yaml#L107">hyperswitch-web.podLabels</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td>pod labels</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--podSecurityContext"><div style="max-width: 300px;"><a href="./values.yaml#L110">hyperswitch-web.podSecurityContext</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td>pod security context</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--replicaCount"><div style="max-width: 300px;"><a href="./values.yaml#L46">hyperswitch-web.replicaCount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td>deployment/statefulset replicas</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--resources"><div style="max-width: 300px;"><a href="./values.yaml#L150">hyperswitch-web.resources</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{
  "limits": {
    "cpu": "1500m",
    "memory": "3Gi"
  },
  "requests": {
    "cpu": "100m",
    "memory": "128Mi"
  }
}</pre> </div>
</td>
    <td>pod ressource configuration</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--annotations--"deployment--kubernetes--io/revision""><div style="max-width: 300px;"><a href="./values.yaml#L29">hyperswitch-web.sdkDemo.annotations."deployment.kubernetes.io/revision"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"1"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--enabled"><div style="max-width: 300px;"><a href="./values.yaml#L2">hyperswitch-web.sdkDemo.enabled</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--env--binary"><div style="max-width: 300px;"><a href="./values.yaml#L39">hyperswitch-web.sdkDemo.env.binary</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"sdk"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--env--host"><div style="max-width: 300px;"><a href="./values.yaml#L38">hyperswitch-web.sdkDemo.env.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-sdk-demo"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--labels--app"><div style="max-width: 300px;"><a href="./values.yaml#L32">hyperswitch-web.sdkDemo.labels.app</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"hyperswitch-sdk-demo"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--nodeAffinity--requiredDuringSchedulingIgnoredDuringExecution--nodeSelectorTerms[0]--matchExpressions[0]--key"><div style="max-width: 300px;"><a href="./values.yaml#L18">hyperswitch-web.sdkDemo.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"node-type"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--nodeAffinity--requiredDuringSchedulingIgnoredDuringExecution--nodeSelectorTerms[0]--matchExpressions[0]--operator"><div style="max-width: 300px;"><a href="./values.yaml#L19">hyperswitch-web.sdkDemo.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"In"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--nodeAffinity--requiredDuringSchedulingIgnoredDuringExecution--nodeSelectorTerms[0]--matchExpressions[0]--values[0]"><div style="max-width: 300px;"><a href="./values.yaml#L21">hyperswitch-web.sdkDemo.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"generic-compute"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--podAnnotations--traffic_sidecar_istio_io_excludeOutboundIPRanges"><div style="max-width: 300px;"><a href="./values.yaml#L26">hyperswitch-web.sdkDemo.podAnnotations.traffic_sidecar_istio_io_excludeOutboundIPRanges</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"10.23.6.12/32"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--progressDeadlineSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L6">hyperswitch-web.sdkDemo.progressDeadlineSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>600</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--replicas"><div style="max-width: 300px;"><a href="./values.yaml#L4">hyperswitch-web.sdkDemo.replicas</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--serviceAccountAnnotations--"eks--amazonaws--com/role-arn""><div style="max-width: 300px;"><a href="./values.yaml#L35">hyperswitch-web.sdkDemo.serviceAccountAnnotations."eks.amazonaws.com/role-arn"</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>null</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--strategy--rollingUpdate--maxSurge"><div style="max-width: 300px;"><a href="./values.yaml#L10">hyperswitch-web.sdkDemo.strategy.rollingUpdate.maxSurge</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>1</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--strategy--rollingUpdate--maxUnavailable"><div style="max-width: 300px;"><a href="./values.yaml#L11">hyperswitch-web.sdkDemo.strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>0</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--strategy--type"><div style="max-width: 300px;"><a href="./values.yaml#L12">hyperswitch-web.sdkDemo.strategy.type</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"RollingUpdate"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--sdkDemo--terminationGracePeriodSeconds"><div style="max-width: 300px;"><a href="./values.yaml#L23">hyperswitch-web.sdkDemo.terminationGracePeriodSeconds</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>30</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--securityContext"><div style="max-width: 300px;"><a href="./values.yaml#L114">hyperswitch-web.securityContext</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td>security context</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--service--port"><div style="max-width: 300px;"><a href="./values.yaml#L127">hyperswitch-web.service.port</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>9090</pre> </div>
</td>
    <td>service port</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--service--type"><div style="max-width: 300px;"><a href="./values.yaml#L125">hyperswitch-web.service.type</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"ClusterIP"</pre> </div>
</td>
    <td>service type</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--serviceAccount--annotations"><div style="max-width: 300px;"><a href="./values.yaml#L100">hyperswitch-web.serviceAccount.annotations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>{}</pre> </div>
</td>
    <td>Annotations to add to the service account</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--serviceAccount--automount"><div style="max-width: 300px;"><a href="./values.yaml#L98">hyperswitch-web.serviceAccount.automount</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Automatically mount a ServiceAccount's API credentials?</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--serviceAccount--create"><div style="max-width: 300px;"><a href="./values.yaml#L96">hyperswitch-web.serviceAccount.create</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>true</pre> </div>
</td>
    <td>Specifies whether a service account should be created</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--serviceAccount--name"><div style="max-width: 300px;"><a href="./values.yaml#L102">hyperswitch-web.serviceAccount.name</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>""</pre> </div>
</td>
    <td>The name of the service account to use. If not set and create is true, a name is generated using the fullname template</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--services--router--host"><div style="max-width: 300px;"><a href="./values.yaml#L204">hyperswitch-web.services.router.host</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"http://localhost:8080"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--services--sdkDemo--hyperswitchPublishableKey"><div style="max-width: 300px;"><a href="./values.yaml#L207">hyperswitch-web.services.sdkDemo.hyperswitchPublishableKey</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"pub_key"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--services--sdkDemo--hyperswitchSecretKey"><div style="max-width: 300px;"><a href="./values.yaml#L208">hyperswitch-web.services.sdkDemo.hyperswitchSecretKey</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"secret_key"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--services--sdkDemo--image"><div style="max-width: 300px;"><a href="./values.yaml#L206">hyperswitch-web.services.sdkDemo.image</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>"juspaydotin/hyperswitch-web:v1.0.10"</pre> </div>
</td>
    <td></td>
</tr>

	
<tr>
    <td id="hyperswitch-web--tolerations"><div style="max-width: 300px;"><a href="./values.yaml#L193">hyperswitch-web.tolerations</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[]</pre> </div>
</td>
    <td>Tolerations</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--volumeMounts"><div style="max-width: 300px;"><a href="./values.yaml#L181">hyperswitch-web.volumeMounts</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[
  {
    "mountPath": "/etc/nginx/conf.d/default.conf",
    "name": "nginx-config-volume",
    "subPath": "default.conf"
  }
]</pre> </div>
</td>
    <td>Additional volumeMounts on the output Deployment definition.</td>
</tr>

	
<tr>
    <td id="hyperswitch-web--volumes"><div style="max-width: 300px;"><a href="./values.yaml#L175">hyperswitch-web.volumes</a></div></td>
    <td>
<div style="max-width: 300px;"> <pre>[
  {
    "configMap": {
      "name": "hyperswitch-web-nginx"
    },
    "name": "nginx-config-volume"
  }
]</pre> </div>
</td>
    <td>Additional volumes on the output Deployment definition.</td>
</tr>

</tbody>
</table>

