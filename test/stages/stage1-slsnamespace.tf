resource "time_sleep" "wait_30_seconds3" {
  depends_on = [ module.dev_mongo_namespace ]

  create_duration = "30s"
}
module "dev_namespace" {
  depends_on = [ time_sleep.wait_30_seconds3 ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = var.namespace
}

resource null_resource write_namespace {
  provisioner "local-exec" {
    command = "echo -n '${module.dev_namespace.name}' > ${path.cwd}/.namespace"
  }
}
