
resource "time_sleep" "wait_30_seconds2" {
  depends_on = [module.gitops]

  create_duration = "30s"
}
module "dev_mongo_namespace" {
  depends_on = [ time_sleep.wait_30_seconds2 ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git?ref=provider"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = var.mongo_namespace
  create_operator_group = false
}




resource null_resource write_mongo_namespace {
  provisioner "local-exec" {
    command = "echo '${var.mongo_namespace}' > ${path.cwd}/mongo_namespace"
  }
}
