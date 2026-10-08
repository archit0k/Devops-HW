"""Record real commands, timestamps and exit codes for the lab evidence."""
import argparse
import datetime
import pathlib
import shlex
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

parser = argparse.ArgumentParser()
parser.add_argument("output", type=pathlib.Path)
parser.add_argument("--cwd", default=".")
parser.add_argument("command", nargs=argparse.REMAINDER)
args = parser.parse_args()
command = args.command[1:] if args.command[:1] == ["--"] else args.command
if not command:
    parser.error("a command is required")
started = datetime.datetime.now(datetime.UTC).isoformat()
args.output.parent.mkdir(parents=True, exist_ok=True)
with args.output.open("w", encoding="utf-8") as output:
    header = f"Recorded: {started}\nCommand: {shlex.join(command)}\n\n"
    output.write(header)
    output.flush()
    print(header, end="", flush=True)
    with subprocess.Popen(command, cwd=args.cwd, text=True, encoding="utf-8", errors="replace", stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, bufsize=1) as process:
        for line in process.stdout:
            output.write(line)
            output.flush()
            print(line, end="", flush=True)
        code = process.wait()
    footer = f"\nExit code: {code}\n"
    output.write(footer)
    print(footer, end="", flush=True)
raise SystemExit(code)
