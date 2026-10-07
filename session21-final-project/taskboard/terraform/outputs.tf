output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "vpc_id" { value = module.vpc.vpc_id }
output "kubectl_role_arn" { value = aws_iam_role.lab_access.arn }
output "image_repositories" { value = { for name, repository in aws_ecr_repository.lab : name => repository.repository_url } }
