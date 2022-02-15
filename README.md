# Maximo Service License Suite Module

Module to populate a gitops repository with the SLS operator subscription and LicenseService(instance) for MAS. 

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v12
- kubectl

### Terraform providers

- IBM Cloud provider >= 1.5.3
- Helm provider >= 1.1.1 (provided by Terraform)

## Module dependencies

This module makes use of the output from other modules:

- Argocd Bootstrap - github.com/cloud-native-toolkit/terraform-tools-argocd-bootstrap.git
- GitOps - github.com/cloud-native-toolkit/terraform-tools-gitops.git
- Cluster - github.com/cloud-native-toolkit/terraform-ibm-ocp-vpc.git
- Namespace - github.com/cloud-native-toolkit/terraform-gitops-namespace.git
- Catalog - github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs.git
- MongoDB
https://github.com/cloud-native-toolkit/terraform-gitops-mongo-ce

## Example usage

```hcl-terraform
module "sls" {
  source = "https://github.com/cloud-native-toolkit/terraform-gitops-cp-sls"
  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  cluster_config_file = module.dev_cluster.config_file_path
  server_name = module.gitops.server_name
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  cluster_type = module.dev_cluster.platform.type_code
  tls_secret_name = module.dev_cluster.platform.tls_secret
  kubeseal_cert = module.argocd-bootstrap.sealed_secrets_cert
  catalog = module.cp_catalogs.catalog_ibmoperators
  namespace   = module.dev_namespace.name
  sls_key         = var.sls_key
  mongo_dbpass    = module.dev_mongo.mongo_pw
  mongo_namespace = module.dev_mongo.mongo_namespace
  mongo_svcname   = module.dev_mongo.mongo_servicename
}
```

