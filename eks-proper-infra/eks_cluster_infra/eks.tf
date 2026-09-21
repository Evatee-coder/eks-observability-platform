module "eks" {
  count = var.if_eks_needed ? 1 : 0 # if the value is true, do the first(1) one, if the value is false, do the second(0) one. 
  #So if the value is false, it will not create any EKS cluster, and if the value is true, it will create 1 EKS cluster. 
  #This way we can control whether we want to create EKS cluster or not based on the environment (dev or prod) by setting the value 
  #of if_eks_needed variable in the respective tfvars file.
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.5.0"

  name               = "${var.environment}-${var.prefix}-${var.eks_cluster_name}" #ekscluster
  kubernetes_version = "1.33"

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    # aws-ebs-csi-driver is intentionally NOT declared here.
    # It needs aws_iam_role.ebs_csi_driver, which needs this module's OIDC
    # provider output -> declaring it inline creates a dependency cycle.
    # It's created as a standalone aws_eks_addon resource in iam.tf instead.
  }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  #enable_cluster_creator_admin_permissions = true
  enable_cluster_creator_admin_permissions = false  # added this to remove AWS-side conflict permanently and keeps my access grant explicit and visible in my own code

  vpc_id = module.vpc.vpc_id

  # private subnet id for eks control and node
  subnet_ids = module.vpc.private_subnets
  # control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    #Environment = "dev"
    Terraform = "true"
    repo      = "eks-microservices-gitops-platforms"
  }
}