module "vpc" {
  source              = "terraform-aws-modules/vpc/aws"
  version             = "5.8.1"
  name                = "archit-taskboard-lab-vpc"
  cidr                = "10.20.0.0/16"
  azs                 = ["ap-south-1a", "ap-south-1b"]
  private_subnets     = ["10.20.1.0/24", "10.20.2.0/24"]
  public_subnets      = ["10.20.101.0/24", "10.20.102.0/24"]
  enable_nat_gateway  = true
  single_nat_gateway  = true
  public_subnet_tags  = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }
  tags                = { Owner = "Archit-Kulkarni", Roll = "24BCS10194", Project = "taskboard-lab21" }
}

module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "20.37.1"
  cluster_name                             = var.cluster_name
  cluster_version                          = "1.35"
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = false
  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size       = 2
      max_size       = 4
      desired_size   = 2
    }
  }
  tags = { Owner = "Archit-Kulkarni", Roll = "24BCS10194", Project = "taskboard-lab21" }
}

resource "aws_iam_role" "ebs_csi" {
  name = "archit-taskboard-lab-ebs-csi"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = module.eks.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi.arn
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on                  = [aws_iam_role_policy_attachment.ebs_csi]
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lab_access" {
  name = "archit-taskboard-lab-access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action = "sts:AssumeRole"
      Condition = { ArnEquals = { "aws:PrincipalArn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" } }
    }]
  })
}

resource "aws_iam_role_policy" "describe_cluster" {
  role = aws_iam_role.lab_access.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["eks:DescribeCluster"], Resource = module.eks.cluster_arn }]
  })
}

resource "aws_eks_access_entry" "lab" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.lab_access.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "lab" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.lab_access.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.lab]
}
