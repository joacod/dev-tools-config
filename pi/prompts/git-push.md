---
description: Push the current branch to origin with safety checks
argument-hint: "[force|-f|create-pr]"
---

Push the current branch to `origin` with these safety checks. Use the bash tool to run each command and inspect its output:

1. **Identify current branch and upstream:**
   - Current branch: `git branch --show-current`
   - Upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "(none)"`

2. **Check repository status:**
   - Run `git status --short`.
   - If there are uncommitted changes, warn the user and suggest `/git-commit` first.

3. **Check whether the branch exists on the remote:**
   - Run `git ls-remote --heads origin <current-branch> 2>/dev/null`.
   - If the result is empty, treat it as a new remote branch and use `git push -u origin <current-branch>`.
   - If an upstream exists, show ahead/behind counts with `git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "(no upstream)"`.

4. **Safety checks before pushing:**
   - Determine the default remote branch with `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || echo "(unknown)"`.
   - If pushing to the default branch or another protected branch, ask for explicit confirmation.
   - Follow any higher-priority project or global safety instructions, including confirmation requirements.

5. **Execute the push:**
   - New branch: `git push -u origin <current-branch>`.
   - Existing branch: `git push origin <current-branch>`.
   - If the push is rejected because the remote has changes, suggest `git pull --rebase` first.
   - If the user-provided arguments include `force` or `-f`, use `git push --force-with-lease` instead of `--force`.

6. **Report the result and offer PR creation:**
   - Confirm a successful push.
   - Show the remote URL.
   - If the remote is GitHub or GitLab, ask whether to create a PR or MR now.
   - If the user-provided arguments include `create-pr`, treat that as a preference to create a PR after the push, while still following confirmation requirements.
   - If the user agrees and the remote is GitHub, create it with `gh pr create`.

User-provided arguments:
$ARGUMENTS
