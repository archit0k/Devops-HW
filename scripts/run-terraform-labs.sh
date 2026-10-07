#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export AWS_REGION=us-east-1
export AWS_MAX_ATTEMPTS=8
provider_dir=/tmp/homework-provider
if [[ ! -x "$provider_dir/registry.terraform.io/hashicorp/aws/6.67.0/linux_amd64/terraform-provider-aws_v6.67.0_x5" ]]; then
  curl -fSL --retry 4 -o /tmp/terraform-provider-aws_6.67.0_linux_amd64.zip https://releases.hashicorp.com/terraform-provider-aws/6.67.0/terraform-provider-aws_6.67.0_linux_amd64.zip
  curl -fsSL --retry 4 -o /tmp/aws-checksums.txt https://releases.hashicorp.com/terraform-provider-aws/6.67.0/terraform-provider-aws_6.67.0_SHA256SUMS
  (cd /tmp && grep terraform-provider-aws_6.67.0_linux_amd64.zip aws-checksums.txt | sha256sum -c -)
  mkdir -p "$provider_dir/registry.terraform.io/hashicorp/aws/6.67.0/linux_amd64"
  unzip -o /tmp/terraform-provider-aws_6.67.0_linux_amd64.zip -d "$provider_dir/registry.terraform.io/hashicorp/aws/6.67.0/linux_amd64"
fi
for spec in 'session19-cloud-terraform:session19-cloud-terraform' 'session18-terraform/terraform-s3-demo:session18-terraform'; do
  IFS=: read -r directory evidence_root <<< "$spec"
  terraform -chdir="$directory" providers lock -fs-mirror="$provider_dir" -platform=linux_amd64
  python3 scripts/record-output.py "$evidence_root/evidence/init.txt" -- terraform -chdir="$directory" init -plugin-dir="$provider_dir" -input=false -no-color
  python3 scripts/record-output.py "$evidence_root/evidence/plan.txt" -- terraform -chdir="$directory" plan -out=lab.tfplan -input=false -no-color
  python3 scripts/record-output.py "$evidence_root/evidence/apply.txt" -- terraform -chdir="$directory" apply -input=false -no-color lab.tfplan
  python3 scripts/record-output.py "$evidence_root/evidence/show.txt" -- terraform -chdir="$directory" show -no-color
  python3 scripts/record-output.py "$evidence_root/evidence/output.txt" -- terraform -chdir="$directory" output -no-color
done
