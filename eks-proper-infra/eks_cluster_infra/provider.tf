provider "aws" {
  region = "us-east-1"

  # assume_role {
  #   ## The ARN of the role in Account B to assume.
  #   role_arn = "arn:aws:iam::01234567890:role/role_in_account_b"
  # }

  default_tags {
    tags = {
      project = "EKS Cluster Setup and Three-Tier Deployment"
    }
  }

}




