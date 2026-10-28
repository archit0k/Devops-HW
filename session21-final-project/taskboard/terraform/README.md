# Terraform lab

Archit Kulkarni | 24BCS10194 | Section A

[Back to the TaskBoard walkthrough](../../README.md)

Terraform modules for the TaskBoard VPC, networking, EKS cluster and add-ons in `ap-south-1`.

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

The AWS infrastructure check created and destroyed 66 resources. Application checks ran on Minikube and CI Kind.

Configure the `taskboard-access` CLI profile and a non-root Kubernetes principal before provisioning. The access preflight checks this configuration. State, plans, credentials and kubeconfig stay local.

EKS depends on the complete VPC module, including its NAT gateway. Cleanup must remove EKS before taking away the private nodes' network path.
