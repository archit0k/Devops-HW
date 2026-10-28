# AWS lab infrastructure

Archit Kulkarni | 24BCS10194 | Section A

[Back to StudySlot](../README.md)

One VPC, two public subnets in separate availability zones, EKS 1.35 and two `t3.medium` workers. The nodes use public-subnet routing. SSH access is disabled.

Region: `us-east-1`. AWS profile: `devops-homework`. State, plan files and credentials stay local.

```bash
terraform init
terraform fmt
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
terraform output
# Cleanup:
terraform plan -destroy
terraform destroy
```

GitHub uses OIDC, restricted to this repository's owner/repository IDs and `main` branch. Its AWS permission is `eks:DescribeCluster`. Bootstrap uses `AmazonEKSClusterAdminPolicy`; `terraform-lab.sh restrict` then switches to `AmazonEKSEditPolicy` scoped to the `studyslot` namespace. Deployment uses short-lived role credentials.

From the repository root:

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

The Ingress controller uses a ClusterIP Service. Before cleanup, disable cloud CD and delete the application/PVC while EBS CSI is running. Then destroy Terraform resources and check the remaining volumes.

The [cleanup workflow](https://github.com/archit0k/Devops-HW/actions/runs/38946391044) removed the PVC before Terraform destroyed all 25 managed resources. The cluster, VPC, workers, volumes and temporary roles were removed. The [destroy screenshot](../screenshots/terraform-destroy.jpg) shows the earlier 26-resource run.
