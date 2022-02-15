module "cert" {
  depends_on = [module.gitops]
  source = "github.com/cloud-native-toolkit/terraform-util-sealed-secret-cert.git"

}
