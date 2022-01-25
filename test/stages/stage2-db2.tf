module "db2" {
  depends_on = [module.gitops-db2]
  
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  workers = module.gitops.workers
  region = module.gitops.region
}
