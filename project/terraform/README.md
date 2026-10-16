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

The actual [apply record](../evidence/terraform-apply-final.txt) created 26 resources. The [AWS bootstrap run](https://github.com/archit0k/Devops-HW/actions/runs/38893003011) deployed the application and monitoring, checked both non-root users, exercised CRUD through Ingress and verified the database migration. The [access restriction record](../evidence/terraform-restrict-access-final.txt) confirms that namespace-only permissions replaced bootstrap access.

Cost control: create this cluster only for verification, disable cloud CD before cleanup, delete Kubernetes-created volumes while the EBS CSI driver is still running, then destroy Terraform resources. This configuration uses a ClusterIP Ingress controller, not a chargeable public LoadBalancer. The homework budget is **$30 maximum**; free credits do not make resources free forever. State, saved plans and generated passwords are ignored. Keep state until teardown is verified.

On this Windows/WSL machine the large provider binary started slowly from the Windows mount. Keeping the already verified provider on Linux storage fixed startup timeouts; it does not change the infrastructure configuration or bypass the dependency lock checks.
