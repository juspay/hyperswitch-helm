# hyperswitch-app

Hyperswitch is a community-led, open payments switch designed to empower digital businesses by providing fast, reliable, and affordable access to the best payments infrastructure.

![Version: 0.2.1](https://img.shields.io/badge/Version-0.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

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
Note: minimum --memory 6000 --cpus 4 needed
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

## 💳 Test a payment

Hyperswitch Control center will mimic the behavior of your checkout page. Please follow below steps to test a payment with the deployed app

### 🔐 Step 1 - Deploy card vault

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

    # Add key1, key2 and then decrypt
    curl -X POST -H "Content-Type: application/json" -d '{"key": "<key 1>"}' http://localhost:8080/custodian/key1
    curl -X POST -H "Content-Type: application/json" -d '{"key": "<key 2>"}' http://localhost:8080/custodian/key2
    curl -X POST http://localhost:8080/custodian/decrypt
   
  If the last cURL replies with `Decrypted Successfully`, we are ready to use the locker.
   </p>
</details>

### Step 2 - Make a payment using our Control Center

Use the Hyperswitch Control Center and [make a payment with test card](https://docs.hyperswitch.io/hyperswitch-open-source/account-setup/test-a-payment).

Refer our [postman collection](https://www.postman.com/hyperswitch/workspace/hyperswitch/folder/25176183-0103918c-6611-459b-9faf-354dee8e4437) to try out REST APIs

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
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L758">application.controlCenter.env.default__endpoints__agreement_url</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"</code></div></td>
    <td>Hyperswitch terms and conditions url</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L764">application.controlCenter.env.default__endpoints__agreement_version</a></div></td>
    <td><div><code>"1.0.0"</code></div></td>
    <td>Agreement version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L761">application.controlCenter.env.default__endpoints__dss_certificate_url</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/certificates/PCI_DSS_v4-0_AOC_Juspay_2024.pdf"</code></div></td>
    <td>PCI DSS certificate url</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L752">application.controlCenter.env.default__endpoints__favicon_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Endpoints favicon url</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L749">application.controlCenter.env.default__endpoints__logo_url</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Endpoints logo url</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L755">application.controlCenter.env.default__endpoints__mixpanel_token</a></div></td>
    <td><div><code>"dd4da7f62941557e716fbc0a19f9cc7e"</code></div></td>
    <td>Mixpanel token</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L818">application.controlCenter.env.default__features__branding</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables customization of branding elements like logos, colors.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L773">application.controlCenter.env.default__features__email</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables user sign-in and sign-up using magic links instead of passwords. When enabled, users can request a magic link via email that logs them into their account or creates a new account if they are signing up.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L797">application.controlCenter.env.default__features__feedback</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the ability for users to provide direct product feedback from within the dashboard. When enabled, a feedback modal will be available in the UI that allows users to rate features, report bugs, and suggest improvements. Disabling this flag will remove the feedback modal and prevent collection of any user data.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L785">application.controlCenter.env.default__features__frm</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the Fraud and Risk Management (FRM) module within the dashboard. When enabled, this unlocks integrations with FRM players like Riskified and Signified. https://docs.hyperswitch.io/explore-hyperswitch/payment-flows-and-management/fraud-and-risk-management</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L803">application.controlCenter.env.default__features__generate_report</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Controls the ability to generate detailed reports on payments, refunds, and disputes. When enabled, this allows users to pull reports covering the previous 6 months of transaction data. The reports can provide insights into trends, identify issues, and inform business decisions.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L770">application.controlCenter.env.default__features__is_live_mode</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the live mode - that the user is accessing. When enabled, it will show a visual indicator within the dashboard signaling whether the user is currently in a test environment or live production environment. In Live mode, current users are not allowed to sign up. Users must be created manually.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L800">application.controlCenter.env.default__features__mixpanel</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Controls the collection and transmission of anonymous usage data to Mixpanel for analytics. When enabled, the dashboard will automatically send information about user actions and events to Mixpanel without collecting any personally identifiable information via REST API.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L788">application.controlCenter.env.default__features__payout</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the payout functionality in the dashboard. When enabled, this allows users to configure payout profiles, manage recipient details, schedule disbursements, and process payout batches to pay out funds to third parties.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L776">application.controlCenter.env.default__features__quick_start</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the simplified onboarding flow for new users, where they connect to processors, configure payment routing and test a payment, all in one flow.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L791">application.controlCenter.env.default__features__recon</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables access to reconciliation capabilities in the Hyperswitch dashboard. When turned on, this unlocks the Reconciliation module that allows users to match payment transactions with bank/ledger entries for accounting purposes.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L782">application.controlCenter.env.default__features__sample_data</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the ability to load simulated sample data into the dashboard for preview purposes. When enabled, dummy transactions, analytics, and reporting data can be generated.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L809">application.controlCenter.env.default__features__surcharge</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables the ability to apply surcharges to payments. When enabled, you can create advanced rules based on payment parameters like amount, currency, and payment method to enforce surcharges as needed.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L779">application.controlCenter.env.default__features__system_metrics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Unlocks access to system monitoring and metrics pages within the dashboard. When enabled, users can view technical performance data like payment latency, uptime, API response times, error rates, and more.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L767">application.controlCenter.env.default__features__test_live_toggle</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables users to toggle between test and live modes when signing in. When enabled, users will see an option during sign-in to actively switch between test and live environments.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L794">application.controlCenter.env.default__features__test_processors</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Allows enabling sandbox/test payment processors for testing purposes. When enabled, developers and testers can add test payment processors like Stripe Test or PayPal Test to trial payment flows without touching live transactions or making processor API calls.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L822">application.controlCenter.env.default__features__totp</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Enables totp will mandate 2fa for all users</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L806">application.controlCenter.env.default__features__user_journey_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td>Grants access to the user journey module within the analytics section of the dashboard. This feature provides comprehensive graphical representations of payment analytics, facilitating a deeper understanding of user behavior and usage patterns.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L740">application.controlCenter.env.default__theme__primary_color</a></div></td>
    <td><div><code>"#006DF9"</code></div></td>
    <td>Primary color for the theme</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L743">application.controlCenter.env.default__theme__primary_hover_color</a></div></td>
    <td><div><code>"#005ED6"</code></div></td>
    <td>Primary hover color for the theme</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L746">application.controlCenter.env.default__theme__sidebar_color</a></div></td>
    <td><div><code>"#242F48"</code></div></td>
    <td>Secondary color for the theme</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L737">application.controlCenter.env.mixpanelToken</a></div></td>
    <td><div><code>"dd4da7f62941557e716fbc0a19f9cc7e"</code></div></td>
    <td>Mix panel token</td>
  </tr></tbody>
</table>
<h3>App Server Secrets</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L276">application.server.analytics.clickhouse.database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse database name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L279">application.server.analytics.clickhouse.host</a></div></td>
    <td><div><code>"http://clickhouse:8123"</code></div></td>
    <td>Clickhouse host in http(s)://<URL>:<PORT> format</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L285">application.server.analytics.clickhouse.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Clickhouse password (optional)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L282">application.server.analytics.clickhouse.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L321">application.server.email.aws_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS region used by AWS SES</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L325">application.server.email.aws_ses.email_role_arn</a></div></td>
    <td><div><code>"arn:aws:iam::123456789012:role/SendEmailRole"</code></div></td>
    <td>The amazon resource name ( arn ) of the role which has permission to send emails</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L328">application.server.email.aws_ses.sts_role_session_name</a></div></td>
    <td><div><code>"SendEmailRole"</code></div></td>
    <td>An identifier for the assumed role session, used to uniquely identify a session.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L331">application.server.email.prod_intent_recipient_email</a></div></td>
    <td><div><code>"business@example.com"</code></div></td>
    <td>Recipient email for prod intent email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L334">application.server.email.recon_recipient_email</a></div></td>
    <td><div><code>"recon@example.com"</code></div></td>
    <td>Recipient email for recon request email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L337">application.server.email.sender_email</a></div></td>
    <td><div><code>"example@example.com"</code></div></td>
    <td>Sender email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L343">application.server.email.smtp.host</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Host of the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L348">application.server.email.smtp.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Password for the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L513">application.server.paze_decrypt_keys.paze_private_key</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY"</code></div></td>
    <td>Base 64 Encoded Private Key File cakey.pem generated for Paze -> Command to create private key: openssl req -newkey rsa:2048 -x509 -keyout cakey.pem -out cacert.pem -days 365</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L516">application.server.paze_decrypt_keys.paze_private_key_passphrase</a></div></td>
    <td><div><code>"PAZE_PRIVATE_KEY_PASSPHRASE"</code></div></td>
    <td>PEM Passphrase used for generating Private Key File cakey.pem</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L162">application.server.secrets.admin_api_key</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>admin API key for admin authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L267">application.server.secrets.api_hash_key</a></div></td>
    <td><div><code>"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"</code></div></td>
    <td>API key hashing key.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L237">application.server.secrets.apple_pay_merchant_cert</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L240">application.server.secrets.apple_pay_merchant_cert_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generated by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L249">application.server.secrets.apple_pay_merchant_conf_merchant_cert</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Merchant Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Merchant Identity Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L252">application.server.secrets.apple_pay_merchant_conf_merchant_cert_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generate by RSA:2048 algorithm. Refer Hyperswitch Docs (https://docs.hyperswitch.io/hyperswitch-cloud/payment-methods-setup/wallets/apple-pay/ios-application/) to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L255">application.server.secrets.apple_pay_merchant_conf_merchant_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Refer to config.example.toml to learn how you can generate this value</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L243">application.server.secrets.apple_pay_ppc</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Payment Processing Certificate provided by Apple Pay (https://developer.apple.com/) Certificates, Identifiers & Profiles > Apple Pay Payment Processing Certificate</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L246">application.server.secrets.apple_pay_ppc_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Private key generated by Elliptic-curve prime256v1 curve. You can use `openssl ecparam -out private.key -name prime256v1 -genkey` to generate the private key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L258">application.server.secrets.forex_api_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Api key for making request to foreign exchange Api, Follow https://github.com/juspay/hyperswitch/tree/main/crates/analytics#setting-up-forex-apis to get the forex api key</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L261">application.server.secrets.forex_fallback_api_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Forex Api key for the fallback service</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L165">application.server.secrets.jwt_secret</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>JWT secret used for user authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L181">application.server.secrets.kms_jwekey_vault_encryption_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the locker from locker-public-key.pub, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L194">application.server.secrets.kms_jwekey_vault_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>The private key for the tenant from tenant-private-key.pem, these are only test keys, please change it when deploying to production or other environments</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L174">application.server.secrets.kms_key_id</a></div></td>
    <td><div><code>"kms_key_id"</code></div></td>
    <td>KMS key id for encryption and decryption</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L177">application.server.secrets.kms_key_region</a></div></td>
    <td><div><code>"us-east-1"</code></div></td>
    <td>AWS KMS region</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L168">application.server.secrets.master_enc_key</a></div></td>
    <td><div><code>"471f22516724347bcca9c20c5fa88d9821c4604e63a6aceffd24605809c9237c"</code></div></td>
    <td>Master Encryption key used to encrypt merchant wise encryption key. Should be 32-byte long.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L264">application.server.secrets.pm_auth_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td># Payment method auth key used for authorization</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L171">application.server.secrets.recon_admin_api_key</a></div></td>
    <td><div><code>"test_admin"</code></div></td>
    <td>Recon Admin API key for recon admin authentication.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L234">application.server.secrets.redis_temp_locker_encryption_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Encryption key for redis temp locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L270">application.server.secrets.user_auth_encryption_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td>Encryption key used for encrypting data in user_authentication_methods table</td>
  </tr></tbody>
</table>
<h3>Dependencies configuration</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L1069">clickhouse.auth.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Clickhouse password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1066">clickhouse.auth.username</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td>Clickhouse username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1075">clickhouse.config.TZ</a></div></td>
    <td><div><code>"Asia/Kolkata"</code></div></td>
    <td>Clickhouse timezone</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1058">clickhouse.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Clickhouse sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1062">clickhouse.fullnameOverride</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>Name of the Clickhouse sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1088">clickhouse.logLevel</a></div></td>
    <td><div><code>"error"</code></div></td>
    <td>Clickhouse log level</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1081">clickhouse.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse replica count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1078">clickhouse.shards</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Clickhouse shard count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1085">clickhouse.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Zookerper replica count</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L928">externalPostgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Postgres server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L945">externalPostgresql.primary.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L939">externalPostgresql.primary.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L942">externalPostgresql.primary.auth.plainpassword</a></div></td>
    <td><div><code>null</code></div></td>
    <td>master DB plainpassword</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L936">externalPostgresql.primary.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>master DB username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L932">externalPostgresql.primary.host</a></div></td>
    <td><div><code>"postgresql-ext"</code></div></td>
    <td>External postgres host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L965">externalPostgresql.readOnly.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L959">externalPostgresql.readOnly.auth.password</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L962">externalPostgresql.readOnly.auth.plainpassword</a></div></td>
    <td><div><code>null</code></div></td>
    <td>replica DB plainpassword</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L956">externalPostgresql.readOnly.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>replica DB username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L949">externalPostgresql.readOnly.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>External postgres read only host enabled or disabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L952">externalPostgresql.readOnly.host</a></div></td>
    <td><div><code>"postgres-service"</code></div></td>
    <td>External postgres read only host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L862">externalRedis.auth.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>auth enabled or disabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L868">externalRedis.auth.password</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L865">externalRedis.auth.username</a></div></td>
    <td><div><code>""</code></div></td>
    <td>redis username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L855">externalRedis.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Link this service to an external Redis server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L858">externalRedis.host</a></div></td>
    <td><div><code>"redis-ext-master"</code></div></td>
    <td>External redis host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1013">kafka.broker.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for broker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1008">kafka.controller.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for controller</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1000">kafka.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Kafka sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1003">kafka.fullnameOverride</a></div></td>
    <td><div><code>"kafka0"</code></div></td>
    <td>Name of the Kafka sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1030">kafka.listeners.client.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener client protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1042">kafka.listeners.controller.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener controller protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1038">kafka.listeners.external.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener external protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1034">kafka.listeners.interbroker.protocol</a></div></td>
    <td><div><code>"PLAINTEXT"</code></div></td>
    <td>Listener interbroker protocol</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1046">kafka.provisioning.replicationFactor</a></div></td>
    <td><div><code>1</code></div></td>
    <td>kafka provisioning replicationFactor</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1025">kafka.service.ports.client</a></div></td>
    <td><div><code>29092</code></div></td>
    <td>Client port for Kafka</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1020">kafka.zookeeper.replicaCount</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for zookeeper</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1143">loki-stack.grafana.adminPassword</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td>Name of the Grafana sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1140">loki-stack.grafana.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Grafana sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1147">loki-stack.grafana.image.tag</a></div></td>
    <td><div><code>"10.0.1"</code></div></td>
    <td>Grafana image tag</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1120">loki-stack.loki.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Loki sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1123">loki-stack.loki.fullnameOverride</a></div></td>
    <td><div><code>"loki"</code></div></td>
    <td>Name of the Loki sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1127">loki-stack.promtail.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Promtail sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1110">mailhog.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Mailhog sub-chart helm installation for email testing</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1113">mailhog.fullnameOverride</a></div></td>
    <td><div><code>"mailhog"</code></div></td>
    <td>Name of the Mailhog sub-chart</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L898">postgresql.architecture</a></div></td>
    <td><div><code>"replication"</code></div></td>
    <td>Postgresql architecture: replication or standalone</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L881">postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>enable Bitnami postgresql sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L895">postgresql.global.postgresql.auth.database</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql database</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L892">postgresql.global.postgresql.auth.password</a></div></td>
    <td><div><code>"ZGJwYXNzd29yZDEx"</code></div></td>
    <td>Postgresql password</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L889">postgresql.global.postgresql.auth.username</a></div></td>
    <td><div><code>"hyperswitch"</code></div></td>
    <td>Postgresql username</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L909">postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td>postgres primary name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L914">postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"150m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L918">postgresql.readReplicas.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of read replicas</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L923">postgresql.readReplicas.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td>CPU resource requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L905">postgresql.replication.numSynchronousReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of synchronous replicas</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L902">postgresql.replication.synchronousCommit</a></div></td>
    <td><div><code>"off"</code></div></td>
    <td>synchronous_commit parameter</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L847">redis.auth.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable redis auth</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L850">redis.auth.sentinel</a></div></td>
    <td><div><code>false</code></div></td>
    <td>enable or disable sentinel</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L833">redis.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>- enable Bitnami redis sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L839">redis.master.count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for master</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L843">redis.replica.replicaCount</a></div></td>
    <td><div><code>0</code></div></td>
    <td>Number of replicas to be used for replica</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1153">vector.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Enable Bitnami Vector sub-chart helm installation</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1157">vector.env[0]</a></div></td>
    <td><div><code>{
  "name": "KAFKA_HOST",
  "value": "kafka0:29092"
}</code></div></td>
    <td>Vector environment variables</td>
  </tr></tbody>
</table>
<h3>Services</h3>
<table height="400px">
<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>
<tbody><tr>
    <td><div><a href="./values.yaml#L15">services.consumer.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-consumer:v1.112.0"</code></div></td>
    <td>Consumer image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L23">services.controlCenter.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-control-center:v1.34.2"</code></div></td>
    <td>Control Center image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L19">services.producer.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-producer:v1.112.0"</code></div></td>
    <td>Producer image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L11">services.router.host</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td>Router host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L8">services.router.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-router:v1.112.0"</code></div></td>
    <td>Router image</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L5">services.router.version</a></div></td>
    <td><div><code>"v1.112.0"</code></div></td>
    <td>Router version</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L27">services.sdk.host</a></div></td>
    <td><div><code>"http://localhost:9050"</code></div></td>
    <td>SDK host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L33">services.sdk.subversion</a></div></td>
    <td><div><code>"v0"</code></div></td>
    <td>SDK subversion</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L30">services.sdk.version</a></div></td>
    <td><div><code>"0.103.1"</code></div></td>
    <td>SDK version</td>
  </tr></tbody>
</table>
<h3>Other Values</h3>
<table>

<thead>
	<th >Key</th>
	<th >Default</th>
	<th >Description</th>
</thead>

<tbody><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L13">global.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key</a></div></td>
    <td><div><code>"node-type"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L14">global.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator</a></div></td>
    <td><div><code>"In"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L16">global.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]</a></div></td>
    <td><div><code>"generic-compute"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L4">global.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L5">global.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L733">application.controlCenter.env.binary</a></div></td>
    <td><div><code>"dashboard"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L819">application.controlCenter.env.default__features__authentication_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L825">application.controlCenter.env.default__features__compliance_certificate</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L815">application.controlCenter.env.default__features__configure_pmts</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L824">application.controlCenter.env.default__features__custom_webhook_headers</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L814">application.controlCenter.env.default__features__dispute_analytics</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L810">application.controlCenter.env.default__features__dispute_evidence_upload</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L813">application.controlCenter.env.default__features__global_search</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L823">application.controlCenter.env.default__features__live_users_counter</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L811">application.controlCenter.env.default__features__paypal_automatic_flow</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L826">application.controlCenter.env.default__features__performance_monitor</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L827">application.controlCenter.env.default__features__pm_authentication_processor</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L812">application.controlCenter.env.default__features__threeds_authenticator</a></div></td>
    <td><div><code>"false"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L734">application.controlCenter.env.host</a></div></td>
    <td><div><code>"hyperswitch-control-center"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L690">application.controlCenter.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for the application</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L287">application.server.analytics.source</a></div></td>
    <td><div><code>"clickhouse"</code></div></td>
    <td>The Analytics source/strategy to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L290">application.server.analytics.sqlx.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L292">application.server.analytics.sqlx.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L294">application.server.analytics.sqlx.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L146">application.server.annotations</a></div></td>
    <td><div><code>{
  "deployment.kubernetes.io/revision": "1"
}</code></div></td>
    <td>Annotations that are to be added the the deployments (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L297">application.server.applepay_merchant_configs.applepay_endpoint</a></div></td>
    <td><div><code>"https://apple-pay-gateway.apple.com/paymentservices/registerMerchant"</code></div></td>
    <td>Apple pay gateway merchant endpoint</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L300">application.server.cell_information.id</a></div></td>
    <td><div><code>"12345"</code></div></td>
    <td>Default CellID for Global Cell Information</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L303">application.server.connector_onboarding.paypal.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L306">application.server.connector_request_reference_id_config.merchant_ids_send_payment_id_as_connector_request_id</a></div></td>
    <td><div><code>"['merchant_id_1','merchant_id_2']"</code></div></td>
    <td>List of merchant ids for which the payment id should be sent as connector request id</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L309">application.server.cors.allowed_methods</a></div></td>
    <td><div><code>"GET,POST,PUT,DELETE"</code></div></td>
    <td>List of methods that are allowed</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L311">application.server.cors.max_age</a></div></td>
    <td><div><code>30</code></div></td>
    <td>Maximum time (in seconds) for which this CORS request may be cached.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L313">application.server.cors.wildcard_origin</a></div></td>
    <td><div><code>true</code></div></td>
    <td>If true, allows any origin to make requests</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L316">application.server.email.active_email_client</a></div></td>
    <td><div><code>"SES"</code></div></td>
    <td>The currently active email client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L318">application.server.email.allowed_unverified_days</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of days the api calls ( with jwt token ) can be made without verifying the email</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L340">application.server.email.smtp.connection</a></div></td>
    <td><div><code>"plaintext"</code></div></td>
    <td>connection type to be used for the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L350">application.server.email.smtp.port</a></div></td>
    <td><div><code>"1025"</code></div></td>
    <td>Port of the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L352">application.server.email.smtp.timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>timeout for the smtp server connection</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L345">application.server.email.smtp.username</a></div></td>
    <td><div><code>""</code></div></td>
    <td>Username for the smtp server</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L355">application.server.encryption_management.encryption_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Encryption manager client to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L361">application.server.events.kafka.api_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-api-log-events"</code></div></td>
    <td>Kafka topic to be used for incoming api events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L363">application.server.events.kafka.attempt_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td>Kafka topic to be used for PaymentAttempt events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L365">application.server.events.kafka.audit_events_topic</a></div></td>
    <td><div><code>"hyperswitch-audit-events"</code></div></td>
    <td>Kafka topic to be used for Payment Audit events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L367">application.server.events.kafka.authentication_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-authentication-events"</code></div></td>
    <td>Kafka topic to be used for Authentication events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L368">application.server.events.kafka.brokers</a></div></td>
    <td><div><code>"['kafka0:29092']"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L370">application.server.events.kafka.connector_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-connector-events"</code></div></td>
    <td>Kafka topic to be used for connector api events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L372">application.server.events.kafka.consolidated_events_topic</a></div></td>
    <td><div><code>"hyperswitch-consolidated-events"</code></div></td>
    <td>Kafka topic to be used for Consolidated events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L374">application.server.events.kafka.dispute_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td>Kafka topic to be used for Dispute events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L376">application.server.events.kafka.fraud_check_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-fraud-check-events"</code></div></td>
    <td>Kafka topic to be used for Fraud Check events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L378">application.server.events.kafka.intent_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td>Kafka topic to be used for PaymentIntent events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L380">application.server.events.kafka.outgoing_webhook_logs_topic</a></div></td>
    <td><div><code>"hyperswitch-outgoing-webhook-events"</code></div></td>
    <td>Kafka topic to be used for outgoing webhook events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L382">application.server.events.kafka.payout_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-payout-events"</code></div></td>
    <td>Kafka topic to be used for Payouts and PayoutAttempt events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L384">application.server.events.kafka.refund_analytics_topic</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td>Kafka topic to be used for Refund events</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L358">application.server.events.source</a></div></td>
    <td><div><code>"kafka"</code></div></td>
    <td>The event sink to push events supports kafka or logs (stdout)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L393">application.server.forex_api.api_timeout</a></div></td>
    <td><div><code>20001</code></div></td>
    <td>Api timeouts once it crosses 20000 ms</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L387">application.server.forex_api.call_delay</a></div></td>
    <td><div><code>21601</code></div></td>
    <td>Api calls are made after every 6 hrs</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L389">application.server.forex_api.local_fetch_retry_count</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Fetch from Local cache has retry count as 5</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L391">application.server.forex_api.local_fetch_retry_delay</a></div></td>
    <td><div><code>1010</code></div></td>
    <td>Retry delay for checking write condition</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L395">application.server.forex_api.redis_lock_timeout</a></div></td>
    <td><div><code>260001</code></div></td>
    <td>Redis remains write locked for 26000 ms once the acquire_redis_lock is called</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L404">application.server.generic_link.payment_method_collect.enabled_payment_methods.bank_transfer</a></div></td>
    <td><div><code>"ach,bacs,sepa"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L403">application.server.generic_link.payment_method_collect.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L405">application.server.generic_link.payment_method_collect.enabled_payment_methods.wallet</a></div></td>
    <td><div><code>"paypal,pix,venmo"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L399">application.server.generic_link.payment_method_collect.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L400">application.server.generic_link.payment_method_collect.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L401">application.server.generic_link.payment_method_collect.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L408">application.server.generic_link.payout_link.enabled_payment_methods.card</a></div></td>
    <td><div><code>"credit,debit"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L410">application.server.generic_link.payout_link.ui_config.logo</a></div></td>
    <td><div><code>"https://app.hyperswitch.io/HyperswitchFavicon.png"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L411">application.server.generic_link.payout_link.ui_config.merchant_name</a></div></td>
    <td><div><code>"HyperSwitch"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L412">application.server.generic_link.payout_link.ui_config.theme</a></div></td>
    <td><div><code>"#4285F4"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L416">application.server.grpc_client.dynamic_routing_client.host</a></div></td>
    <td><div><code>"localhost"</code></div></td>
    <td>Client Host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L418">application.server.grpc_client.dynamic_routing_client.port</a></div></td>
    <td><div><code>7000</code></div></td>
    <td>Client Port</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L420">application.server.grpc_client.dynamic_routing_client.service</a></div></td>
    <td><div><code>"dynamo"</code></div></td>
    <td>Client Service Name</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L149">application.server.labels</a></div></td>
    <td><div><code>{
  "app": "hyperswitch-server"
}</code></div></td>
    <td>Labels to be added to the deployment's (match labels) and their pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L424">application.server.lock_settings.delay_between_retries_in_milliseconds</a></div></td>
    <td><div><code>500</code></div></td>
    <td>Delay between retries in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L426">application.server.lock_settings.redis_lock_expiry_seconds</a></div></td>
    <td><div><code>180</code></div></td>
    <td>Seconds before the redis lock expires</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L432">application.server.locker.host</a></div></td>
    <td><div><code>"http://hyperswitch-vault"</code></div></td>
    <td>Locker host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L434">application.server.locker.host_rs</a></div></td>
    <td><div><code>null</code></div></td>
    <td>Rust Locker host</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L436">application.server.locker.locker_enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Boolean to enable or disable saving cards in locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L438">application.server.locker.locker_signing_key_id</a></div></td>
    <td><div><code>"1"</code></div></td>
    <td>Key_id to sign basilisk hs locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L440">application.server.locker.mock_locker</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Emulate a locker locally using Postgres</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L442">application.server.locker.ttl_for_storage_in_secs</a></div></td>
    <td><div><code>220752000</code></div></td>
    <td>Time to live for storage entries in locker</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L445">application.server.log.console.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L447">application.server.log.console.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td>Log level for console logs, ERROR, WARN, INFO, DEBUG</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L448">application.server.log.console.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L450">application.server.log.file.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L451">application.server.log.file.level</a></div></td>
    <td><div><code>"DEBUG"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L452">application.server.log.file.log_format</a></div></td>
    <td><div><code>"json"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L456">application.server.log.telemetry.bg_metrics_collection_interval_in_secs</a></div></td>
    <td><div><code>15</code></div></td>
    <td>Interval for collecting the metrics in background thread</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L458">application.server.log.telemetry.ignore_errors</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether to ignore errors during traces or metrics pipeline setup</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L460">application.server.log.telemetry.metrics_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether metrics are enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L462">application.server.log.telemetry.otel_exporter_otlp_endpoint</a></div></td>
    <td><div><code>"http://localhost:4317"</code></div></td>
    <td>endpoint to send metrics and traces to, can include port number</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L464">application.server.log.telemetry.otel_exporter_otlp_timeout</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>timeout (in milliseconds) for sending metrics and traces</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L465">application.server.log.telemetry.route_to_trace</a></div></td>
    <td><div><code>"['*/confirm']"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L466">application.server.log.telemetry.sampling_rate</a></div></td>
    <td><div><code>0.1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L468">application.server.log.telemetry.traces_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean [true or false], whether traces are enabled</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L470">application.server.log.telemetry.use_xray_generator</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Set this to true for AWS X-ray compatible traces</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L474">application.server.master_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L476">application.server.master_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L478">application.server.master_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L480">application.server.multitenancy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L482">application.server.multitenancy.global_tenant.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L483">application.server.multitenancy.global_tenant.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L484">application.server.multitenancy.global_tenant.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L487">application.server.multitenancy.tenants.public.base_url</a></div></td>
    <td><div><code>"http://localhost:8080"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L488">application.server.multitenancy.tenants.public.clickhouse_database</a></div></td>
    <td><div><code>"default"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L489">application.server.multitenancy.tenants.public.redis_key_prefix</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L490">application.server.multitenancy.tenants.public.schema</a></div></td>
    <td><div><code>"public"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L493">application.server.opensearch.auth.auth</a></div></td>
    <td><div><code>"basic"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L495">application.server.opensearch.auth.password</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L496">application.server.opensearch.auth.region</a></div></td>
    <td><div><code>"eu-central-1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L494">application.server.opensearch.auth.username</a></div></td>
    <td><div><code>"admin"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L497">application.server.opensearch.host</a></div></td>
    <td><div><code>"https://localhost:9200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L499">application.server.opensearch.indexes.disputes</a></div></td>
    <td><div><code>"hyperswitch-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L500">application.server.opensearch.indexes.payment_attempts</a></div></td>
    <td><div><code>"hyperswitch-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L501">application.server.opensearch.indexes.payment_intents</a></div></td>
    <td><div><code>"hyperswitch-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L502">application.server.opensearch.indexes.refunds</a></div></td>
    <td><div><code>"hyperswitch-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L503">application.server.opensearch.indexes.sessionizer_disputes</a></div></td>
    <td><div><code>"sessionizer-dispute-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L504">application.server.opensearch.indexes.sessionizer_payment_attempts</a></div></td>
    <td><div><code>"sessionizer-payment-attempt-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L505">application.server.opensearch.indexes.sessionizer_payment_intents</a></div></td>
    <td><div><code>"sessionizer-payment-intent-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L506">application.server.opensearch.indexes.sessionizer_refunds</a></div></td>
    <td><div><code>"sessionizer-refund-events"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L509">application.server.payment_method_auth.redis_expiry</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Redis expiry time in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L143">application.server.podAnnotations</a></div></td>
    <td><div><code>{
  "traffic_sidecar_istio_io_excludeOutboundIPRanges": "10.23.6.12/32"
}</code></div></td>
    <td>Annotations that are to be added to the pods (extends global configuration)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L98">application.server.progressDeadlineSeconds</a></div></td>
    <td><div><code>600</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L519">application.server.proxy.bypass_proxy_urls</a></div></td>
    <td><div><code>[]</code></div></td>
    <td>A list of URLs that should bypass the proxy</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L520">application.server.proxy.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L522">application.server.proxy.http_url</a></div></td>
    <td><div><code>"http://proxy_http_url"</code></div></td>
    <td>Outgoing proxy http URL to proxy the HTTP traffic</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L524">application.server.proxy.https_url</a></div></td>
    <td><div><code>"https://proxy_https_url"</code></div></td>
    <td>Outgoing proxy https URL to proxy the HTTPS traffic</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L528">application.server.redis.auto_pipeline</a></div></td>
    <td><div><code>true</code></div></td>
    <td>Whether or not the client should automatically pipeline commands across tasks when possible.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L530">application.server.redis.cluster_enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td>boolean</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L532">application.server.redis.cluster_urls</a></div></td>
    <td><div><code>"['redis.cluster.uri-1:8080', 'redis.cluster.uri-2:4115']"</code></div></td>
    <td>List of redis cluster urls</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L534">application.server.redis.default_command_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>An optional timeout to apply to all commands. In seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L536">application.server.redis.default_hash_ttl</a></div></td>
    <td><div><code>900</code></div></td>
    <td>Default TTL for hashes entries, in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L538">application.server.redis.default_ttl</a></div></td>
    <td><div><code>300</code></div></td>
    <td>Default TTL for entries, in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L540">application.server.redis.disable_auto_backpressure</a></div></td>
    <td><div><code>false</code></div></td>
    <td>Whether or not to disable the automatic backpressure features when pipelining is enabled.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L541">application.server.redis.host</a></div></td>
    <td><div><code>"127.0.0.1"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L543">application.server.redis.max_feed_count</a></div></td>
    <td><div><code>200</code></div></td>
    <td>The maximum number of frames that will be fed to a socket before flushing.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L545">application.server.redis.max_in_flight_commands</a></div></td>
    <td><div><code>5000</code></div></td>
    <td>The maximum number of in-flight commands (per connection) before backpressure will be applied.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L547">application.server.redis.pool_size</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L548">application.server.redis.port</a></div></td>
    <td><div><code>6379</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L550">application.server.redis.reconnect_delay</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Delay between reconnection attempts, in milliseconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L552">application.server.redis.reconnect_max_attempts</a></div></td>
    <td><div><code>5</code></div></td>
    <td>Maximum number of reconnection attempts to make before failing. Set to 0 to retry forever.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L554">application.server.redis.stream_read_count</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Default number of entries to read from stream if not provided in stream read options</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L556">application.server.redis.unresponsive_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>An optional timeout for Unresponsive commands in seconds. This should be less than default_command_timeout.</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L558">application.server.redis.use_legacy_version</a></div></td>
    <td><div><code>false</code></div></td>
    <td>RESP protocol for fred crate (set this to true if using RESPv2 or redis version < 6)</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L562">application.server.replica_database.connection_timeout</a></div></td>
    <td><div><code>10</code></div></td>
    <td>Timeout for database connection in seconds</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L564">application.server.replica_database.pool_size</a></div></td>
    <td><div><code>"20"</code></div></td>
    <td>Number of connections to keep open</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L566">application.server.replica_database.queue_strategy</a></div></td>
    <td><div><code>"Fifo"</code></div></td>
    <td>Add the queue strategy used by the database bb8 client</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L96">application.server.replicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td>Number of replicas to be used for the application</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L569">application.server.report_download_config.dispute_function</a></div></td>
    <td><div><code>"report_download_config_dispute_function"</code></div></td>
    <td>Config to download dispute report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L571">application.server.report_download_config.payment_function</a></div></td>
    <td><div><code>"report_download_config_payment_function"</code></div></td>
    <td>Config to download payment report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L573">application.server.report_download_config.refund_function</a></div></td>
    <td><div><code>"report_download_config_refund_function"</code></div></td>
    <td>Config to download refund report</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L575">application.server.report_download_config.region</a></div></td>
    <td><div><code>"report_download_config_region"</code></div></td>
    <td>Region of the bucket</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L577">application.server.run_env</a></div></td>
    <td><div><code>"sandbox"</code></div></td>
    <td>Processor URLs will be decided based on this config, Eg: sandbox or production</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L227">application.server.secrets.kms_connector_onboarding_paypal_client_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L229">application.server.secrets.kms_connector_onboarding_paypal_client_secret</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L231">application.server.secrets.kms_connector_onboarding_paypal_partner_id</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L225">application.server.secrets.kms_jwekey_rust_locker_encryption_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L223">application.server.secrets.kms_jwekey_tunnel_private_key</a></div></td>
    <td><div><code>"dummy_val"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L583">application.server.secrets_management.hc_vault.token</a></div></td>
    <td><div><code>"vault_token"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L582">application.server.secrets_management.hc_vault.url</a></div></td>
    <td><div><code>"http://vault:8200"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L580">application.server.secrets_management.secrets_manager</a></div></td>
    <td><div><code>"no_encryption"</code></div></td>
    <td>Secrets manager client to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L586">application.server.server.host</a></div></td>
    <td><div><code>"0.0.0.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L587">application.server.server.port</a></div></td>
    <td><div><code>8080</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L589">application.server.server.request_body_limit</a></div></td>
    <td><div><code>32768</code></div></td>
    <td>HTTP Request body limit. Defaults to 32kB</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L592">application.server.server.shutdown_timeout</a></div></td>
    <td><div><code>30</code></div></td>
    <td>For more details: https://actix.rs/docs/server/#graceful-shutdown</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L593">application.server.server.workers</a></div></td>
    <td><div><code>8</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L152">application.server.serviceAccountAnnotations</a></div></td>
    <td><div><code>{
  "eks.amazonaws.com/role-arn": "my-role-arn"
}</code></div></td>
    <td>service account annotations to be used</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L102">application.server.strategy.rollingUpdate.maxSurge</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L103">application.server.strategy.rollingUpdate.maxUnavailable</a></div></td>
    <td><div><code>0</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L104">application.server.strategy.type</a></div></td>
    <td><div><code>"RollingUpdate"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L141">application.server.terminationGracePeriodSeconds</a></div></td>
    <td><div><code>30</code></div></td>
    <td>The time kubernetes will wait after sending the termination signal to the pods</td>
  </tr><tr>
    <td><div><a href="./values.yaml#L595">application.server.user.base_url</a></div></td>
    <td><div><code>"http://localhost:9000"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L600">application.server.user.force_cookies</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L596">application.server.user.force_two_factor_auth</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L597">application.server.user.password_validity_in_days</a></div></td>
    <td><div><code>"90"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L598">application.server.user.totp_issuer_name</a></div></td>
    <td><div><code>"Hyperswitch Sandbox"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L599">application.server.user.two_factor_auth_expiry_in_secs</a></div></td>
    <td><div><code>"300"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L980">autoscaling.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L982">autoscaling.maxReplicas</a></div></td>
    <td><div><code>10</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L981">autoscaling.minReplicas</a></div></td>
    <td><div><code>1</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L983">autoscaling.targetCPUUtilizationPercentage</a></div></td>
    <td><div><code>80</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1071">clickhouse.image.tag</a></div></td>
    <td><div><code>24.3</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1059">clickhouse.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L986">hyperswitch-card-vault.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L988">hyperswitch-card-vault.global.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L994">hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"docker.io/bitnami/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L991">hyperswitch-card-vault.postgresql.primary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L970">initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"docker.io/bitnami/postgresql:16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L971">initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L968">initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L974">initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L972">initDB.refs</a></div></td>
    <td><div><code>"tags"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1014">kafka.broker.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1009">kafka.controller.resourcesPreset</a></div></td>
    <td><div><code>"none"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L1050">kafka.extraConfig</a></div></td>
    <td><div><code>"offsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\n"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L977">loadBalancer.targetSecurityGroup</a></div></td>
    <td><div><code>"loadBalancer-sg"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L883">postgresql.image.tag</a></div></td>
    <td><div><code>"16.1.0-debian-11-r18"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L835">redis.image.tag</a></div></td>
    <td><div><code>"7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L873">redisMiscConfig.checkRedisIsUp.initContainer.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L874">redisMiscConfig.checkRedisIsUp.initContainer.image</a></div></td>
    <td><div><code>"docker.io/bitnami/redis:7.2.3-debian-11-r2"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="./values.yaml#L875">redisMiscConfig.checkRedisIsUp.initContainer.maxAttempt</a></div></td>
    <td><div><code>60</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L143">hyperswitch-card-vault.external.postgresql.config.database</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L139">hyperswitch-card-vault.external.postgresql.config.host</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L142">hyperswitch-card-vault.external.postgresql.config.password</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L140">hyperswitch-card-vault.external.postgresql.config.port</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L141">hyperswitch-card-vault.external.postgresql.config.username</a></div></td>
    <td><div><code>null</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L137">hyperswitch-card-vault.external.postgresql.enabled</a></div></td>
    <td><div><code>false</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L150">hyperswitch-card-vault.initDB.checkPGisUp.image</a></div></td>
    <td><div><code>"postgres:16-alpine3.19"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L151">hyperswitch-card-vault.initDB.checkPGisUp.maxAttempt</a></div></td>
    <td><div><code>30</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L148">hyperswitch-card-vault.initDB.enable</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L153">hyperswitch-card-vault.initDB.migration.image</a></div></td>
    <td><div><code>"christophwurst/diesel-cli:latest"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L119">hyperswitch-card-vault.postgresql.enabled</a></div></td>
    <td><div><code>true</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L127">hyperswitch-card-vault.postgresql.global.postgresql.auth.architecture</a></div></td>
    <td><div><code>"standalone"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L126">hyperswitch-card-vault.postgresql.global.postgresql.auth.database</a></div></td>
    <td><div><code>"locker-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L125">hyperswitch-card-vault.postgresql.global.postgresql.auth.password</a></div></td>
    <td><div><code>"V2tkS1ptTkhSbnBqZDI4OUNnPT0K"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L124">hyperswitch-card-vault.postgresql.global.postgresql.auth.username</a></div></td>
    <td><div><code>"db_user"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L120">hyperswitch-card-vault.postgresql.nameOverride</a></div></td>
    <td><div><code>"locker-db"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L129">hyperswitch-card-vault.postgresql.primary.name</a></div></td>
    <td><div><code>""</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L133">hyperswitch-card-vault.postgresql.primary.resources.requests.cpu</a></div></td>
    <td><div><code>"100m"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L130">hyperswitch-card-vault.postgresql.primary.tolerations</a></div></td>
    <td><div><code>[]</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L38">hyperswitch-card-vault.server.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key</a></div></td>
    <td><div><code>"node-type"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L39">hyperswitch-card-vault.server.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator</a></div></td>
    <td><div><code>"In"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L41">hyperswitch-card-vault.server.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]</a></div></td>
    <td><div><code>"generic-compute"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L22">hyperswitch-card-vault.server.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L115">hyperswitch-card-vault.server.extra.env</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L25">hyperswitch-card-vault.server.image</a></div></td>
    <td><div><code>"juspaydotin/hyperswitch-card-vault:v0.4.0"</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L30">hyperswitch-card-vault.server.pod.annotations</a></div></td>
    <td><div><code>{}</code></div></td>
    <td></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L70">hyperswitch-card-vault.server.secrets.locker_private_key</a></div></td>
    <td><div><code>"-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----"</code></div></td>
    <td>To create this key pairs, follow the instructions provided here: </br> # Generating the private keys <pre>openssl genrsa -out locker-private-key.pem 2048</pre> <pre>openssl genrsa -out tenant-private-key.pem 2048</pre> # Generating the public keys </br> <pre>openssl rsa -in locker-private-key.pem -pubout -out locker-public-key.pem</pre> <pre>openssl rsa -in tenant-private-key.pem -pubout -out tenant-public-key.pem</pre> The private key for the locker from locker-private-key.pem</td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L58">hyperswitch-card-vault.server.secrets.master_key</a></div></td>
    <td><div><code>"master_key"</code></div></td>
    <td>Optionally, you can run </br> <pre>cargo install --git https://github.com/juspay/hyperswitch-card-vault --root . && ./bin/utils master-key && rm ./bin/utils && rmdir ./bin</pre></td>
  </tr><tr>
    <td><div><a href="../hyperswitch-card-vault/values.yaml#L101">hyperswitch-card-vault.server.secrets.tenant_public_key</a></div></td>
    <td><div><code>"-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----"</code></div></td>
    <td>The public key for the tenant from tenant-public-key.pem</td>
  </tr>
</tbody>
</table>

