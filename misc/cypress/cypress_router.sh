cd cypress-tests

npm ci
psql --host=your-hypers-v1-postgresql-0-domain --username=hyperswitch --dbname=hyperswitch --command "\copy cards_info FROM '../.github/data/cards_info.csv' DELIMITER ',' CSV HEADER;"

export CYPRESS_CONNECTOR="stripe"
export CYPRESS_BASEURL="localhost:8080"
export DEBUG=cypress:cli  
export CYPRESS_ADMINAPIKEY="test_admin"
export CYPRESS_CONNECTOR_AUTH_FILE_PATH="creds.json"

npm run cypress:ci