terraform {
  required_providers {
    aws = {
      source  = "opentofu/aws"
      version = "~> 6.28.0"
    }
  }
}

provider "aws" {
  region = var.region
}
