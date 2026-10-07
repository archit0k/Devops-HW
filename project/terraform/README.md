# AWS lab infrastructure

Two public subnets in separate availability zones, one VPC, one EKS control plane and one managed group with two `t3.medium` nodes. There is no SSH rule, key pair, NAT gateway or RDS instance. Public-node networking avoids a NAT hourly charge for this short classroom lab; a long-running production deployment should normally use private nodes and controlled egress.

The region is `us-east-1`, matching my account setup. Kubernetes 1.35 is in EKS standard support. The lab uses temporary AWS console-session credentials via the `devops-homework` profile, not access keys in code. Terraform state and plan files are ignored because they contain account and resource details.

```bash
terraform init
terraform fmt
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
terraform output
# After the deployments, screenshots and walkthrough:
terraform plan -destroy
terraform destroy
```

The separate lab-admin role is assumed only by the account's root principal and is removed at cleanup. GitHub uses OIDC, restricted to this repository's `main` branch. Its AWS permission is only `eks:DescribeCluster`; Kubernetes access is edit access in `studyslot`, not account-wide administration. The classroom namespace and database Secret are bootstrapped separately.

Cost control: create this cluster only for verification, disable cloud CD before cleanup, delete Kubernetes-created load balancers/volumes first, then destroy Terraform resources. The homework budget is **$30 maximum**; free credits do not make resources free forever. Terraform creation/cleanup evidence will be added after the actual run.
