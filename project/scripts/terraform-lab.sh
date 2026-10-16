#!/usr/bin/env bash
set -euo pipefail
export PATH="/root/.local/bin:$PATH" AWS_PAGER=''
case ${1:?plan,apply,restrict,destroy} in
  plan) terraform -chdir=project/terraform plan -input=false -no-color -var=bootstrap_cluster=true -out=project.tfplan ;;
  apply) terraform -chdir=project/terraform apply -input=false -no-color project.tfplan ;;
  restrict) terraform -chdir=project/terraform apply -input=false -no-color -var=bootstrap_cluster=false -auto-approve ;;
  destroy) terraform -chdir=project/terraform destroy -input=false -no-color -var=bootstrap_cluster=false -auto-approve ;;
  *) exit 2 ;;
esac
