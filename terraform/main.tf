#
# Main setup
#

module "infra" {
  source = "./welcome"
  count  = length(var.environments)

  env_name        = var.environments[count.index]
  app_source_file = var.app_source_file
}

output "urls" {
  value = [for item in module.infra : item.url]
}
