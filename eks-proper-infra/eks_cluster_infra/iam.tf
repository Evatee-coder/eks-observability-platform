# IAM Role for EBS CSI driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.environment}-${var.prefix}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Federated = module.eks[0].oidc_provider_arn
        }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks[0].oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${module.eks[0].oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach AWS managed policy AmazonEBSCSIDriverPolicy to the IAM role for EBS CSI driver
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# EBS CSI driver EKS addon, created standalone (outside module.eks's addons map)
# to avoid a dependency cycle: this role's trust policy depends on the module's
# OIDC provider output, so the module itself cannot also depend on this role.
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = module.eks[0].cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver_policy_attachment,
  ]
}