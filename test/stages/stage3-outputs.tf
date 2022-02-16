
resource null_resource write_outputs {
  provisioner "local-exec" {    
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

environment = {
      OUTPUT = jsonencode({
        name        = module.cp-db2.name
        inst_name   = module.cp-db2.inst_name
        sub_chart   = module.cp-db2.sub_chart
        sub_name   = module.cp-db2.sub_name 
        operator_namespace = module.cp-db2.operator_namespace
        cpd_namespace= module.cp-db2.cpd_namespace
        branch      = module.cp-db2.branch
        namespace   = module.cp-db2.namespace
        server_name = module.cp-db2.server_name
        layer       = module.cp-db2.layer
        layer_dir   = module.cp-db2.layer == "infrastructure" ? "1-infrastructure" : (module.cp-db2.layer == "services" ? "2-services" : "3-applications")
        type        = module.cp-db2.type
      })
    }
  }
}
