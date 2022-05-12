module "sls" {
  depends_on = [module.jetstack-cert]
  
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials

  server_name = module.gitops.server_name

  kubeseal_cert = module.gitops.sealed_secrets_cert
  catalog = module.cp_catalogs.catalog_ibmoperators
  namespace   = module.dev_namespace.name
  mongo_userid    = module.mongodb.username
  mongo_dbpass    = module.mongodb.password
  mongo_namespace = module.mongodb.namespace
  mongo_svcname   = module.mongodb.svcname
  mongo_port      = module.mongodb.port
  cluster_ingress = module.dev_cluster.platform.ingress
  entitlement_key  = module.cp_catalogs.entitlement_key
  
}

