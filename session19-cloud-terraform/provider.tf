terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.67" }
  }
}
provider "aws" {
  region  = var.region
  profile = "devops-homework"
  default_tags {
    tags = { Project = "devops-homework19", Owner = "Archit-Kulkarni", Roll = "24BCS10194" }
  }
}
