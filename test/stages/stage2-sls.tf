module "sls" {
  depends_on = [ null_resource.write_namespace ]
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  cluster_config_file = module.dev_cluster.config_file_path
  server_name = module.gitops.server_name
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  cluster_type = module.dev_cluster.platform.type_code
  tls_secret_name = module.dev_cluster.platform.tls_secret
  kubeseal_cert = module.gitops.sealed_secrets_cert
  catalog = module.cp_catalogs.catalog_ibmoperators
  namespace   = module.dev_namespace.name
  sls_key         = module.cp_catalogs.entitlement_key
  mongo_userid    = module.mongodb.username
  mongo_dbpass    = module.mongodb.password
  mongo_namespace = module.mongodb.namespace
  mongo_svcname   = module.mongodb.svcname
  mongo_cacrt     = module.mongodb.cacrt
  mongo_port      = module.mongodb.port
  sls_storageClass = var.rwm_storage_class
}
