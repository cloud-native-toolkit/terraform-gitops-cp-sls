module "dev_mongo" {
  source = "github.com/cloud-native-toolkit/terraform-ocp-mongodb"

  cluster_config_file      = module.dev_cluster.config_file_path
  cluster_type             = module.dev_cluster.platform.type_code
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  tls_secret_name          = module.dev_cluster.platform.tls_secret
  
  mongo_namespace    = module.dev_mongo_namespace.name

}
