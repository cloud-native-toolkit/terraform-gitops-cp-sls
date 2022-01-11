module "sls" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  cluster_type = module.dev_cluster.platform.type_code
  tls_secret_name = module.dev_cluster.platform.tls_secret
  kubeseal_cert = module.argocd-bootstrap.sealed_secrets_cert
  catalog = module.cp_catalogs.catalog_ibmoperators
  sls_namespace   = module.dev_sls_namespace.name
  sls_key         = var.sls_key
  mongo_dbpass    = module.dev_mongo.mongo_pw
  mongo_namespace = module.dev_mongo.mongo_namespace
  mongo_svcname   = module.dev_mongo.mongo_servicename
  
}