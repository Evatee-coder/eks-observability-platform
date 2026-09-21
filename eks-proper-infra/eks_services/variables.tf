variable "prefix" {
  description = "The prefix to use for resource names"
  type        = string
  default     = "microservices"
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster is deployed"
  type        = string
  
}

variable "eks_cluster_name" {
  type = string
}
