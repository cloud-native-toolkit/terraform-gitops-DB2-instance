module "portworx_module" {
  source = "github.com/cloud-native-toolkit/terraform-portworx.git"

  resource_group_name = var.resource_group_name
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  cluster_name        = module.cluster-portwork.name
  name_prefix         = var.name_prefix
  workers             = module.cluster-portwork.workers
  worker_count        = module.cluster-portwork.total_worker_count
  create_external_etcd = var.create_external_etcd
}

