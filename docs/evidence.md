# Evidence

This page records real command output after running the template locally. Keeping short evidence snapshots helps reviewers distinguish a runnable lab from static YAML.

## Validation

```bash
PATH="$PWD/.tmp/bin:$PWD/.tmp/venv/bin:$PATH" STRICT_VALIDATION=true ./scripts/validate.sh
```

Result from 2026-07-07:

```text
1 chart(s) linted, 0 chart(s) failed
Summary: 13 resources found in 1 file - Valid: 13, Invalid: 0, Errors: 0, Skipped: 0
Summary: 13 resources found in 1 file - Valid: 13, Invalid: 0, Errors: 0, Skipped: 0
Summary: 9 resources found in 1 file - Valid: 9, Invalid: 0, Errors: 0, Skipped: 0
Summary: 10 resources found in 1 file - Valid: 10, Invalid: 0, Errors: 0, Skipped: 0
Summary: 10 resources found in 1 file - Valid: 10, Invalid: 0, Errors: 0, Skipped: 0
156 tests, 156 passed, 0 warnings, 0 failures, 0 exceptions
108 tests, 108 passed, 0 warnings, 0 failures, 0 exceptions
120 tests, 120 passed, 0 warnings, 0 failures, 0 exceptions
120 tests, 120 passed, 0 warnings, 0 failures, 0 exceptions
156 tests, 156 passed, 0 warnings, 0 failures, 0 exceptions
validation completed
```

## Kustomize Render

```bash
kubectl kustomize k8s/overlays/dev
kubectl kustomize k8s/overlays/prod
```

Rendered object counts:

```text
k8s/overlays/dev   13 Kubernetes objects
k8s/overlays/prod  13 Kubernetes objects
```

Helm rendered object counts:

```text
default values             9 Kubernetes objects
charts/app/values-dev.yaml 10 Kubernetes objects
charts/app/values-prod.yaml 10 Kubernetes objects
```

## Runtime Smoke Test

```bash
kind create cluster --name kubernetes-devops-template
kubectl apply -k k8s/overlays/dev
kubectl rollout status deployment/sample-app -n sample-app-dev
kubectl get deploy,svc,hpa,pdb -n sample-app-dev
curl http://localhost:8080/healthz
curl http://localhost:8080/
```

Result from 2026-07-07:

```text
deployment "sample-app" successfully rolled out

NAME                         READY   UP-TO-DATE   AVAILABLE
deployment.apps/sample-app   1/1     1            1

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
service/sample-app   ClusterIP   10.96.192.169   <none>        80/TCP

NAME                                             REFERENCE               TARGETS
horizontalpodautoscaler.autoscaling/sample-app   Deployment/sample-app   cpu: <unknown>/70%, memory: <unknown>/80%

NAME                                    MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS
poddisruptionbudget.policy/sample-app   1               N/A               0

/healthz response: ok
/ response: kubernetes-devops-template
```

## GitOps

```bash
kubectl apply -f gitops/argocd/application-dev.yaml
kubectl apply -f gitops/argocd/application-prod.yaml
```

The Argo CD `Application` manifests are included as examples and point to the public repository URL. They were not applied during the local kind smoke test because Argo CD CRDs were not installed in that cluster.
