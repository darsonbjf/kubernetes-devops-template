# Evidence

Use this page to record real command output after running the template in a cluster. Keeping short evidence snapshots helps reviewers distinguish a runnable lab from static YAML.

## Validation

```bash
STRICT_VALIDATION=true make validate
```

Paste a successful CI or local validation summary here.

## Kustomize Render

```bash
kubectl kustomize k8s/overlays/prod
```

Capture the rendered object count or a short manifest excerpt here.

## Runtime Smoke Test

```bash
kubectl rollout status deployment/sample-app -n sample-app-dev
kubectl get deploy,svc,hpa,pdb -n sample-app-dev
curl http://localhost:8080/healthz
```

Expected health response:

```text
ok
```

## GitOps

```bash
kubectl get applications.argoproj.io -n argocd
```

Capture Argo CD sync and health status after applying the sample `Application` manifests.
