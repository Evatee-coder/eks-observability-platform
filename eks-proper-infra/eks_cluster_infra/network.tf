module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = "${var.environment}-${var.prefix}-${var.vpc_name}"
  cidr = var.vpc_cidr

  # # for two azs
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = var.subnet_cidrs["private_subnets"]
  public_subnets  = [var.subnet_cidrs["public_subnets"][0], var.subnet_cidrs["public_subnets"][1]]
  database_subnets = var.subnet_cidrs["rds_private_subnets"]

  enable_nat_gateway = true
  single_nat_gateway = true
  # EKS nodes generally need a NAT gateway (or a public IP and an Internet Gateway) to join and operate within a private subnet. 
  # NAT gateway is required to allow pods get image (private or public) from internet.
  enable_dns_hostnames = true
  enable_dns_support   = true


  # Module creates the RDS subnet group 
  create_database_subnet_group = true
  database_subnet_group_name   = "rds-subnet-group"

  tags = {
    Terraform   = "true"
    Environment = var.environment
    repo        = "eks-microservices-gitops-platforms"
  }



  # Required tags for EKS cluster subnet discovery

  # The tags below will allow kubernetes cluster to find those public subnets to create those load balancer 
  # NOTE: no private_subnet_tags here — EKS-specific tags are applied
  # explicitly below, scoped only to the EKS subnets (not RDS).
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}-${var.prefix}-${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                                  = "1"
  }


  # EKS-specific discovery tags now apply directly to private_subnets —
  # database_subnets are a separate module output and are never touched by these
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}-${var.prefix}-${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                         = "1"
  }

}

















# # --- EKS-only private subnet tags (RDS subnets intentionally excluded) ---
# locals {
#   eks_subnet_cidrs = var.subnet_cidrs["eks_private_subnets"]
# }

# resource "aws_ec2_tag" "eks_subnet_cluster_tag" {
#   for_each    = { for idx, cidr in local.eks_subnet_cidrs : idx => module.vpc.private_subnets[idx] }
#   resource_id = each.value
#   key         = "kubernetes.io/cluster/eks-microservices-gitops-platform"
#   value       = "shared"
# }

# resource "aws_ec2_tag" "eks_subnet_role_tag" {
#   for_each    = { for idx, cidr in local.eks_subnet_cidrs : idx => module.vpc.private_subnets[idx] }
#   resource_id = each.value
#   key         = "kubernetes.io/role/internal-elb"
#   value       = "1"
# }

# # --- RDS subnet group (RDS subnets, untouched by K8s tags) ---
# # RDS subnets are deliberately isolated from EKS: no k8s discovery tags,
# # no load balancer placement — database tier stays out of the cluster's
# # networking surface area.

# # resource "aws_db_subnet_group" "rds" {
# #   name       = "rds-subnet-group"
# #   subnet_ids = [module.vpc.private_subnets[2], module.vpc.private_subnets[3]]
# #   tags       = { Name = "rds-subnet-group" }
# # }

