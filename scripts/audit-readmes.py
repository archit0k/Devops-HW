"""Check local Markdown links without changing files or contacting websites."""
import pathlib
import re
import subprocess
import urllib.parse

root = pathlib.Path(__file__).resolve().parents[1]
tracked = subprocess.check_output(["git", "ls-files", "*.md"], cwd=root, text=True).splitlines()
errors = []
checked = 0
for name in tracked:
    source = root / name
    if not source.exists():
        continue
    for target in re.findall(r"!?\[[^\]]*\]\(([^)]+)\)", source.read_text(encoding="utf-8")):
        target = target.strip().strip("<>")
        if target.startswith(("https://", "http://", "#", "mailto:")):
            continue
        path = urllib.parse.unquote(target.split("#", 1)[0])
        checked += 1
        if not (source.parent / path).exists():
            errors.append(f"{name}: {target}")
print(f"Checked {checked} local Markdown links")
for error in errors:
    print("BROKEN:", error)
raise SystemExit(bool(errors))
