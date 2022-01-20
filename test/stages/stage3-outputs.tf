
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo '$${OUTPUT}' > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.db2.name
        branch      = module.db2.branch
        namespace   = module.db2.namespace
        server_name = module.db2.server_name
        layer       = module.db2.layer
        layer_dir   = module.db2.layer == "infrastructure" ? "1-infrastructure" : (module.db2.layer == "services" ? "2-services" : "3-applications")
        type        = module.db2.type
      })
    }
  }
}
