
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo '$${OUTPUT}' > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.db2u.name
        branch      = module.db2u.branch
        namespace   = module.db2u.operator_namespace
        server_name = module.db2u.server_name
        layer       = module.db2u.layer
        layer_dir   = module.db2u.layer == "infrastructure" ? "1-infrastructure" : (module.db2u.layer == "services" ? "2-services" : "3-applications")
        type        = module.db2u.type
      })
    }
  }
}
