# IAM policies and attachments for the GitHub Actions OIDC build role
# defined in main.tf. Split out here to keep identity (main.tf) separate
# from permissions (this file).

# --- ECR push/pull policy ---
resource "aws_iam_policy" "ecr_push_pull" {
  name        = "eks-ECRPushPullPolicy"
  description = "Policy that allows push and pull images from ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:ListTagsForResource",
          "ecr:DescribeRepositories",
          "ecr:TagResource",
          "ecr:UntagResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions_build.name
  policy_arn = aws_iam_policy.ecr_push_pull.arn
}

# --- Terraform state access policy ---
resource "aws_iam_policy" "terraform_state_access" {
  name = "eks-terraform-state-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::state-bucket-216989097838"
        Condition = {
          StringLike = {
            "s3:prefix" = "eks/*"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::state-bucket-216989097838/eks/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_state" {
  role       = aws_iam_role.github_actions_build.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}

# --- Self GetRole policy ---
resource "aws_iam_policy" "self_get_role" {
  name = "eks-github-actions-self-getrole"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["iam:GetRole"]
        Resource = aws_iam_role.github_actions_build.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_self_getrole" {
  role       = aws_iam_role.github_actions_build.name
  policy_arn = aws_iam_policy.self_get_role.arn
}

# --- SSM parameter lookup (EKS AMI IDs) ---
resource "aws_iam_policy" "ssm_eks_ami_lookup" {
  name = "eks-github-actions-ssm-ami-lookup"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = "arn:aws:ssm:us-east-1::parameter/aws/service/eks/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ssm_ami" {
  role       = aws_iam_role.github_actions_build.name
  policy_arn = aws_iam_policy.ssm_eks_ami_lookup.arn
}

# --- EKS + supporting infra provisioning ---
resource "aws_iam_policy" "eks_provisioning" {
  name = "eks-github-actions-provisioning"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2VPCFull"
        Effect   = "Allow"
        Action   = ["ec2:*"]
        Resource = "*"
      },
      {
        Sid    = "IAMRoleManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:ListOpenIDConnectProviders",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider"
        ]
        Resource = "*"
      },
      {
        Sid      = "CloudWatchLogsDiscovery"
        Effect   = "Allow"
        Action   = ["logs:DescribeLogGroups"]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogsManagement"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
          "logs:TagResource",
          "logs:ListTagsForResource"
        ]
        Resource = "arn:aws:logs:us-east-1:216989097838:log-group:/aws/eks/*"
      },
      {
        Sid      = "EKSFull"
        Effect   = "Allow"
        Action   = ["eks:*"]
        Resource = "*"
      },
      {
        Sid    = "KMSForEKSEncryption"
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:DescribeKey",
          "kms:GetKeyPolicy",
          "kms:ListAliases",
          "kms:ListResourceTags",
          "kms:PutKeyPolicy",
          "kms:ScheduleKeyDeletion",
          "kms:TagResource",
          "kms:EnableKeyRotation",
          "kms:GetKeyRotationStatus"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_provisioning" {
  role       = aws_iam_role.github_actions_build.name
  policy_arn = aws_iam_policy.eks_provisioning.arn
}

# --- RDS subnet group management ---
resource "aws_iam_policy" "rds_provisioning" {
  name = "eks-github-actions-rds-provisioning"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RDSSubnetGroupManagement"
        Effect = "Allow"
        Action = [
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBSubnetGroup",
          "rds:DescribeDBSubnetGroups",
          "rds:ModifyDBSubnetGroup",
          "rds:AddTagsToResource",
          "rds:ListTagsForResource"
        ]
        Resource = "arn:aws:rds:us-east-1:216989097838:subgrp:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_rds" {
  role       = aws_iam_role.github_actions_build.name
  policy_arn = aws_iam_policy.rds_provisioning.arn
}

# --- Import existing resources (created before Terraform managed this state) ---
import {
  to = aws_iam_policy.ecr_push_pull
  id = "arn:aws:iam::216989097838:policy/eks-ECRPushPullPolicy"
}

import {
  to = aws_iam_role_policy_attachment.github_actions_ecr
  id = "eks-github-actions-build-role/arn:aws:iam::216989097838:policy/eks-ECRPushPullPolicy"
}