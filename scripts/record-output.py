"""Record real commands, timestamps and exit codes for the lab evidence."""
import argparse
import datetime
import pathlib
import shlex
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("output", type=pathlib.Path)
parser.add_argument("--cwd", default=".")
parser.add_argument("command", nargs=argparse.REMAINDER)
args = parser.parse_args()
command = args.command[1:] if args.command[:1] == ["--"] else args.command
if not command:
    parser.error("a command is required")
started = datetime.datetime.now(datetime.UTC).isoformat()
result = subprocess.run(command, cwd=args.cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
record = f"Recorded: {started}\nCommand: {shlex.join(command)}\n\n{result.stdout}\nExit code: {result.returncode}\n"
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(record, encoding="utf-8")
print(record)
raise SystemExit(result.returncode)
