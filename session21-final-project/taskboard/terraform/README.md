# Terraform lab

This folder teaches Infrastructure as Code by provisioning the AWS VPC and EKS cluster used by the production-style TaskBoard deployment.

The module-based approach keeps the lesson focused on Terraform concepts: providers, variables, modules, state, plan/apply, outputs and dependency graphs.

> Cost warning: an EKS cluster and NAT gateway can incur AWS charges. Destroy classroom infrastructure when finished.

```bash
# If provisioning with root, first set kubectl_principal_arn in the ignored
# terraform.tfvars file to an approved non-root IAM user/role ARN.
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
aws eks update-kubeconfig --profile taskboard-access --region ap-south-1 \
  --name taskboard-eks \
  --assume-role-arn "$(terraform output -raw kubectl_role_arn)" \
  --role-arn "$(terraform output -raw kubectl_role_arn)"
terraform destroy
```

The dedicated lab role is used for Kubernetes access. AWS root cannot assume roles; the first `kubectl` attempt confirmed this restriction. Terraform now rejects that setup before provisioning unless an approved non-root principal is supplied. `taskboard-access` is the intended separate CLI profile, not a profile already created in this repository. No new user or access key has been created while permission is pending. Generated state, saved plans, credentials and kubeconfig stay out of Git. Do not apply this folder while the homework is paused.

EKS depends on the complete VPC module, including its NAT gateway. Cleanup must remove EKS before taking away the private nodes' network path.
