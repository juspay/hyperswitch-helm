FROM node:14.21

ARG SDK_VERSION
# Install Python
RUN apt-get update && \
    apt-get install -y python3 python3-pip git
RUN git clone --branch v${SDK_VERSION} https://github.com/juspay/hyperswitch-web
WORKDIR /hyperswitch-web
RUN npm install
RUN npm run re:build
RUN npm run build:integ