output "vpc_id" { value = aws_vpc.lab.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "cluster_name" { value = aws_eks_cluster.lab.name }
output "lab_admin_role_arn" { value = aws_iam_role.lab_admin.arn }
output "github_deploy_role_arn" { value = aws_iam_role.github_deploy.arn }
