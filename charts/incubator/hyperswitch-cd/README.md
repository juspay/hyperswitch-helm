# Implement CD Pipeline Using Argo: Proposal

This proposal attemps to implement CD pipeline to automate the deployment process using Argo.

##  Folder Tree

- The proposed setup contains a `hyperstack-cd` folder at `charts/incubator` level so as to achieve a proper structure and readiness.

- There is an argo config file built for each workload with the naming convention `{app_name}-argo-application.yml` which ofcourse can be automated through workflows.
- The tree layout would look like:

```text
.
├── charts/incubator
│   ├── hyperswitch-app
│   ├── hyperswitch-card-vault
│   ├── hyperswitch-cd
│   │   ├── {app_name}-argo-application.yml
│   ├── hyperswitch-sdk
│   ├── hyperswitch-stack
|── repo 
```

##  How It Works

- A workflow is created to deploy applications to reduce any human interventions.
- Simply run the `ArgoCD-Deploy` workflow from the GitHub Actions mentioning the application name that needs to be deployed.
- As of now, the configurations are done based on my local cluster configuration. 


##  Getting Started

Inside the cluster, following steps have to be performed in order to install argocd cli and argocd API Server:

- Install `kubectl` command line tool. [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- Have a `kubeconfig` file (default location is ~/.kube/config).
- Install ArgoCD.
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
- Configuration of the certificates for the TLS endpoints is required explicitly.
- Install the ArgoCD CLI. For MacOS, it is
```
brew install argocd
````
- Change the argocd-server service type to LoadBalancer:
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
- Port Forwarding.
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

The ArgoCD API Server can then be accessed at https://localhost:8080

##  Achievements

- I was able to deploy the applications in my local setup using Argo.
- However, I was using an AMD64 based machine and the image is built using ARM architecture. Due to the same reason, pods were not coming up. Getting `exec /bin/sh: exec format error` in ArgoCD logs.

## What's Next

- This setup can be leveraged to achieve environment specific configurations by having respective branches e.g. dev, stg and prod.
- Pipelines can be setup to build argocd config files from one env to other.
