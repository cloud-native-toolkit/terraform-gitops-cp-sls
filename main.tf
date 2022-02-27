locals {
  name          ="ibm-sls-operator"
  chart_name01  ="ibm-sls-operator-subscription"
  chart_name02  ="ibm-sls-operator-instance"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir01      = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_name01}/"
  yaml_dir02      = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_name02}/"
  ingress_host  = "${local.name}-${var.namespace}.${var.cluster_ingress_hostname}"
  ingress_url   = "https://${local.ingress_host}"
  service_url   = "http://${local.name}.${var.namespace}"
  values_content01 = {
    subscriptions = {
        ibmsls = {
          name = "ibm-sls-operator-subscription"
          subscription = {
            channel = var.channel
            installPlanApproval = "Automatic"
            name = "ibm-sls"
            source = var.catalog
            sourceNamespace = var.catalog_namespace
          }
        }
      }
    }
  layer = "services"
  type = "base"
  application_branch = "main"
  values_file = "values.yaml"
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml01 {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml01.sh '${local.chart_name01}' '${local.yaml_dir01}' "
    environment = {
      VALUES_CONTENT01 = yamlencode(local.values_content01)
      
    }
  }
}

resource null_resource create_yaml02 {
  depends_on = [null_resource.create_yaml01]
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml02.sh '${local.ingress_host}' '${var.namespace}' '${var.sls_storageClass}' '${var.mongo_namespace}' '${var.mongo_svcname}' '${local.chart_name02}' '${var.mongo_port}' '${local.yaml_dir02}'"

    environment = {

      CA_CRT = var.mongo_cacrt
    }
  }
}

resource gitops_module subscription {
  depends_on = [null_resource.create_yaml01, gitops_module.instance]

  name        = local.chart_name01
  namespace   = var.namespace
  content_dir = local.yaml_dir01
  server_name = var.server_name
  layer       = local.layer
  type        = "instances"
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

resource gitops_module instance {
  depends_on = [null_resource.create_yaml02]

  name        = local.chart_name02
  namespace   = var.namespace
  content_dir = local.yaml_dir02
  server_name = var.server_name
  layer       = local.layer
  type        = "operators"
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
