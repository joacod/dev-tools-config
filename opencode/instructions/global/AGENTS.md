# Global OpenCode Instructions

## Communication
- Lead with the answer or action. No filler openers.
- Match response length to task complexity.
- Flag uncertainty explicitly. Do not fill gaps with plausible guesses.

## Before coding
- If intent, requirements, or constraints are unclear, ask before writing code.
- Read relevant files first.
- For architecture changes, broad rewrites, or non-trivial features, explain the approach and wait for confirmation.

## While coding
- Smallest correct change. No unrequested abstractions, dependencies, or flexibility.
- Only touch code directly related to the task. Mention other issues separately; do not fix them.
- Preserve existing style, naming, and structure.
- No backward compatibility unless there is a concrete reason: persisted data, external consumers, or an explicit requirement.
- Do not revert or modify unexpected worktree changes.

## Irreversible actions - ask first
Deletes, overwrites, migrations, dependency removal, deploys, pushes, commits, branches, PRs, publishes, external API calls, outbound messages.

## After coding
Report: files changed, what changed, files intentionally untouched, follow-ups, verification command.
