---
description: Stage, commit changes with a safe, generated message
---

Before committing, follow these steps in order:

1. **Review local changes first:**
   !`git status --short`
   !`git diff --stat`
   !`git diff --cached --stat`

2. **Check branch and upstream (if any):**
   Current branch: !`git branch --show-current`
   Upstream: !`git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "(none)"`

3. **Only sync if asked or clearly needed:**
   - If $ARGUMENTS includes `sync` or `rebase`, or if upstream exists and we are behind, then:
     - `git fetch origin 2>/dev/null`
     - Behind count: !`git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0"`
     - If behind > 0, run `git pull --rebase origin <current-branch>`
     - If there are conflicts, stop and notify me

4. **Decide what to stage (avoid secrets and generated files):**
   - If $ARGUMENTS contains paths, stage only those paths.
   - Otherwise, review untracked/modified files and stage deliberately.
   - Prefer `git add -A <paths>` over `git add .`.
   - Never stage files that look like secrets (e.g. `.env`, `credentials.json`, private keys).

5. **Detect repo commit conventions (use when present):**
   Commit template: !`git config --get commit.template 2>/dev/null || echo "(none)"`
   - If a commit template or commitlint config exists, follow it.
   - Conventional Commits are optional unless required by repo config.

6. **Generate a commit message (if not provided):**
   - If I provided a message above or in $ARGUMENTS, use it.
   - Otherwise, infer type from changes and write a concise subject (max 50 chars).
   - Add a short body only when it clarifies why.

7. **Commit with the chosen message.**

$ARGUMENTS
