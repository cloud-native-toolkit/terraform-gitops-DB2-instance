locals {
  name          = "ibm-db2"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  sa_name       = "ibm-db2-ibm-db2"
  layer = "services"
  type  = "instances"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
  values_content = {
    "db2instance" = {
       name = local.name
       spec = {
        license = {
         accept = true
         license = var.license     
         db_type = "db2oltp"
          }
        }
      }
    }  
    values_file = "values-${var.server_name}.yaml"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

/*module pull_secret {
  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  server_name = var.server_name
  kubeseal_cert = var.kubeseal_cert
  namespace = var.namespace
  docker_username = "cp"
  docker_password = var.entitlement_key
  docker_server   = "cp.icr.io"
  secret_name     = "ibm-entitlement-key-s"
}*/

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

module "service_account" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-service-account.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  name = local.sa_name
  sccs = ["anyuid", "privileged"]
  server_name = var.server_name
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml,module.service_account]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
