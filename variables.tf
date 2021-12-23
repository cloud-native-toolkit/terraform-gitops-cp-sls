
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
}

variable "sls_namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}
variable "sls_key" {
  type        = string
  description = "ibm container entitlement key for sls"

}

variable "sls_storageClass" {
  type        = string
  description = "Name for sls file storage class"
  default = "portworx-db2-rwx-sc"
}

variable "mongo_userid" {
  type        = string
  description = "mongodb admin userid, should stay admin in most cases"
  default     = "admin"
}

variable "mongo_dbpass" {
  type        = string
  description = "mongodb password"

}

variable "mongo_namespace" {
  type        = string
  description = "namespace for mongo"
  
}

variable "mongo_svcname" {
  type        = string
  description = "service name for mongo"
  
}

variable "certmgr_namespace" {
  type        = string
  description = "Namespace where cert-manager is deployed"
  default = "cert-manager"
}
variable "cluster_ingress_hostname" {
  type        = string
  description = "Ingress hostname of the IKS cluster."
  default     = ""
}

variable "cluster_type" {
  type        = string
  description = "The cluster type (openshift or ocp3 or ocp4 or kubernetes)"
  default     = "ocp4"
}

variable "tls_secret_name" {
  type        = string
  description = "The name of the secret containing the tls certificate values"
  default     = ""
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}
variable "catalog" {
  type        = string
  description = "The catalog source that should be used to deploy the operator"
  default     = "ibm-operator-catalog"
}

variable "catalog_namespace" {
  type        = string
  description = "The namespace where the catalog has been deployed"
  default     = "openshift-marketplace"
}

variable "channel" {
  type        = string
  description = "The channel that should be used to deploy the operator"
  default     = "3.x"
}