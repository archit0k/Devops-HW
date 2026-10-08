variable "aws_region" { default = "ap-south-1" }
variable "cluster_name" { default = "taskboard-eks" }
variable "environment" { default = "dev" }
variable "kubectl_principal_arn" {
  description = "Approved non-root IAM user/role that may assume this lab's Kubernetes access role."
  type        = string
  default     = null
  validation {
    condition     = var.kubectl_principal_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:(user|role)/.+$", var.kubectl_principal_arn))
    error_message = "Use a non-root IAM user or role ARN, not a root or STS session ARN."
  }
}
