locals {
  name          ="ibm-sls-operator"
  chart_name01  ="ibm-sls-operator-subscription"
  chart_name02  ="ibm-sls-operator-instance"
  bin_dir       = module.setup_clis.bin_dir
  tmp_dir       = "${path.cwd}/.tmp/${local.name}"
  secret_dir    = "${local.tmp_dir}/secrets"
  password_secret_name = "${local.name}-password"
  yaml_dir01      = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_name01}/"
  yaml_dir02      = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_name02}/"

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

module "add_pullsecret" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  server_name = var.server_name
  kubeseal_cert = var.kubeseal_cert
  namespace = var.namespace
  docker_username = "cp"
  docker_password = var.entitlementkey
  docker_server   = "cp.icr.io"
  secret_name     = "ibm-entitlement"
}

resource null_resource create_secret {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-secret.sh '${var.namespace}' '${var.mongo_userid}' '${var.mongo_dbpass}' '${local.secret_dir}' '${local.password_secret_name}'"
  }
}

module seal_secrets {
  depends_on = [null_resource.create_secret]

  source = "github.com/cloud-native-toolkit/terraform-util-seal-secrets.git?ref=v1.0.0"

  source_dir    = local.secret_dir
  dest_dir      = "${local.yaml_dir01}/templates"
  kubeseal_cert = var.kubeseal_cert
  label         = local.name
}

resource null_resource create_yaml01 {
  depends_on = [module.seal_secrets]
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
    command = "${path.module}/scripts/create-yaml02.sh '${var.cluster_ingress}' '${var.namespace}' '${var.mongo_namespace}' '${var.mongo_svcname}' '${local.chart_name02}' '${var.mongo_port}' '${local.yaml_dir02}'"

    environment = {

      CA_CRT = var.mongo_cacrt
    }
  }
}

resource gitops_module subscription {
  depends_on = [null_resource.create_yaml01,module.add_pullsecret]

  name        = local.chart_name01
  namespace   = var.namespace
  content_dir = local.yaml_dir01
  server_name = var.server_name
  layer       = local.layer
  type        = "operators"
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

resource gitops_module instance {
  depends_on = [null_resource.create_yaml02,gitops_module.subscription]

  name        = local.chart_name02
  namespace   = var.namespace
  content_dir = local.yaml_dir02
  server_name = var.server_name
  layer       = local.layer
  type        = "instances"
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
