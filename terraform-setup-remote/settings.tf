#
# Settings for resources enabling terraform remote state
#

terraform {
  required_version = "~> 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

variable "remote_state_s3_bucket_name" {
  # You need to change bucket to your own bucket name as they are unique
  default = "michelebariani-terraform"
}

variable "remote_state_dynamodb_table_name" {
  default = "terraform"
}
