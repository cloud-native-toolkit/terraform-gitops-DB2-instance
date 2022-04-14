locals {
  name          = "ibm-cpd-db2-instance"
  subscription_name  = "ibm-cpd-db2-subscription"
  bin_dir       = module.setup_clis.bin_dir  
  subscription_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.subscription_name}"
  instance_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  sa_name       = "ibm-db2-ibm-db2"
  layer = "services"
  operator_type  = "operators"
  type  = "instances"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
  subscription_content = {
    name = "ibm-db2oltp-cp4d-operator-catalog-subscription"
    operator_namespace = var.operator_namespace
    common_services_namespace = var.common_services_namespace
    syncWave = "-5"
    spec = {
      channel = var.channel
      installPlanApproval = "Automatic"
      name = "ibm-db2oltp-cp4d-operator"
      source = "ibm-operator-catalog"
      sourceNamespace = var.subscription_source_namespace        
    }       
  } 
  
  instance_content = {
    name = "db2oltp-cr2"
    cpd_namespace = var.cpd_namespace
    spec = {
      license = {
        accept = "true"
        license = var.license 
        db_type = "db2oltp"
        }      
      }               
    }    
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}
resource null_resource create_subcription_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.subscription_name}' '${local.subscription_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.subscription_content)
    }
  }
}

module setup_service_account {
  source = "github.com/cloud-native-toolkit/terraform-gitops-service-account.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = local.namespace
  name = "db2oltp-operandreg-sa"
  server_name = var.server_name  
}

module setup_rbac {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.7.1"

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = local.namespace
  service_account_name      = "db2oltp-operandreg-sa"
  namespace                 = var.common_services_namespace
  rules                     = [
    {
      apiGroups = ["operator.ibm.com"]
      resources = ["operandregistries"]
      verbs = ["get", "apply", "list"]
    }
  ]
  server_name               = var.server_name
  cluster_scope             = true
}


resource null_resource setup_gitops_subscription {
  depends_on = [null_resource.create_subcription_yaml]

  triggers = {
    name = local.subscription_name
    namespace = var.namespace
    yaml_dir = local.subscription_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.operator_type
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

resource null_resource create_instance_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.instance_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.instance_content)
    }
  }
}

resource null_resource setup_gitops_instance {
  depends_on = [null_resource.create_instance_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.instance_yaml_dir
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
