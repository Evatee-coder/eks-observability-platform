# Grants my personal IAM user (cli-adetayo) admin access to the EKS
# cluster's Kubernetes API, so local `terraform apply`/`kubectl` commands
# authenticate correctly without manual CLI setup after every cluster rebuild.

resource "aws_eks_access_entry" "cli_adetayo" {
  cluster_name  = "${var.environment}-${var.prefix}-${var.eks_cluster_name}" #module.eks[0].cluster_name
  principal_arn = "arn:aws:iam::216989097838:user/cli-adetayo"

  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "cli_adetayo_admin" {
  cluster_name  = "${var.environment}-${var.prefix}-${var.eks_cluster_name}" #module.eks[0].cluster_name
  principal_arn = aws_eks_access_entry.cli_adetayo.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.cli_adetayo]
}


resource "aws_eks_access_entry" "ci_role" {
  cluster_name  = "${var.environment}-${var.prefix}-${var.eks_cluster_name}" #module.eks[0].cluster_name
  principal_arn = "arn:aws:iam::216989097838:role/eks-github-actions-build-role"

  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "ci_role_admin" {
  cluster_name  = "${var.environment}-${var.prefix}-${var.eks_cluster_name}" #module.eks[0].cluster_name
  principal_arn = aws_eks_access_entry.ci_role.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.ci_role]
}  