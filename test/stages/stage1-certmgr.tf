// Only uncomment this IF you are installing on a cluster that does NOT have ibm-cert manager installed from previous cloudpak work
/*module "jetstack-cert" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-ocp-cert-manager.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
}*/