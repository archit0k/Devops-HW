#!/usr/bin/env bash
set -euo pipefail

current_date="$(date '+%Y-%m-%d %H:%M:%S %Z')"
host_name="$(hostname)"
current_user="$(whoami)"

read -r -p 'Enter a directory name to create: ' target_directory
read -r -p 'Enter a file name for process output: ' process_file

mkdir -p "$target_directory"
touch "$target_directory/$process_file"
ps aux > "$target_directory/$process_file"

echo "Current date: $current_date"
echo "Hostname: $host_name"
echo "Username: $current_user"
echo 'Disk usage:'
df -h
echo 'Running processes:'
ps aux
echo "Process information was saved to: $target_directory/$process_file"
