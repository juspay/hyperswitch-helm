### Build Hyperloader.js
Whenever we try to host Hyperloader.js for new version, we need to build asset. The Docker file in this folder can be used to build the image in local and publish it to Hyperswitch dockerhub for open-source users to use it directly changing their domain names using helm chart and host it on their cloud.


```
Start local docker
cd hyperswitch-helm/charts/incubator/hyperswitch-sdk/sdk-builder
docker build --build-arg sdkVersion=<0.35.4> --platform=linux/amd64 -t hyperswitch-web .
docker tag hyperswitch-web <user>/hyperswitch-web:<0.35.4>
docker push <user>/hyperswitch-web:<0.35.4>
```