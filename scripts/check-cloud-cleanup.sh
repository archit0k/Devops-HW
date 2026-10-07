#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export AWS_REGION=us-east-1
aws=/root/.local/bin/aws
set -x
terraform -chdir=session18-terraform/terraform-s3-demo state list
terraform -chdir=session19-cloud-terraform state list
"$aws" ec2 describe-instances --profile devops-homework --region us-east-1 --filters Name=tag:Project,Values=devops-homework19 --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name}' --output json
"$aws" ec2 describe-vpcs --profile devops-homework --region us-east-1 --filters Name=tag:Project,Values=devops-homework19 --query 'Vpcs[].VpcId' --output json
"$aws" ec2 describe-volumes --profile devops-homework --region us-east-1 --filters Name=tag:Project,Values=devops-homework19 --query 'Volumes[].VolumeId' --output json
"$aws" s3api list-buckets --profile devops-homework --region us-east-1 --query 'Buckets[?starts_with(Name, `archit-24bcs10194-devops-hw`)].Name' --output json
