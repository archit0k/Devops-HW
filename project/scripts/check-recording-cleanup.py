"""Capture exact lab IDs, then verify cleanup without changing AWS resources."""
import argparse
import json
import pathlib
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("action", choices=["capture", "check"])
args = parser.parse_args()
ledger_path = pathlib.Path("private-evidence/studyslot-recording-ledger.json")


def aws(*arguments):
    return json.loads(subprocess.check_output([
        "/root/.local/bin/aws", *arguments, "--profile", "devops-homework",
        "--region", "us-east-1", "--no-cli-pager", "--output", "json",
    ], text=True))


def instances(vpc_id):
    return [instance for reservation in aws(
        "ec2", "describe-instances", "--filters", f"Name=vpc-id,Values={vpc_id}"
    )["Reservations"] for instance in reservation["Instances"]]


if args.action == "capture":
    state = json.loads(subprocess.check_output([
        "terraform", "-chdir=project/terraform", "show", "-json"
    ], text=True))
    resources = state["values"]["root_module"]["resources"]
    vpcs = [r["values"]["id"] for r in resources
            if r.get("mode") == "managed" and r["type"] == "aws_vpc"]
    assert len(vpcs) == 1, "Expected one managed StudySlot VPC"
    node_ids = {i["InstanceId"] for i in instances(vpcs[0])}
    volumes = [v["VolumeId"] for v in aws("ec2", "describe-volumes")["Volumes"]
               if any(a["InstanceId"] in node_ids for a in v["Attachments"])]
    roles = [r["values"]["name"] for r in resources
             if r.get("mode") == "managed" and r["type"] == "aws_iam_role"]
    owned_oidc = [r["values"]["arn"] for r in resources if r.get("mode") == "managed"
                  and r["type"] == "aws_iam_openid_connect_provider"]
    ledger = {"vpc_id": vpcs[0], "cluster": "archit-studyslot",
              "volumes": volumes, "roles": roles, "owned_oidc": owned_oidc}
    ledger_path.parent.mkdir(parents=True, exist_ok=True)
    ledger_path.write_text(json.dumps(ledger, indent=2), encoding="utf-8")
    print("Captured exact StudySlot cleanup targets:", json.dumps(ledger))
    print("A pre-existing OIDC provider outside this Terraform state is not a deletion target.")
else:
    ledger = json.loads(ledger_path.read_text(encoding="utf-8"))
    assert ledger["cluster"] not in aws("eks", "list-clusters")["clusters"]
    print("StudySlot EKS cluster absent: True")
    assert not aws("ec2", "describe-vpcs", "--filters",
                   "Name=tag:Project,Values=studyslot-homework")["Vpcs"]
    print("StudySlot VPCs remaining: 0")
    active = [i["InstanceId"] for i in instances(ledger["vpc_id"])
              if i["State"]["Name"] != "terminated"]
    assert not active, active
    print("Non-terminated StudySlot workers: []")
    remaining = [v["VolumeId"] for v in aws("ec2", "describe-volumes")["Volumes"]
                 if v["VolumeId"] in ledger["volumes"]]
    assert not remaining, remaining
    print("Recorded StudySlot volumes remaining: []")
    remaining_roles = [r["RoleName"] for r in aws("iam", "list-roles")["Roles"]
                       if r["RoleName"] in ledger["roles"]]
    assert not remaining_roles, remaining_roles
    print("StudySlot IAM roles remaining: []")
    providers = {p["Arn"] for p in aws("iam", "list-open-id-connect-providers")[
        "OpenIDConnectProviderList"]}
    assert not providers.intersection(ledger["owned_oidc"])
    print("Terraform-owned OIDC providers remaining: []")
    if not ledger["owned_oidc"]:
        print("Pre-existing shared GitHub OIDC provider was not managed or deleted by this lab.")
    managed = subprocess.check_output([
        "terraform", "-chdir=project/terraform", "state", "list"
    ], text=True).strip()
    assert not managed, managed
    print("Terraform managed resources remaining: 0")
    print("Fresh recording lab cleanup passed. Unrelated account resources were left alone.")
