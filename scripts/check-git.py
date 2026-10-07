"""Small real Git exercise in a temporary repo, separate from published homework history."""
import pathlib
import subprocess
import tempfile

with tempfile.TemporaryDirectory(prefix="archit-git-lab-") as directory:
    repo = pathlib.Path(directory)

    def git(*args, expect=0):
        print("git", *args, flush=True)
        result = subprocess.run(["git", *args], cwd=repo, text=True, capture_output=True)
        print(result.stdout + result.stderr, flush=True)
        assert result.returncode == expect, (args, result.returncode)
        return result.stdout.strip()

    git("init", "-b", "main")
    git("config", "user.name", "Archit")
    git("config", "user.email", "architkulkarni0@gmail.com")
    (repo / "notes.txt").write_text("Archit - 24BCS10194\n")
    git("add", "notes.txt")
    git("commit", "-m", "Start notes")
    (repo / "notes.txt").write_text("Archit - 24BCS10194\nLinux and Git\n")
    git("commit", "-m", "Unstaged change", expect=1)
    git("commit", "-am", "Update tracked notes")
    (repo / "new.txt").write_text("Untracked files still need git add\n")
    git("commit", "-am", "Try new file without add", expect=1)
    git("add", "new.txt")
    git("commit", "-m", "Add new notes")
    git("switch", "-c", "practice")
    for number in range(1, 4):
        (repo / f"branch-{number}.txt").write_text(f"Branch note {number}\n")
        git("add", f"branch-{number}.txt")
        git("commit", "-m", f"Add branch note {number}")
        if number == 2:
            selected = git("rev-parse", "HEAD")
    git("log", "--oneline", "--all", "--graph")
    git("switch", "main")
    git("cherry-pick", selected)
    assert (repo / "branch-2.txt").exists()
    assert not (repo / "branch-1.txt").exists()
    assert not (repo / "branch-3.txt").exists()
    git("log", "--oneline", "--all", "--graph", "--decorate")
    print("Only branch note 2 transferred to main. All checks passed.")
