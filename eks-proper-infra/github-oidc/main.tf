# GitHub Actions -> AWS OIDC federation
#
# Lets the CI workflow (.github/workflows/3tier-build.yaml) assume an AWS role
# via short-lived federated tokens instead of static access keys.
#
# This lives in its own Terraform state, separate from eks/infra. It used to
# be managed inside the eks/infra stack, and a `terraform destroy` of that
# stack (a routine cluster teardown) deleted these resources along with the
# cluster on 2026-08-20. CI credentials need to survive cluster teardowns, so
# they're now an independent root module with their own state file.

data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions_build" {
  name = "eks-github-actions-build-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          #Federated = aws_iam_openid_connect_provider.github_actions.arn
          Federated = data.aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            # GitHub's immutable subject claim format (repos created after 2026-07-15
            # embed the permanent owner_id/repo_id, so this is an exact, stable match -
            # confirmed against the actual denied CloudTrail AssumeRoleWithWebIdentity events).
            #"token.actions.githubusercontent.com:sub" = "repo:Evatee-coder@70039845/eks-microservices-gitops-platform@1337927724:ref:refs/heads/main"
            #"token.actions.githubusercontent.com:sub" = "repo:Evatee-coder@70039845/eks-microservices-gitops-platform@1354028614:*"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Evatee-coder@70039845/eks-microservices-gitops-platform@1354028614:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "github-actions-eks-build-role"
  }
}

import {
  to = aws_iam_role.github_actions_build
  id = "eks-github-actions-build-role"
}
































