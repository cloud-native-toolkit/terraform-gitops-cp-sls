module "dev_namespace" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = "ibm-sls"
}

resource null_resource write_namespace {
  provisioner "local-exec" {
    command = "echo -n '${module.dev_namespace.name}' > ${path.cwd}/.namespace"
  }
}
