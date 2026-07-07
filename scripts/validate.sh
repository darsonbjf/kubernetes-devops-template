#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="${ROOT_DIR}/.tmp"
STRICT_VALIDATION="${STRICT_VALIDATION:-false}"

has_command() {
  command -v "$1" >/dev/null 2>&1
}

skip() {
  printf 'skip: %s\n' "$1"
}

require_or_skip() {
  local command_name="$1"
  local message="$2"

  if has_command "${command_name}"; then
    return 0
  fi

  if [ "${STRICT_VALIDATION}" = "true" ]; then
    printf 'error: %s\n' "${message}" >&2
    exit 1
  fi

  skip "${message}"
  return 1
}

mkdir -p "${TMP_DIR}"

cd "${ROOT_DIR}"

if require_or_skip yamllint "yamllint is not installed"; then
  yamllint .
fi

if require_or_skip kubectl "kubectl is not installed; skipping Kustomize rendering"; then
  for overlay in dev prod; do
    kubectl kustomize "k8s/overlays/${overlay}" > "${TMP_DIR}/${overlay}.yaml"
  done
fi

if require_or_skip helm "helm is not installed; skipping Helm validation"; then
  helm lint ./charts/app
  helm template sample-app ./charts/app --namespace sample-app-dev > "${TMP_DIR}/helm.yaml"
fi

if require_or_skip kubeconform "kubeconform is not installed"; then
  for file in "${TMP_DIR}"/*.yaml; do
    [ -e "${file}" ] || continue
    kubeconform -strict -summary -ignore-missing-schemas "${file}"
  done
fi

if require_or_skip conftest "conftest is not installed"; then
  for file in "${TMP_DIR}"/*.yaml; do
    [ -e "${file}" ] || continue
    conftest test "${file}" --policy policies/conftest
  done
fi

printf 'validation completed\n'
