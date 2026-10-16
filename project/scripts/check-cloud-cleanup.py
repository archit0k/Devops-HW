"""Read-only checks for the exact temporary StudySlot lab."""
import json
import pathlib
import subprocess
import sys

def aws(*args):
    return json.loads(subprocess.check_output([
        '/root/.local/bin/aws', *args, '--profile', 'devops-homework',
        '--region', 'us-east-1', '--no-cli-pager', '--output', 'json',
    ], text=True))

ledger = pathlib.Path('private-evidence/studyslot-volume-ids.json')
volumes = aws('ec2', 'describe-volumes')['Volumes']
if sys.argv[1:] == ['before']:
    rows = [{k: v[k] for k in ['VolumeId', 'Size', 'State']} for v in volumes]
    print('Volumes remaining after Helm/PVC cleanup:', json.dumps(rows))
    ledger.write_text(json.dumps([v['VolumeId'] for v in volumes]))
    raise SystemExit(0)

clusters = aws('eks', 'list-clusters')['clusters']
print('StudySlot EKS cluster exists:', 'archit-studyslot' in clusters)
assert 'archit-studyslot' not in clusters
vpcs = aws('ec2', 'describe-vpcs', '--filters', 'Name=tag:Project,Values=studyslot-homework')['Vpcs']
print('StudySlot VPCs:', len(vpcs))
assert not vpcs
reservations = aws('ec2', 'describe-instances', '--filters',
                   'Name=vpc-id,Values=vpc-09363c7f725b28c28')['Reservations']
active = [i['InstanceId'] for r in reservations for i in r['Instances'] if i['State']['Name'] != 'terminated']
print('Non-terminated StudySlot worker instances:', active)
assert not active
tracked = set(json.loads(ledger.read_text()))
remaining = [v['VolumeId'] for v in volumes if v['VolumeId'] in tracked]
print('Remaining recorded worker/PVC volumes:', remaining)
assert not remaining
roles = [r['RoleName'] for r in aws('iam', 'list-roles')['Roles'] if r['RoleName'].startswith('studyslot-')]
print('StudySlot IAM roles:', roles)
assert not roles
providers = aws('iam', 'list-open-id-connect-providers')['OpenIDConnectProviderList']
ours = 'arn:aws:iam::731372490400:oidc-provider/token.actions.githubusercontent.com'
print('Temporary GitHub OIDC provider exists:', any(p['Arn'] == ours for p in providers))
assert not any(p['Arn'] == ours for p in providers)
state = subprocess.check_output(['terraform', '-chdir=project/terraform', 'state', 'list'], text=True)
print('Terraform managed resources remaining:', len(state.splitlines()))
assert not state.strip()
print('StudySlot cloud cleanup checks passed. Other account resources were not changed.')
