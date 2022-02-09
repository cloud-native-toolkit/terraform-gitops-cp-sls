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
  application_branch = "main"
  instance_type = "base"
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
    command = "${path.module}/scripts/create-yaml02.sh '${local.ingress_host}' '${var.namespace}' '${var.sls_storageClass}' '${var.mongo_namespace}' '${var.mongo_svcname}' '${local.chart_name02}' '${local.yaml_dir02}'"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
}

resource null_resource setup_gitops_subscription {
 depends_on = [null_resource.create_yaml01]
  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.chart_name01}' -n '${var.namespace}' --contentDir '${local.yaml_dir01}' --serverName '${var.server_name}' --valueFiles '${local.values_file}' -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}
resource null_resource setup_gitops_instance {
  depends_on = [null_resource.create_yaml02,null_resource.setup_gitops_subscription]
  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.chart_name02}' -n '${var.namespace}' --contentDir '${local.yaml_dir02}' --serverName '${var.server_name}' --valueFiles=${local.values_file} -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}
