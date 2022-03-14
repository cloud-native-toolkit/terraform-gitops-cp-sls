# Maximo Service License Suite Module

Module to populate a gitops repository with the SLS operator subscription and LicenseService(instance) for MAS. 

## Software dependencies

The module depends on the following software components:

### Terraform providers

- IBM Cloud provider >= 1.5.3
- Helm provider >= 1.1.1 (provided by Terraform)

## Module dependencies

This module makes use of the output from other modules:

- GitOps - github.com/cloud-native-toolkit/terraform-tools-gitops.git
- Namespace - github.com/cloud-native-toolkit/terraform-gitops-namespace.git
- Catalog - github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs.git
- MongoDB - github.com/cloud-native-toolkit/terraform-gitops-mongo-ce.git
- StorageClassManger - github.com/cloud-native-toolkit/terraform-util-storage-class-manager.git

## Example usage

```hcl-terraform
module "sls" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-cp-sls"
  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials

  server_name = module.gitops.server_name

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
  sls_storageClass = module.sc_manager.rwx_storage_class
  cluster_ingress = module.dev_cluster.platform.ingress
}
```

