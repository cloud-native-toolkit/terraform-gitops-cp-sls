locals {
  name          ="ibm-sls-operator"
  chart_name01  ="ibm-sls-operator-subscription"
  chart_name02  ="ibm-sls-operator-instance"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir01      = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_name01}/"
  yaml_dir02      = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_name02}/"
  ingress_host  = "${local.name}-${var.sls_namespace}.${var.cluster_ingress_hostname}"
  ingress_url   = "https://${local.ingress_host}"
  service_url   = "http://${local.name}.${var.sls_namespace}"
  PODLIST="$(kubectl get pods --selector=app=mas-mongo-ce-svc -o=json -n mongo -o=jsonpath={.items..metadata.name})"
  PORT="$(kubectl get svc mas-mongo-ce-svc -n mongo -o=jsonpath='{.spec.ports[?(@.name==\"mongodb\")].port}')"
  values_content01 = {
    "ibm-sls-operator-subscription" = {
      subscriptions = {
        ibmsls = {
          name = "ibm-sls"
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
  }
  values_content02 = {
    "ibm-sls-operator-instance" = {
      licenseservices = {
        ibmsls = {
          name = "sls"
          namespace = "${var.sls_namespace}"
          licenseservice = {
            license = {
              accept = true
            }
            domain = "${local.ingress_host}"
            mongo = {
              configDb = "admin"
              nodes = "${null_resource.nodes}"
              secretName = "sls-mongo-credentials"
              authMechanism = "DEFAULT"
              retryWrites = true
              certificates = {
                alias = "mongoca"
                crt = "${null_resource.mongo-crt}"
                      
                  }
                }
            rlks = {
                    storage = {
                      class = var.sls_storageClass 
                      size  =  "20G"
                    }
                  }           
          }
        }
      }
    }
  }
  layer = "services"
  application_branch = "main"
  values_file = "values.yaml"
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}
resource null_resource mongo-credentials {
provisioner "local-exec" {
    command = "kubectl create secret generic sls-mongo-credentials --from-literal=username=${var.mongo_userid} --from-literal=password=${var.mongo_dbpass} -n ${var.sls_namespace}"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
} 
resource null_resource mongo-crt {
provisioner "local-exec" {
    command="$(kubectl get ConfigMap mas-mongo-ce-cert-map -n ${var.mongo_namespace} -o jsonpath='{.data.ca.crt}' | awk '{printf \"        %s \n\", $0}')"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
} 

resource null_resource nodes {
provisioner "local-exec" {
    command="$(for podname in ${local.PODLIST}; do echo \" host: \" $podname.${var.mongo_namespace}.${var.mongo_svcname}.svc$' \n  port = ' ${local.PORT}}; done)"
    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
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
  depends_on = [null_resource.nodes,null_resource.mongo-crt]
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml02.sh '${local.chart_name02}' '${local.yaml_dir02}'  "

    environment = {
      VALUES_CONTENT02 = yamlencode(local.values_content02)
    }
  }
}

resource null_resource setup_gitops {
 depends_on = [null_resource.create_yaml01,null_resource.create_yaml02]
 //depends_on = [null_resource.create_yaml01]


  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.chart_name01}' -n '${var.sls_namespace}' --contentDir '${local.yaml_dir01}' --serverName '${var.server_name}' --valueFiles '${local.values_file}' -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.chart_name02}' -n '${var.sls_namespace}' --contentDir '${local.yaml_dir02}' --serverName '${var.server_name}' --valueFiles=${local.values_file} -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}
