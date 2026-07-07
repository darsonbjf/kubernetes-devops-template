OVERLAY ?= dev
RELEASE ?= sample-app
NAMESPACE ?= sample-app-dev
HELM_VALUES ?= charts/app/values-dev.yaml

.PHONY: render diff apply delete helm-template helm-install helm-lint validate validate-strict policy clean

render:
	kubectl kustomize k8s/overlays/$(OVERLAY)

diff:
	kubectl diff -k k8s/overlays/$(OVERLAY)

apply:
	kubectl apply -k k8s/overlays/$(OVERLAY)

delete:
	kubectl delete -k k8s/overlays/$(OVERLAY)

helm-template:
	helm template $(RELEASE) ./charts/app --namespace $(NAMESPACE) -f $(HELM_VALUES)

helm-install:
	helm upgrade --install $(RELEASE) ./charts/app --namespace $(NAMESPACE) --create-namespace -f $(HELM_VALUES)

helm-lint:
	helm lint ./charts/app

validate:
	./scripts/validate.sh

validate-strict:
	STRICT_VALIDATION=true ./scripts/validate.sh

policy:
	mkdir -p .tmp
	kubectl kustomize k8s/overlays/$(OVERLAY) > .tmp/$(OVERLAY).yaml
	conftest test .tmp/$(OVERLAY).yaml --policy policies/conftest

clean:
	rm -rf .tmp
