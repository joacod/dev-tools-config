---
description: Stage and commit changes with a safe, generated message
argument-hint: "[paths|sync|rebase|message]"
---

Before committing, follow these steps in order. Use the bash tool to run each command and inspect its output:

1. **Review local changes first:**
   - `git status --short`
   - `git diff --stat`
   - `git diff --cached --stat`

2. **Check branch and upstream (if any):**
   - Current branch: `git branch --show-current`
   - Upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "(none)"`

3. **Only sync if asked or clearly needed:**
   - Sync only if the user-provided arguments include `sync` or `rebase`, or if an upstream exists and the branch is behind.
   - If syncing is needed, run `git fetch origin 2>/dev/null`.
   - Check the behind count with `git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0"`.
   - If the branch is behind, run `git pull --rebase origin <current-branch>`.
   - If there are conflicts, stop and notify the user.

4. **Decide what to stage (avoid secrets and generated files):**
   - If the user-provided arguments contain paths, stage only those paths.
   - Otherwise, review untracked and modified files and stage deliberately.
   - Prefer `git add -A <paths>` over `git add .`.
   - Never stage files that look like secrets, such as `.env`, `credentials.json`, or private keys.

5. **Detect repository commit conventions (use when present):**
   - Check the commit template with `git config --get commit.template 2>/dev/null || echo "(none)"`.
   - If a commit template or commitlint configuration exists, follow it.
   - Conventional Commits are optional unless required by repository configuration.

6. **Generate a commit message (if not provided):**
   - If the user provided a message in the request or arguments below, use it.
   - Otherwise, infer the type from the changes and write a concise subject of at most 50 characters.
   - Add a short body only when it clarifies why.

7. **Commit with the chosen message.** Follow any higher-priority project or global safety instructions, including confirmation requirements.

User-provided arguments:
$ARGUMENTS
