
module "mongo-operator" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-mongo-ce-operator?ref=provider"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.dev_mongo_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
}

module "mongodb" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-mongo-ce"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.mongo-operator.namespace
  kubeseal_cert = module.gitops.sealed_secrets_cert
  storage_class_name = var.storageclass
}
