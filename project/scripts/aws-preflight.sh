#!/usr/bin/env bash
set -euo pipefail
aws_cli=/root/.local/bin/aws
export AWS_PROFILE=devops-homework AWS_REGION=us-east-1 AWS_DEFAULT_REGION=us-east-1 AWS_PAGER=''
"$aws_cli" sts get-caller-identity
"$aws_cli" eks list-clusters
"$aws_cli" ec2 describe-vpcs --filters Name=tag:Project,Values=studyslot-homework --query 'Vpcs[].{id:VpcId,state:State}'
"$aws_cli" ec2 describe-instances --filters Name=instance-state-name,Values=pending,running,stopped,stopping --query 'Reservations[].Instances[].[InstanceId,State.Name]'
"$aws_cli" iam list-open-id-connect-providers
"$aws_cli" eks describe-cluster-versions --cluster-versions 1.35 --query 'clusterVersions[].{version:clusterVersion,status:status,endStandard:endOfStandardSupportDate}'
"$aws_cli" ce get-cost-and-usage --time-period Start=2026-10-01,End=2026-10-17 --granularity MONTHLY --metrics UnblendedCost --query 'ResultsByTime[].{period:TimePeriod,total:Total,estimated:Estimated}'
