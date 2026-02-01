---
description: Push current branch to origin with safety checks
---

Push the current branch to origin with these safety checks:

1. **Identify current branch and upstream:**
   Current branch: !`git branch --show-current`
   Upstream: !`git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "(none)"`

2. **Check repository status:**
   !`git status --short`
   - If there are uncommitted changes, warn me and suggest `/git-commit` first.

3. **Check if branch exists on remote:**
   !`git ls-remote --heads origin $(git branch --show-current) 2>/dev/null`
   - If empty, treat as a new remote branch and set upstream with `git push -u origin <branch>`.
   - If upstream exists, show ahead/behind counts:
     !`git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "(no upstream)"`

4. **Safety checks before pushing:**
   - Determine default remote branch:
     !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || echo "(unknown)"`
   - If pushing to the default branch (or a protected branch), ask for explicit confirmation.

5. **Execute the push:**
   - New branch: `git push -u origin <current-branch>`
   - Existing branch: `git push origin <current-branch>`
   - If rejected due to remote changes, suggest `git pull --rebase` first.

6. **Report result:**
   - Confirm successful push.
   - Show the remote URL. If it's GitHub/GitLab, suggest creating a PR/MR.

$ARGUMENTS

If I specified `force` or `-f` above, use `git push --force-with-lease` (safer than `--force`).
