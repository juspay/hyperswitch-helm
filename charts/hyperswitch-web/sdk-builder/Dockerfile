# Stage 1: Build the assets
FROM node:lts AS builder

# Set the build environment as an argument
ARG sdkEnv=sandbox
ARG sdkVersion=main
RUN if [ "$sdkVersion" != "main" ]; then gitBranch="v$sdkVersion"; else gitBranch="$sdkVersion"; fi && \
    git clone --branch ${gitBranch} https://github.com/juspay/hyperswitch-web --depth 1 /app

# Set the working directory to the cloned repository
WORKDIR /app

ENV ENV_BACKEND_URL=https://beta.hyperswitch.io/api
# Install dependencies and build the project
RUN npm_config_ignore_scripts=true npm install
RUN npm run re:build
RUN npm run build:sandbox
# Stage 2: Serve the built assets
FROM nginx:alpine

# Set working directory and copy the built assets from the builder stage
WORKDIR /usr/share/nginx/html
ARG sdkVersion
ARG port=80
ARG nginxPath=/usr/share/nginx/html/web/$sdkVersion
COPY --from=builder /app/dist/sandbox $nginxPath
WORKDIR $nginxPath/v1

# Add the embedded entrypoint script
RUN printf '%s\n' \
'#!/bin/sh' \
'echo "Starting build modifications..."' \
'if [ -n "$envSdkUrl" ]; then' \
'  sed -i -e "s|https://beta.hyperswitch.io/web|${envSdkUrl}/web|g" app.js HyperLoader.js' \
'fi' \
'if [ -n "$envBackendUrl" ]; then' \
'  sed -i -e "s|https://beta.hyperswitch.io/api|${envBackendUrl}|g" app.js HyperLoader.js' \
'fi' \
'if [ -n "$envLogsUrl" ]; then' \
'  sed -i -e "s|https://sandbox.hyperswitch.io/logs/sdk|${envLogsUrl}|g" app.js HyperLoader.js' \
'fi' \
'echo "Build modifications completed."' \
'exec "$@"' \
> /docker-entrypoint.d/change_urls.sh && chmod +x /docker-entrypoint.d/change_urls.sh


# Use the embedded entrypoint script and run Nginx
CMD ["nginx", "-g", "daemon off;"]