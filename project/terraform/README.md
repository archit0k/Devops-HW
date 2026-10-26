# AWS lab infrastructure

Archit Kulkarni | 24BCS10194 | Section A

[Back to StudySlot](../README.md)

Two public subnets in separate availability zones, one VPC, one EKS control plane and one managed group with two `t3.medium` nodes. There is no SSH rule, key pair, NAT gateway or RDS instance. Public-node networking avoids a NAT hourly charge for this short classroom lab; a long-running production deployment should normally use private nodes and controlled egress.

The region is `us-east-1`. EKS uses Kubernetes 1.35. The recorded lab used the `devops-homework` profile; configure an authorized AWS profile before running these commands. State, plan files and runtime credentials are ignored.

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

GitHub uses OIDC, restricted to this repository's immutable owner/repository IDs and `main` branch. Its AWS permission is only `eks:DescribeCluster`. Initial setup temporarily uses `AmazonEKSClusterAdminPolicy` on this cluster; after bootstrap, `bash project/scripts/terraform-lab.sh restrict` replaces that with `AmazonEKSEditPolicy` scoped to the `studyslot` namespace. There is no separate root-assumed lab role, IAM user or permanent access key. Root credentials cannot directly authenticate kubectl to EKS, so the deployment runs through the approved temporary GitHub role.

From the repository root, the lab helper records a reproducible sequence:

```bash
bash project/scripts/terraform-lab.sh plan
bash project/scripts/terraform-lab.sh apply
# Dispatch studyslot-aws-lab.yml with action=bootstrap and an already scanned SHA.
bash project/scripts/terraform-lab.sh restrict
# Enable ENABLE_EKS_CD only while this temporary lab exists.
# After the demo: disable CD, dispatch action=cleanup, then:
bash project/scripts/terraform-lab.sh destroy
```

The [AWS bootstrap](https://github.com/archit0k/Devops-HW/actions/runs/38942882934) deployed the application and monitoring, checked both non-root users, exercised CRUD through Ingress and verified the database migration. The later [main-branch pipeline](https://github.com/archit0k/Devops-HW/actions/runs/38943691357) passed deployment with namespace-only permissions. [VPC](../screenshots/aws-vpc.jpg) and [EKS](../screenshots/aws-eks.jpg) screenshots show the provisioned infrastructure.

If the account already has GitHub's OIDC provider, set `existing_github_oidc_arn` in ignored `terraform.tfvars`. This reuses the provider without importing it into this lab's state or deleting it on teardown. Otherwise Terraform creates its own provider. The initial run managed 26 resources; the later run managed 25 because it reused the existing provider.

Create this cluster only for verification. Disable cloud CD before cleanup, delete the application/PVC while EBS CSI is still running, then destroy Terraform resources. This configuration uses a ClusterIP Ingress controller rather than a public application LoadBalancer. Keep state until teardown is verified.

The [cleanup workflow](https://github.com/archit0k/Devops-HW/actions/runs/38946391044) removed the later application's PVC before Terraform destroyed all 25 managed resources. Final checks found no project cluster, VPC, workers, recorded volumes or temporary roles. The [destroy screenshot](../screenshots/terraform-destroy.jpg) is from the earlier 26-resource run. Shared account infrastructure was not a deletion target.
