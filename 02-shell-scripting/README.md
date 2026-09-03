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
