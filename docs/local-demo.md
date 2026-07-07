# Local Demo

This guide is a lightweight way to prove the template renders, deploys, and exposes the sample workload in a local Kubernetes cluster.

## Prerequisites

- Docker
- kind
- kubectl
- helm

## Create A Cluster

```bash
kind create cluster --name kubernetes-devops-template
kubectl cluster-info --context kind-kubernetes-devops-template
```

## Deploy With Kustomize

```bash
kubectl apply -k k8s/overlays/dev
kubectl rollout status deployment/sample-app -n sample-app-dev
kubectl get deploy,svc,hpa,pdb,networkpolicy -n sample-app-dev
```

## Test The App

```bash
kubectl port-forward -n sample-app-dev svc/sample-app 8080:80
curl http://localhost:8080/healthz
curl http://localhost:8080/
```

Expected responses:

```text
ok
kubernetes-devops-template
```

## Deploy With Helm

```bash
make helm-template HELM_VALUES=charts/app/values-dev.yaml NAMESPACE=sample-app-dev
make helm-install HELM_VALUES=charts/app/values-dev.yaml NAMESPACE=sample-app-dev
```

## Clean Up

```bash
kubectl delete -k k8s/overlays/dev
kind delete cluster --name kubernetes-devops-template
```

NetworkPolicy enforcement depends on the cluster CNI. The default kind networking is useful for deployment smoke tests, but not for validating network isolation behavior.
