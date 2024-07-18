FROM node:lts

ARG SDK_VERSION
# Install Python
RUN git clone --branch v${SDK_VERSION} https://github.com/juspay/hyperswitch-web
WORKDIR hyperswitch-web
RUN npm install
RUN npm run re:build
RUN npm run build:integ