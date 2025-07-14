from email import header
from locust import HttpUser, TaskSet, SequentialTaskSet, task,  between
from uuid import uuid4 as u4
from random import choice
import json
import time
import os

'''
curl 'http://192.168.194.86/payments/pay_juk8r4trQIMHkQoyUaIO/confirm'
-X POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:120.0) Gecko/20100101 Firefox/120.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5'
-H 'Accept-Encoding: gzip, deflate' -H 'Referer: http://hyperswitch-schema-225681119357-us-east-2.s3.amazonaws.com/' -H 'Content-Type: application/json'
-H 'sdk-version: 0.5.6' -H 'api-key: pk_snd_21976dc3aea941c59e0ce*****'
-H 'Origin: http://hyperswitch-schema-225681119357-us-east-2.s3.amazonaws.com'
-H 'Connection: keep-alive'
--data-raw '{"client_secret":"pay_SyKOVP56WtiypInweMde_secret_lox6KduPNJDpUovYTzrW","return_url":"http://hyperswitch-sdk-970350076.us-east-2.elb.amazonaws.com"
,"payment_method":"card","payment_method_data":{"card":{"card_number":"4242424242424242","card_exp_month":"10","card_exp_year":"2025","card_holder_name":"","card_cvc":"123","card_issuer":"","card_network":"Visa"}}
,"browser_info":{"user_agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:120.0) Gecko/20100101 Firefox/120.0","accept_header":"text\\/html,application\\/xhtml+xml,application\\/xml;q=0.9,image\\/webp,image\\/apng,*\\/*;q=0.8"
,"language":"en-US","color_depth":30,"screen_height":1120,"screen_width":1792,"time_zone":-330,"java_enabled":True,"java_script_enabled":True}}'
'''

def merchant_account_create(client):
    payload = json.dumps({
        "merchant_id": f"merchant_{int(time.time())}",
        "locker_id": "m0010",
        "merchant_name": "NewAge Retailer",
        "merchant_details": {
            "primary_contact_person": "John Test",
            "primary_email": "JohnTest@test.com",
            "primary_phone": "sunt laborum",
            "secondary_contact_person": "John Test2",
            "secondary_email": "JohnTest2@test.com",
            "secondary_phone": "cillum do dolor id",
            "website": "https://www.example.com",
            "about_business": "Online Retail with a wide selection of organic products for North America",
            "address": {
            "line1": "1467",
            "line2": "Harrison Street",
            "line3": "Harrison Street",
            "city": "San Fransico",
            "state": "California",
            "zip": "94122",
            "country": "US",
            "first_name":"john",
            "last_name":"Doe"
            }
        },
        "return_url": "https://google.com/success",
        "webhook_details": {
            "webhook_version": "1.0.1",
            "webhook_username": "ekart_retail",
            "webhook_password": "password_ekart@123",
            "webhook_url":"https://webhook.site",
            "payment_created_enabled": True,
            "payment_succeeded_enabled": True,
            "payment_failed_enabled": True
        },
        "sub_merchants_enabled": False,
        "parent_merchant_id":"merchant_123",
        "metadata": {
            "city": "NY",
            "unit": "245"
        },
        "primary_business_details": [
            {
            "country": "US",
            "business": "default"
            }
        ]
    })
    response = client.post('/accounts', data=payload, 
                            headers={
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                            'api-key': 'test_admin'})
    merchant_id = json.loads(response.text)["merchant_id"]
    return merchant_id

def api_key_create(client, m_id):
    payload = json.dumps({
        "name": "API Key 1",
        "description": None,
        "expiration": "2038-01-19T03:14:08.000Z",
    })
    merchant_id = m_id
    response = client.post('/api_keys/'+merchant_id, data=payload, 
                                    headers = {
                                        'Content-Type': 'application/json',
                                        'Accept': 'application/json',
                                        'api-key': 'test_admin'})
    api_key = json.loads(response.text)["api_key"]
    return api_key

def get_api_key_from_env():
    return os.getenv('CONNECTOR_API_KEY')

