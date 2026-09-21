# IAM role and policy for AWS Load Balancer Controller 

# Helm Chart deployment for AWS Load Balancer Controller

# Install AWS Load Balancer Controller using Helm 

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set = [
    {
      name  = "clusterName"
      value = "${var.environment}-${var.prefix}-${var.eks_cluster_name}" #module.eks[0].cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.aws_load_balancer_controller.arn
    },
    {
      name  = "region"
      value = "us-east-1"
    },
    {
      name  = "vpcId"
      value = var.vpc_id #module.vpc.vpc_id
    },
  ]

  depends_on = [
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]
}






















# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.8.1"

#   set {
#     name  = "clusterName"
#     value = "${var.environment}-${var.prefix}-ekscluster"
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.aws_load_balancer_controller.arn
#   }

#   set {
#     name  = "region"
#     value = "us-east-1"
#   }

#   set {
#     name  = "vpcId"
#     value = var.vpc_id
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.aws_load_balancer_controller
#   ]
# }

# Service account for AWS Load Balancer Controller


# Helm provider moved to providers.tf to avoid duplication
