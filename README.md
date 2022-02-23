# Cloud Pak for Data, db2oltp Subscription and Db2oltpService instance gitops module

Module to provision a gitops repo with the resources necessary to provision a Cloud Pak for data,ibm-db2oltp-cp4d-operator Subscription and Db2oltpService instance on a cluster. In order to provision Subscription and the instance, the following steps are performed:

1. Add the db2oltp Subscription chart to the gitops repo (charts/ibm-cpd-db2-subscription)
2. Add the Db2oltpService instance chart to the gitops repo (charts/ibm-cpd-db2-instance)

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - > v0.15
- kubectl

### Terraform providers

- IBM Cloud provider >= 1.5.3
- Helm provider >= 1.1.1 (provided by Terraform)

## Module dependencies

This module makes use of the output from other modules:

- GitOps - github.com/cloud-native-toolkit/terraform-tools-gitops.git
- Namespace - github.com/cloud-native-toolkit/terraform-gitops-namespace.git
- gitops_ibm_catalogs - github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs.git
- gitops_cp_foundation - github.com/cloud-native-toolkit/terraform-gitops-cp-foundational-services.git
- gitops_cp4d_operator - github.com/cloud-native-toolkit/terraform-gitops-cp4d-operator.git
- gitops-cp4d-instance - github.com/cloud-native-toolkit/terraform-gitops-cp4d-instance.git
- gitops-db2 - github.com/cloud-native-toolkit/terraform-gitops-db2u-operator.git

## Example usage

```hcl-terraform
module "cp-db2" {
  depends_on = [module.gitops-db2]
  source = "github.com/cloud-native-toolkit/terraform-gitops-db2-instance.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  operator_namespace= "cpd-operators"  
  cpd_namespace = "gitops-cp4d-instance" 
}
```

## Anatomy of the GitOps module repository

An automation modules is created from a template repository that includes a skeleton of the module logic and the automation framework to validate and release the module.

### Module metadata

The module metadata adds extra descriptive information about the module that is used to build out the module catalog.

```yaml
name: "gitops-db2-instance"
type: gitops
description: "Module to populate a gitops repo wih the resources to provision IBM DB2"
tags:
  - tools
  - gitops
versions:
  - platforms:
      - kubernetes
      - ocp3
      - ocp4
    dependencies:
      - id: gitops
        refs:
          - source: github.com/cloud-native-toolkit/terraform-tools-gitops.git
            version: ">= 1.1.0"
      - id: namespace
        refs:
          - source: github.com/cloud-native-toolkit/terraform-gitops-namespace.git
            version: ">= 1.0.0"
      - id: gitops-db2
        refs:
          - source: https://github.com/cloud-native-toolkit/terraform-gitops-db2u-operator.git
            version: ">= 1.0.0"      
    variables:
      - name: gitops_config
        moduleRef:
          id: gitops
          output: gitops_config
      - name: git_credentials
        moduleRef:
          id: gitops
          output: git_credentials
      - name: server_name
        moduleRef:
          id: gitops
          output: server_name
      - name: namespace
        moduleRef:
          id: namespace
          output: name
      - name: kubeseal_cert
        moduleRef:
          id: gitops
          output: sealed_secrets_cert

```