def connector_create(client): 
    api_key_from_env = get_api_key_from_env()

    payload = json.dumps({
         "connector_type": "payment_processor",
        "connector_name": "stripe",
        "connector_account_details": {
            "auth_type": "HeaderKey",
            "api_key": api_key_from_env
        },
        "test_mode": True,
        "disabled": False,
        "payment_methods_enabled": [
            {
                "payment_method": "card",
                "payment_method_types": [
                    {
                        "payment_method_type": "credit",
                        "card_networks": [
                            "Visa",
                            "Mastercard"
                        ],
                        "minimum_amount": 1,
                        "maximum_amount": 68607706,
                        "recurring_enabled": True,
                        "installment_payment_enabled": True,
                        "accepted_countries": {
                            "type": "disable_only",
                            "list": [
                                "HK"
                            ]
                        },
                        "accepted_currencies": {
                            "type": "enable_only",
                            "list": [
                                "USD",
                                "GBP",
                                "INR"
                            ]
                        }
                    },
                    {
                        "payment_method_type": "debit",
                        "card_networks": [
                            "Visa",
                            "Mastercard"
                        ],
                        "minimum_amount": 1,
                        "maximum_amount": 68607706,
                        "recurring_enabled": True,
                        "installment_payment_enabled": True,
                        "accepted_countries": {
                            "type": "disable_only",
                            "list": [
                                "HK"
                            ]
                        },
                        "accepted_currencies": {
                            "type": "enable_only",
                            "list": [
                                "USD",
                                "GBP",
                                "INR"
                            ]
                        }
                    }
                ]
            },
            {
                "payment_method": "pay_later",
                "payment_method_types": [
                    {
                        "payment_method_type": "klarna",
                        "payment_experience": "redirect_to_url",
                        "minimum_amount": 1,
                        "maximum_amount": 68607706,
                        "recurring_enabled": True,
                        "installment_payment_enabled": True
                    },
                    {
                        "payment_method_type": "affirm",
                        "payment_experience": "redirect_to_url",
                        "minimum_amount": 1,
                        "maximum_amount": 68607706,
                        "recurring_enabled": True,
                        "installment_payment_enabled": True
                    },
                    {
                        "payment_method_type": "afterpay_clearpay",
                        "payment_experience": "redirect_to_url",
                        "minimum_amount": 1,
                        "maximum_amount": 68607706,
                        "recurring_enabled": True,
                        "installment_payment_enabled": True
                    }
                ]
            }
        ],
        "metadata": {
            "city": "NY",
            "unit": "245"
        },
        "connector_webhook_details": {
            "merchant_secret": "MyWebhookSecret"
        },
        "business_country": "US",
        "business_label": "default"
    })
    response = client.post('/account/'+merchant_id+'/connectors', data=payload,
                            headers = {
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                                'api-key': 'test_admin'})




class UserBehavior(SequentialTaskSet):
    payment_id = ""
    @task(1)
    def stripe(self):
        payload = json.dumps({
    "amount": 6540,
    "currency": "USD",
    "confirm": False,
    # "business_country":"US",
    # "business_label":"default",
    "capture_method": "automatic",
    "capture_on": "2022-09-10T10:11:12Z",
    "amount_to_capture": 6540,
    "customer_id": "StripeCustomer",
    "email": "guest@example.com",
    "name": "John Doe",
    "phone": "999999999",
    "phone_country_code": "+65",
    "description": "Its my first payment request",
    "authentication_type": "no_three_ds",
    "return_url": "https://duck.com",
     "billing": {
        "address": {
            "line1": "1467",
            "line2": "Harrison Street",
            "line3": "Harrison Street",
            "city": "San Fransico",
            "state": "California",
            "zip": "94122",
            "country": "US",
            "first_name": "PiX",
            "last_name": "Pix",
        }
    },
    "shipping": {
        "address": {
            "line1": "1467",
            "line2": "Harrison Street",
            "line3": "Harrison Street",
            "city": "San Fransico",
            "state": "California",
            "zip": "94122",
            "country": "US",
            "first_name": "PiX"
        }
    },
    "statement_descriptor_name": "joseph",
    "statement_descriptor_suffix": "JS",
    "metadata": {
        "udf1": "value1",
        "new_customer": "True",
        "login_date": "2019-09-10T10:11:12Z"
    }
})
        response = self.client.post('/payments', data=payload,
                         headers={
                             'Content-Type': 'application/json',
                             'Accept': 'application/json',
                            #'x-feature' : 'router-custom'
                            'api-key' : api_key #c3
                         })

        self.payment_id = json.loads(response.text)["payment_id"]
        print(json.loads(response.text))
        print(self.payment_id)


    @task(1)
    def confimr(self):
        payload = json.dumps({"payment_method": "card",
    "payment_method_type": "credit",
    # "setup_future_usage": "on_session",
    # "connector":["stripe_test"],
    # "payment_method_data": {
    #     "card": {
    #       "card_number": "4200000000000000",
    #       "card_exp_month": "10",
    #       "card_exp_year": "25",
    #       "card_holder_name": "joseph Doe",
    #       "card_cvc": "123"
    #     }
    #   },
    "payment_method_data": {
        "card": {
            "card_number": "4242424242424242",
            "card_exp_month": "10",
            "card_exp_year": "25",
            "card_holder_name": "joseph Doe",
            "card_cvc": "123"
        }
    },
    "browser_info": {
        "user_agent": "Mozilla\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/70.0.3538.110 Safari\/537.36",
        "accept_header": "text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/webp,image\/apng,*\/*;q=0.8",
        "language": "nl-NL",
        "color_depth": 24,
        "screen_height": 723,
        "screen_width": 1536,
        "time_zone": 0,
        "java_enabled": True,
        "java_script_enabled": True,
        "ip_address": "125.0.0.1"
    }})
                
        response = self.client.post('/payments/'+self.payment_id+'/confirm', name='/payments/payment_id/confirm', data=payload,
                         headers={
                             'Content-Type': 'application/json',
                             'Accept': 'application/json',
                            #'x-feature' : 'router-custom'
                            'api-key' : api_key,
                            'x-hs-latency' : 'True'
                         })
        print(response.headers.get('x-hs-latency'))
        print(json.loads(response.text))


class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    def on_start(self):
        global merchant_id, api_key
        merchant_id = merchant_account_create(self.client)
        api_key = api_key_create(self.client, merchant_id)
        connector_create(self.client)
    wait_time = between(0, 2)
    #host = 'https://api.hyperswitch.io'
    # host = 'https://api.hyperswitch.io'
    # http://hyperswitch-1615156337.us-west-2.elb.amazonaws.com