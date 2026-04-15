config {
  format = "compact"
  call_module_type = "all"
  force = false
  disabled_by_default = false
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}
