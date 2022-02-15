
#module "dev_mongo_namespace" {
  #source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  #gitops_config = module.gitops.gitops_config
  #git_credentials = module.gitops.git_credentials
  #name = var.mongo_namespace
  #create_operator_group = false
#}


#resource null_resource write_mongo_namespace {
  #provisioner "local-exec" {
    #command = "echo '${var.mongo_namespace}' > ${path.cwd}/mongo_namespace"
  #}
#}