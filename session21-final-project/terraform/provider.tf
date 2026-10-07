terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.67" }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
  default_tags {
    tags = {
      Project = "studyslot-homework"
      Owner   = "Archit-Kulkarni"
      Roll    = "24BCS10194"
    }
  }
}
