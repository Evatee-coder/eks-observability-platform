terraform {
  required_version = ">= 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "state-bucket-216989097838"
    key     = "eks-microservices/github-oidc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
