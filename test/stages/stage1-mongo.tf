
resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.dev_mongo_namespace]

  create_duration = "30s"
}

module "mongo-operator" {
  depends_on = [time_sleep.wait_30_seconds]
  source = "github.com/cloud-native-toolkit/terraform-gitops-mongo-ce-operator?ref=var-ref-cleanup"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.dev_mongo_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  mongo_storageclass ="ibmc-vpc-block-10iops-tier"
}

module "mongodb" {
  depends_on = [time_sleep.wait_30_seconds]
  source = "github.com/cloud-native-toolkit/terraform-gitops-mongo-ce"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.mongo-operator.namespace
  kubeseal_cert = module.gitops.sealed_secrets_cert
  storage_class_name = "ibmc-vpc-block-10iops-tier"
}
