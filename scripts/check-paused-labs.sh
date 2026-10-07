#!/usr/bin/env bash
# Read-only pause verification. Does not provision, submit or restart anything.
set -euo pipefail
aws_cli=/root/.local/bin/aws
for region in ap-south-1 us-east-1; do
  printf 'Region: %s\n' "$region"
  "$aws_cli" eks list-clusters --profile devops-homework --region "$region" --output json
  "$aws_cli" ec2 describe-instances --profile devops-homework --region "$region" \
    --filters Name=instance-state-name,Values=pending,running,stopping,stopped \
    --query 'Reservations[].Instances[].[InstanceId,State.Name]' --output json
  "$aws_cli" ec2 describe-volumes --profile devops-homework --region "$region" \
    --query 'Volumes[].[VolumeId,State]' --output json
  "$aws_cli" ec2 describe-nat-gateways --profile devops-homework --region "$region" \
    --filter Name=state,Values=pending,available,deleting \
    --query 'NatGateways[].[NatGatewayId,State]' --output json
  "$aws_cli" ec2 describe-addresses --profile devops-homework --region "$region" \
    --query 'Addresses[].AllocationId' --output json
  "$aws_cli" ec2 describe-vpcs --profile devops-homework --region "$region" \
    --filters Name=tag:Project,Values=taskboard-lab21 \
    --query 'Vpcs[].VpcId' --output json
  "$aws_cli" ecr describe-repositories --profile devops-homework --region "$region" \
    --query 'repositories[?starts_with(repositoryName, `archit-taskboard-lab/`)].repositoryName' --output json
done
"$aws_cli" s3api list-buckets --profile devops-homework --region us-east-1 \
  --query 'Buckets[].Name' --output json
docker ps --format '{{.Names}} {{.Status}}'
minikube profile list -o json
