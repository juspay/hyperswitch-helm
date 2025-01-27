# To Run the CYPRESS test cases

Run all the services of the hyperswitch-helm repository as mentioned in the `README.md` file of the repository.

## In `hyperswitch-control-center`

1. Run the following command to start the hyperswitch control center test cases:
```sh cypress_hyperswitch_control_center.sh```

## In `hyperswitch-web`

1. `git clone https://github.com/juspay/hyperswitch-web.git`

2. `cd hyperswitch-web`

3. In the `cypress-tests/cypress.env.json` file update the keys correctly

4. In the `cypress-tests/cypress/support/utils.ts` update the profileId

5. In the `Hyperswitch-React-Demo-App/.env` update the profileId, keys, server and client urls

6. Make sure you have cypress installed in the system `npm install cypress --save-dev`

7. Run the following command to start the hyperswitch web test cases:
```sh cypress_web.sh```

## In `hyperswitch`

1. `git clone https://github.com/juspay/hyperswitch`

2. `cd hyperswitch`

3. Have the `creds.json` file in the `hyperswitch/cypress-tests` directory

4. Make sure you replace the the command in cypress_router.sh with the correct domain name of the postgresql service in the hyperswitch namespace.
``psql --host=your-hypers-v1-postgresql-0-domain --username=hyperswitch --dbname=hyperswitch --command "\copy cards_info FROM '../.github/data/cards_info.csv' DELIMITER ',' CSV HEADER;"``

5. Password
`ZGJwYXNzd29yZDEx`

6. Run the following command to start the hyperswitch test cases:
```sh cypress_router.sh```