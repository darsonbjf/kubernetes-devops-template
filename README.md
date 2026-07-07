# Kubernetes DevOps Template

[![Validate Kubernetes Template](https://github.com/darsonbjf/kubernetes-devops-template/actions/workflows/validate.yaml/badge.svg)](https://github.com/darsonbjf/kubernetes-devops-template/actions/workflows/validate.yaml)

Production-minded Kubernetes application template for portfolio, demos, and real project bootstrapping.

This repository shows how to package and operate a small web workload with common DevOps practices:

- Declarative manifests with Kustomize base and environment overlays.
- Helm chart with configurable security, scaling, ingress, and network policy settings.
- Restricted pod security posture: non-root user, read-only root filesystem, dropped Linux capabilities, and RuntimeDefault seccomp.
- Reliability controls: readiness, liveness, startup probes, rolling updates, HorizontalPodAutoscaler, and PodDisruptionBudget.
- Namespace governance: Pod Security Admission labels, ResourceQuota, and LimitRange.
- Network isolation: default-deny NetworkPolicy with explicit ingress and egress allow rules.
- GitOps examples for Argo CD.
- CI-ready validation with yamllint, kubeconform, helm lint, and Conftest policy checks.
- Optional examples for External Secrets and Prometheus Operator integrations.

## Repository Layout

```text
.
├── charts/app                 # Helm chart for the same sample app
│   ├── values-dev.yaml         # Helm values for development
│   └── values-prod.yaml        # Helm values for production
├── docs                       # Architecture, operations, and references
├── examples                   # Optional CRD-based integrations
├── gitops/argocd              # Argo CD Application examples
├── k8s/base                   # Reusable Kubernetes manifests
├── k8s/overlays/dev           # Development customization
├── k8s/overlays/prod          # Production customization
├── policies/conftest          # Policy-as-code checks
└── scripts/validate.sh        # Local validation helper
```

## Quick Start

Render the development overlay:

```bash
make render OVERLAY=dev
```

Render the production overlay:

```bash
make render OVERLAY=prod
```

Validate everything that can be validated with local tooling:

```bash
make validate
```

Require all validation tools to be installed and fail when one is missing:

```bash
STRICT_VALIDATION=true make validate
```

Apply an overlay to a cluster:

```bash
kubectl apply -k k8s/overlays/dev
```

Install with Helm:

```bash
make helm-install HELM_VALUES=charts/app/values-dev.yaml NAMESPACE=sample-app-dev
```

Run a local smoke test with kind:

```bash
kind create cluster --name kubernetes-devops-template
kubectl apply -k k8s/overlays/dev
kubectl rollout status deployment/sample-app -n sample-app-dev
```

## Tooling

Recommended local tools:

- kubectl
- helm
- yamllint
- kubeconform
- conftest
- pre-commit
- kind, for the optional local demo

By default, the validation script skips missing optional tools and prints what was skipped, so the repository remains easy to inspect on a fresh workstation. CI runs with `STRICT_VALIDATION=true` and fails if any required validator is unavailable.

## Notes For Reuse

- Replace the demo image with your application image and use immutable tags or set `image.digest` in production.
- Do not commit raw secrets. Use External Secrets, Sealed Secrets, SOPS, or your platform secret manager.
- Review NetworkPolicy rules for your CNI plugin and application dependencies.
- Tune requests, limits, HPA thresholds, and PDB values with production metrics.
- Enable the ServiceMonitor example only after your application exposes Prometheus-format metrics.
- Update Argo CD `repoURL` values after publishing the repository.

## Documentation

- [Architecture](docs/architecture.md)
- [Operations](docs/operations.md)
- [Local demo](docs/local-demo.md)
- [Evidence template](docs/evidence.md)
- [References](docs/references.md)

## License

This project is released under the [MIT License](LICENSE).
