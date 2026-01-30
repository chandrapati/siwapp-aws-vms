terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  region = var.aws_region
  # Credentials will be loaded from ~/.aws/credentials or environment variables
  # This is the secure way - no hardcoded credentials!
}
