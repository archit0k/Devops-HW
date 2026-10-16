data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" { state = "available" }

resource "aws_vpc" "lab" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "studyslot-vpc" }
}
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.42.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                     = "studyslot-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  }
}
resource "aws_internet_gateway" "lab" { vpc_id = aws_vpc.lab.id }
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }
}
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_iam_role" "cluster" {
  name = "studyslot-eks-control-plane"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "eks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_eks_cluster" "lab" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }
  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_public_access  = true
    endpoint_private_access = true
  }
  depends_on = [aws_iam_role_policy_attachment.cluster]
}
resource "aws_iam_role" "node" {
  name = "studyslot-eks-workers"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "node" {
  for_each   = toset(["AmazonEKSWorkerNodePolicy", "AmazonEC2ContainerRegistryReadOnly", "AmazonEKS_CNI_Policy"])
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}
resource "aws_eks_node_group" "lab" {
  cluster_name    = aws_eks_cluster.lab.name
  node_group_name = "classroom"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = ["t3.medium"]
  ami_type        = "AL2023_x86_64_STANDARD"
  disk_size       = 20
  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }
  update_config { max_unavailable = 1 }
  depends_on = [aws_iam_role_policy_attachment.node, aws_route_table_association.public]
}

data "aws_eks_addon_version" "pod_identity" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}
data "aws_eks_addon_version" "ebs" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}
resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.lab.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.pod_identity.version
  depends_on    = [aws_eks_node_group.lab]
}
resource "aws_iam_role" "ebs" {
  name = "studyslot-ebs-driver"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow", Principal = { Service = "pods.eks.amazonaws.com" },
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ebs" {
  role       = aws_iam_role.ebs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
resource "aws_eks_pod_identity_association" "ebs" {
  cluster_name    = aws_eks_cluster.lab.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs.arn
}
resource "aws_eks_addon" "ebs" {
  cluster_name  = aws_eks_cluster.lab.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs.version
  depends_on    = [aws_eks_node_group.lab, aws_eks_addon.pod_identity, aws_iam_role_policy_attachment.ebs, aws_eks_pod_identity_association.ebs]
}

resource "aws_iam_openid_connect_provider" "github" {
  count          = var.existing_github_oidc_arn == "" ? 1 : 0
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}
locals {
  github_oidc_arn = var.existing_github_oidc_arn != "" ? var.existing_github_oidc_arn : aws_iam_openid_connect_provider.github[0].arn
}
resource "aws_iam_role" "github_deploy" {
  name = "studyslot-github-deploy"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow", Principal = { Federated = local.github_oidc_arn }, Action = "sts:AssumeRoleWithWebIdentity",
      Condition = { StringEquals = {
        "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
        "token.actions.githubusercontent.com:sub" = "repo:archit0k@178862175/Devops-HW@1356256990:ref:refs/heads/main"
      } }
    }]
  })
}
resource "aws_iam_role_policy" "describe_ci" {
  role = aws_iam_role.github_deploy.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["eks:DescribeCluster"], Resource = aws_eks_cluster.lab.arn }]
  })
}
resource "aws_eks_access_entry" "ci" {
  cluster_name      = aws_eks_cluster.lab.name
  principal_arn     = aws_iam_role.github_deploy.arn
  kubernetes_groups = ["studyslot-deploy"]
}
resource "aws_eks_access_policy_association" "ci" {
  cluster_name  = aws_eks_cluster.lab.name
  principal_arn = aws_eks_access_entry.ci.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/${var.bootstrap_cluster ? "AmazonEKSClusterAdminPolicy" : "AmazonEKSEditPolicy"}"
  access_scope {
    type       = var.bootstrap_cluster ? "cluster" : "namespace"
    namespaces = var.bootstrap_cluster ? null : ["studyslot"]
  }
}

data "aws_eks_addon_version" "metrics" {
  addon_name         = "metrics-server"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}
resource "aws_eks_addon" "metrics" {
  cluster_name  = aws_eks_cluster.lab.name
  addon_name    = "metrics-server"
  addon_version = data.aws_eks_addon_version.metrics.version
  depends_on    = [aws_eks_node_group.lab]
}
