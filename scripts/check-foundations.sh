#!/usr/bin/env bash
set -euo pipefail
set -x
scratch=$(mktemp -d)
cd "$scratch"
pwd
printf 'Archit Kulkarni - 24BCS10194\n' > original.txt
ln original.txt hard-link.txt
ln -s original.txt soft-link.txt
ls -li original.txt hard-link.txt soft-link.txt
cat hard-link.txt soft-link.txt
rm original.txt
cat hard-link.txt
test ! -e soft-link.txt && test -L soft-link.txt
ls -li hard-link.txt soft-link.txt
rm hard-link.txt soft-link.txt
for student_user in homework-adduser-24 homework-useradd-24; do
  if getent passwd "$student_user"; then echo 'Lab user already exists; not touching it'; exit 1; fi
done
adduser --disabled-password --gecos '' homework-adduser-24
useradd --create-home --shell /bin/bash homework-useradd-24
id homework-adduser-24
id homework-useradd-24
getent passwd homework-adduser-24 homework-useradd-24
test "$(getent passwd homework-adduser-24 | cut -d: -f6)" = /home/homework-adduser-24
test "$(getent passwd homework-useradd-24 | cut -d: -f6)" = /home/homework-useradd-24
deluser --remove-home homework-adduser-24
userdel --remove homework-useradd-24
journalctl -b -n 8 --no-pager
journalctl -u docker -n 8 --no-pager
mkdir practice
touch practice/notes.txt
printf 'DevOps homework\nnetwork practice\n' > practice/notes.txt
cp practice/notes.txt practice/copy.txt
mv practice/copy.txt practice/moved.txt
cat practice/notes.txt
grep network practice/notes.txt
chmod 640 practice/notes.txt
stat practice/notes.txt
find practice -type f
du -sh practice
df -h /
ps -eo pid,comm | head -n 12
tar -czf practice.tgz practice
tar -tzf practice.tgz
ip addr show eth0
ip route
ss -tulpn
getent hosts github.com
ping -c 2 -W 2 1.1.1.1 || true
curl -4 -I --retry 3 --max-time 20 https://github.com || true
printf '%s\n%s\n' "$scratch/system-report" processes.log | bash '/mnt/c/Users/archi/Github Projects/Devops-HW/02-shell-scripting/system-info.sh'
test -s "$scratch/system-report/processes.log"
wc -l "$scratch/system-report/processes.log"
