package main

import rego.v1

containers contains container if {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
}

deny contains msg if {
  container := containers[_]
  not image_has_tag_or_digest(container.image)
  msg := sprintf("%s/%s container %s must use an explicit image tag or digest", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  container := containers[_]
  endswith(container.image, ":latest")
  msg := sprintf("%s/%s container %s must not use the latest tag", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  container := containers[_]
  not container.resources.requests.cpu
  msg := sprintf("%s/%s container %s must set cpu requests", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  container := containers[_]
  not container.resources.requests.memory
  msg := sprintf("%s/%s container %s must set memory requests", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  container := containers[_]
  not container.resources.limits.cpu
  msg := sprintf("%s/%s container %s must set cpu limits", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  container := containers[_]
  not container.resources.limits.memory
  msg := sprintf("%s/%s container %s must set memory limits", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  input.kind == "Deployment"
  not input.spec.template.spec.securityContext.runAsNonRoot
  msg := sprintf("%s/%s must set pod securityContext.runAsNonRoot=true", [input.kind, input.metadata.name])
}

deny contains msg if {
  container := containers[_]
  not container.securityContext.runAsNonRoot
  msg := sprintf("%s/%s container %s must set runAsNonRoot=true", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  container := containers[_]
  not container.securityContext.readOnlyRootFilesystem
  msg := sprintf("%s/%s container %s must use a read-only root filesystem", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  container := containers[_]
  not container.securityContext.allowPrivilegeEscalation == false
  msg := sprintf("%s/%s container %s must disable privilege escalation", [input.kind, input.metadata.name, container.name])
}

deny contains msg if {
  container := containers[_]
  not contains_value(container.securityContext.capabilities.drop, "ALL")
  msg := sprintf("%s/%s container %s must drop all Linux capabilities", [input.kind, input.metadata.name, container.name])
}

image_has_tag_or_digest(image) if {
  contains(image, "@sha256:")
}

image_has_tag_or_digest(image) if {
  image_name := image_last_segment(image)
  contains(image_name, ":")
}

image_last_segment(image) := name if {
  parts := split(image, "/")
  name := parts[count(parts) - 1]
}

contains_value(values, expected) if {
  values[_] == expected
}
