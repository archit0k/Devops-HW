variable "region" {
  type    = string
  default = "us-east-1"
}
variable "aws_profile" {
  type    = string
  default = "devops-homework"
}
variable "cluster_name" {
  type    = string
  default = "archit-studyslot"
}
variable "kubernetes_version" {
  type    = string
  default = "1.35"
}
variable "existing_github_oidc_arn" {
  type    = string
  default = ""
}
