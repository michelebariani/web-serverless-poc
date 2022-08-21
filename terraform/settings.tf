#
# General settings
#

terraform {
  required_version = "~> 1.2.0"

  backend "s3" {
    region = "eu-central-1"
    # You need to change bucket to your own bucket name as they are unique
    bucket         = "michelebariani-terraform"
    key            = "state"
    dynamodb_table = "terraform"
  }

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

provider "aws" {
  region = "eu-central-1"
}

variable "app_source_file" {
  default = "../python/main.py"
}

# This is to be set up as TF_VAR_workspace in the calling environment
variable "workspace" {}
