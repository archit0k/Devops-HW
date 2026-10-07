# Terraform lab

This folder teaches Infrastructure as Code by provisioning the AWS VPC and EKS cluster used by the production-style TaskBoard deployment.

The module-based approach keeps the lesson focused on Terraform concepts: providers, variables, modules, state, plan/apply, outputs and dependency graphs.

> Cost warning: an EKS cluster and NAT gateway can incur AWS charges. Destroy classroom infrastructure when finished.

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
aws eks update-kubeconfig --profile devops-homework --region ap-south-1 \
  --name taskboard-eks --role-arn "$(terraform output -raw kubectl_role_arn)"
terraform destroy
```

The dedicated lab role is used for Kubernetes access; AWS root is not an EKS access-entry principal. Generated state, saved plans and kubeconfig stay out of Git. Do not apply this folder while the homework is paused.
