
output "instance_name" {
  description = "The name of the module"
  value       = gitops_module.instance.name
}

output "operator_name" {
  description = "The name of the module"
  value       = gitops_module.subscription.name
}

output "branch" {
  description = "The branch where the module config has been placed"
  value       = gitops_module.instance.branch
}

output "namespace" {
  description = "The namespace where the module will be deployed"
  value       = gitops_module.instance.namespace
}

output "server_name" {
  description = "The server where the module will be deployed"
  value       = gitops_module.instance.server_name
}

output "layer" {
  description = "The layer where the module is deployed"
  value       = gitops_module.instance.layer
}

output "instance_type" {
  description = "The type of module where the module is deployed"
  value       = gitops_module.instance.type
}

output "operator_type" {
  description = "The type of module where the module is deployed"
  value       = gitops_module.subscription.type
}
