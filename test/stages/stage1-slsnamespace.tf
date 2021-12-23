module "dev_sls_namespace" {
  source = "github.com/ibm-garage-cloud/terraform-cluster-namespace?ref=v3.1.2"

  cluster_config_file_path = module.dev_cluster.config_file_path
  name                     = var.sls_namespace
  create_operator_group    = true
}


resource null_resource write_namespace {
  provisioner "local-exec" {
    command = "echo '${var.sls_namespace}' > ${path.cwd}/sls_namespace"
  }
}
