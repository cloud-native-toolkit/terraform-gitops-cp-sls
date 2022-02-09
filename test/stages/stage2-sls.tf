module "gitops_module" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  cluster_config_file = module.dev_cluster.config_file_path
  server_name = module.gitops.server_name
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  kubeseal_cert = module.gitops.sealed_secrets_cert
  catalog = module.cp_catalogs.catalog_ibmoperators
  namespace   = module.dev_namespace.name
  sls_key         = var.sls_key
  mongo_dbpass    = module.dev_mongo.mongo_pw
  mongo_namespace = module.dev_mongo.mongo_namespace
  mongo_svcname   = module.dev_mongo.mongo_servicename
  
}
