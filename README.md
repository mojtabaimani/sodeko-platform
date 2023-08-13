# Sodeko Platform Services

This project is an internal developer platform that install core apps into an empty kubernetes cluster and makes it ready to deploy custom services. Then developers also can use this platform to deploy their services to different environments.

## Installation

You need to have kubectl and helm commands installed in your local environment then use these commands to install and configure argocd. Then argocd will pull the code from the repository and deploy apps to the cluster.

```bash
pipeline/scripts/install.sh <path to kubeconfig file> <Kubernetes context> <git repository token> <environment name>
```
assume we have two clusters: dta for dev,test,acceptance and prd for production. Then run these two commands:

dta:
```
pipeline/scripts/install.sh ~/.kube/minikube.yaml sodeko-dta <token> dta
```

production:
```
pipeline/scripts/install.sh ~/.kube/minikube.yaml sodeko-prd <token> prd
```
