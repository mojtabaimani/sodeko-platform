#!/bin/bash

KUBECONFIG=$1           # example: /home/ubuntu/.kube/config
CONTEXT=$2              # example: kubernetes-admin@kubernetes
REPOSITORY_TOKEN=$3     # example: 1234567890qpoieraksjdhzxcbv
ENVIRONMENT=$4          # example: dev, tst, acc, prd


# create namespace
NAMESPACE=argocd
kubectl create namespace $NAMESPACE --context $CONTEXT --dry-run=client -o yaml | kubectl apply --context $CONTEXT -f -

# create secret for repository
kubectl create secret generic repo-green-services --context $CONTEXT -n $NAMESPACE \
  --from-literal=name=green-services \
  --from-literal=username=x \
  --from-literal=password=$REPOSITORY_TOKEN \
  --from-literal=url=https://github.com/mojtabaimani/sodeko-green-services.git \
  --from-literal=type=git \
  --dry-run=client -o yaml | kubectl apply --context $CONTEXT -n $NAMESPACE -f -
kubectl label secret repo-green-services argocd.argoproj.io/secret-type=repository --context $CONTEXT -n $NAMESPACE

kubectl create secret generic repo-platform-tools --context $CONTEXT -n $NAMESPACE \
  --from-literal=name=platform-tools \
  --from-literal=username=x \
  --from-literal=password=$REPOSITORY_TOKEN \
  --from-literal=url=https://github.com/mojtabaimani/sodeko-platform-tools.git \
  --from-literal=type=git \
  --dry-run=client -o yaml | kubectl apply --context $CONTEXT -n $NAMESPACE -f -
kubectl label secret repo-platform-tools argocd.argoproj.io/secret-type=repository --context $CONTEXT -n $NAMESPACE

# install argocd using helm
PROJECT_NAME=project-$ENVIRONMENT
VALUES_FILE=app-values/argocd/argocd-values-$ENVIRONMENT.yaml
helm repo add argocd https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install --kube-context $CONTEXT -n $NAMESPACE -f $VALUES_FILE argocd argocd/argo-cd --version 5.42.2 --wait


# add project to the argocd server using yaml file
cat <<EOF | kubectl apply --context $CONTEXT -n $NAMESPACE -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: $PROJECT_NAME
  namespace: $NAMESPACE
  # Finalizer that ensures that project is not deleted until it is not referenced by any application
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  sourceRepos:
  - '*'
  destinations:
  - name: '*'
    namespace: '*'
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
EOF

# add app of the apps to the argocd server using yaml file
kubectl apply --context $CONTEXT -n $NAMESPACE -f pipeline/argocd/app-of-apps-$ENVIRONMENT.yaml
