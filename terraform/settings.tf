#
# General settings
#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}

variable "provider_aws_region" {
  default = "eu-central-1"
}

variable "environments" {
  default = ["dev", "prod"]
}

variable "app_source_file" {
  default = "../python/main.py"
}

variable "create_and_show_github_deploy_secrets" {
  default = 0
}
