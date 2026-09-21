data "aws_eks_cluster" "eks" {
  name = "${var.environment}-${var.prefix}-${var.eks_cluster_name}"  #module.eks[0].cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${var.environment}-${var.prefix}-${var.eks_cluster_name}"
}

# output "oidc_url" {
#   value = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer  #points to ekscluster oidc url
# }

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# output "oidc_arn" {
#   value = data.aws_iam_openid_connect_provider.eks.arn

# }



# Configure the Kubernetes provider so Terraform can talk to the EKS cluster's
# API server directly (e.g., for kubernetes_* resources like configmaps, secrets,
# or service accounts managed via Terraform).
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint  # The cluster's API server endpoint URL — where kubectl/Kubernetes API calls go.
  # The cluster's certificate authority (CA) cert, used to verify the API
  # server's identity over TLS. AWS returns this base64-encoded, so it must
  # be decoded before the provider can use it.
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  # A short-lived authentication token used to prove who's calling the API
  # server. This comes from an aws_eks_cluster_auth data source (uses IAM
  # auth under the hood, so whoever runs `terraform apply` authenticates
  # as their own IAM identity — in your case, the CI role).
  token                  = data.aws_eks_cluster_auth.cluster.token
}



# Configure the Helm provider so Terraform can install/manage Helm charts
# (e.g., ingress controllers, cert-manager, monitoring stacks) directly onto
# the EKS cluster. Helm needs its own Kubernetes connection details, provided
# via this nested `kubernetes` block — same three values as above, since Helm
# ultimately talks to the same cluster the same way.
provider "helm" {
  kubernetes = {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  }
}