# System Information Script

`system-info.sh` meets the task requirements: it uses variables, accepts two values with `read -p`, creates a directory with `mkdir`, creates a file with `touch`, and uses `>` to redirect `ps aux` into that file.

Run it from a Linux shell:

```bash
chmod +x system-info.sh
./system-info.sh
```

Example input:

```text
Enter a directory name to create: system-report
Enter a file name for process output: processes.log
```

The generated `system-report/processes.log` contains the complete `ps aux` output. `df -h` and `ps aux` are also printed to the terminal for immediate review.

## Verification output (Ubuntu WSL, 2026-09-03)

The script was executed with the example input above. Its captured output began as follows:

```text
Current date: 2026-09-03 18:06:25 UTC
Hostname: LAPTOP-HG5QJ0K2
Username: archit
Disk usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdd       1007G  2.3G  954G   1% /
C:\\             475G  452G   24G  96% /mnt/c
Running processes:
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1 21.7  0.2  24316 15360 ?        Ss   18:06   0:01 /sbin/init
...
Process information was saved to: system-report/processes.log
```

The full captured process list is committed at `system-report/processes.log`.
