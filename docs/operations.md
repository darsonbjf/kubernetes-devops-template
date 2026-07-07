# Operations

## Render Before Applying

Always inspect generated manifests before applying changes:

```bash
kubectl kustomize k8s/overlays/dev
kubectl kustomize k8s/overlays/prod
helm template sample-app ./charts/app --namespace sample-app-prod
helm template sample-app ./charts/app --namespace sample-app-prod -f charts/app/values-prod.yaml
```

## Validate Changes

Run the full local validation helper:

```bash
make validate
```

Run strict validation, matching CI behavior:

```bash
STRICT_VALIDATION=true make validate
```

For policy-only checks:

```bash
make policy OVERLAY=prod
```

## Deployment

Kustomize:

```bash
kubectl apply -k k8s/overlays/dev
kubectl rollout status deployment/sample-app -n sample-app-dev
```

Helm:

```bash
helm upgrade --install sample-app ./charts/app \
  --namespace sample-app-prod \
  --create-namespace \
  -f charts/app/values-prod.yaml
```

Local smoke-test instructions are available in [local-demo.md](local-demo.md). After running the demo in a real cluster, record short outputs in [evidence.md](evidence.md).

## Useful Checks

```bash
kubectl get deploy,svc,ingress,hpa,pdb -n sample-app-prod
kubectl describe hpa sample-app -n sample-app-prod
kubectl describe networkpolicy -n sample-app-prod
kubectl logs deploy/sample-app -n sample-app-prod
```

## Production Review Checklist

- Image tags are immutable or `image.digest` is set for Helm deployments.
- Requests and limits come from load testing or real telemetry.
- HPA thresholds match application behavior.
- PDB still allows node maintenance and cluster upgrades.
- Ingress TLS secret exists and certificate renewal is automated.
- NetworkPolicy allow rules match actual dependencies.
- Secrets are managed by a dedicated secret workflow, not committed to Git.
- Dashboards and alerts exist for saturation, restarts, latency, and error rate.
