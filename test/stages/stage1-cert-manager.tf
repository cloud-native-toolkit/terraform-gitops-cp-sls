module "certmgr" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-ocp-cert-manager"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
}
