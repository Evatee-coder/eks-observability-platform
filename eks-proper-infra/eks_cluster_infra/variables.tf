variable "environment" {
  description = "The environment for the infrastructure (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

}

variable "project" {
  description = "The project name"
  type        = string
  default     = "eks-microservices"

}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "eks-vpc"

}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"

}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets"
  type        = map(list(string))
  default = {
    public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
    rds_private_subnets = ["10.0.5.0/24", "10.0.6.0/24"]
  }
}


variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "ekscluster"

}

variable "prefix" {
  type    = string
  default = "microservices"
}

variable "if_eks_needed" {
  description = "Flag to indicate if EKS is needed"
  type        = bool
}

variable "db_default_settings" {
  type = any
  default = {
    allocated_storage       = 30
    max_allocated_storage   = 50
    engine_version          = 14.23
    instance_class          = "db.t3.micro"
    backup_retention_period = 2
    db_name                 = "postgres"
    ca_cert_name            = "rds-ca-rsa2048-g1"
    db_admin_username       = "postgres"
  }
}