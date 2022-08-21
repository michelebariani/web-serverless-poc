#
# Main setup
#

module "infra" {
  source = "./welcome"

  env_name        = (var.workspace == "default" ? "prod" : var.workspace)
  app_source_file = var.app_source_file
}

output "infra" {
  value = module.infra
}
