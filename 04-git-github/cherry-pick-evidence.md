# Cherry-Pick Evidence

This file was committed on the `cherry-pick-lab` branch and selected specifically for transfer into `main` using `git cherry-pick`. Its presence in `main` is the verification that the selected change, rather than the complete branch, was applied.

Commands used:

```bash
git log --oneline --all --decorate
git switch main
git cherry-pick <selected-commit>
git log --oneline --decorate -n 5
```