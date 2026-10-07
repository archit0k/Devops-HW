# Linux Fundamentals

## Task 1 - soft links and hard links

A hard link is another directory entry for the same inode and data. A symbolic (soft) link stores a path to its target. Consequently, hard links cannot normally cross filesystems or point to directories, while soft links can; a soft link becomes dangling if the target is deleted.

```bash
mkdir -p link-lab && cd link-lab
echo 'DevOps homework' > original.txt
ln original.txt hard-link.txt
ln -s original.txt soft-link.txt
ls -li original.txt hard-link.txt soft-link.txt
cat hard-link.txt
cat soft-link.txt
rm soft-link.txt hard-link.txt original.txt
```

Interview summary: deleting `original.txt` does not remove data while `hard-link.txt` remains, because its link count is still nonzero. The soft link contains `original.txt`, so it no longer resolves after that deletion.

## Task 2 - `adduser` versus `useradd`

`useradd` is the low-level binary: it creates an account according to options/defaults and often requires flags for a home directory, shell, and groups. `adduser` is a friendlier Debian/Ubuntu Perl wrapper that interactively creates the home directory, asks for account details, and applies sensible defaults. On Ubuntu, `adduser` is normally preferred for an interactive human account.

```bash
sudo adduser devops-test
id devops-test
sudo deluser --remove-home devops-test
```

## Task 3 - `journalctl`

`journalctl` queries the systemd journal, which centralizes kernel, boot, and service logs.

```bash
journalctl -b                    # current boot
journalctl -u ssh --since today  # one service, since today
journalctl -p err..alert         # errors and more severe events
journalctl -f                    # follow new log entries
```

For a service incident, I would first use `journalctl -u <service> -b`, then add a time window such as `--since '30 minutes ago'`.

## Task 4 - essential command cheat sheet

| Purpose | Commands |
| --- | --- |
| Navigate and inspect | `pwd`, `ls -la`, `cd`, `find`, `stat` |
| Files and text | `cp`, `mv`, `rm`, `mkdir`, `touch`, `cat`, `less`, `grep` |
| Permissions | `chmod`, `chown`, `umask` |
| Processes | `ps aux`, `top`, `kill`, `pgrep` |
| Storage | `df -h`, `du -sh`, `mount` |
| Network | `ip addr`, `ss -tulpn`, `ping`, `curl` |
| Archives | `tar -czf archive.tgz folder/`, `tar -xzf archive.tgz` |

Practice each command in a disposable directory and read `man <command>` before using destructive flags.

## Recorded exercise

[Actual command output](evidence/foundations.txt) records inode equality, the dangling soft link, two disposable user accounts, journal queries and command practice. The lab deletes only the two accounts it has just created. It does not alter existing accounts. `adduser` is the distribution's higher-level helper; its implementation language is not the reason to choose it.
