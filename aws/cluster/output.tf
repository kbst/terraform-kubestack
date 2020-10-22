output "current_config" {
  value = module.configuration.merged[terraform.workspace]
}
