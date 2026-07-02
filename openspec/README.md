# OpenSpec

[OpenSpec](https://openspec.dev/) is a lightweight spec-driven development workflow for AI coding agents.

Use it when a task is large enough that a normal prompt would be too vague, risky, or easy for the agent to misinterpret.

The goal is simple:

```text
Agree on what to build before asking the agent to build it
```

## What This Setup Does

This guide covers the practical OpenSpec loop for planning, implementing, verifying, and archiving agent-driven changes.

- **Separates current behavior from proposed changes:** current specs live in `openspec/specs/`, active changes live in `openspec/changes/`
- **Uses specs for behavior:** product requirements belong in spec files, not hidden inside task checklists
- **Uses tasks for execution:** `tasks.md` tells the agent what to implement and in what order
- **Keeps changes reviewable:** one OpenSpec change should be small enough to validate, test, and archive as one unit

**Result:** you get a clearer agent workflow where the intended behavior is agreed before implementation starts.

## Mental Model

OpenSpec separates the current system from proposed changes.

```text
openspec/
  specs/      # current source of truth
  changes/    # proposed changes in progress
```

A change usually looks like this:

```text
openspec/changes/add-feature/
  proposal.md
  design.md
  tasks.md
  specs/
    feature/spec.md
```

Use this meaning:

| File | Purpose |
| --- | --- |
| `proposal.md` | Why this change exists and what it should include |
| `specs/` | Product behavior and requirements being added or changed |
| `design.md` | Technical approach and important decisions |
| `tasks.md` | Implementation checklist for the agent |

The important rule:

```text
specs define behavior
tasks define execution
```

If something in `tasks.md` changes how the product behaves, it should also be represented in `specs/`.

## Terminal Commands vs AI Chat Commands

OpenSpec has two types of commands.

Run these in the terminal:

```sh
openspec init
openspec update
openspec list
openspec show <change-name>
openspec validate <change-name>
openspec view
openspec archive <change-name>
```

Run these inside the AI coding assistant chat:

```text
/opsx:explore
/opsx:propose <change-name>
/opsx:apply <change-name>
/opsx:verify <change-name>
/opsx:archive <change-name>
```

Do not type `/opsx:*` commands in the terminal. They are chat commands for the agent.

The default OpenSpec profile includes `/opsx:explore`, `/opsx:propose`, `/opsx:apply`, `/opsx:sync`, and `/opsx:archive`. Expanded workflow commands such as `/opsx:verify`, `/opsx:new`, `/opsx:continue`, and `/opsx:ff` can be enabled with `openspec config profile` and `openspec update`.

## Basic Workflow

### 1. Initialize OpenSpec

```sh
npm install -g @fission-ai/openspec@latest
openspec init
```

Choose the assistant you use in the project.

### 2. Explore Before Creating a Change

Use this when the work is not clear yet:

```text
/opsx:explore
```

Good for:

- understanding the codebase
- comparing options
- shaping a fuzzy idea into a concrete change
- deciding the right implementation order

No code should be written during exploration.

### 3. Create a Change

When the scope is clear:

```text
/opsx:propose add-feature-name
```

This should create:

```text
openspec/changes/add-feature-name/
  proposal.md
  design.md
  tasks.md
  specs/
```

Review the generated files before implementation.

### 4. Validate the Change

From the terminal:

```sh
openspec show add-feature-name
openspec validate add-feature-name
```

Check that:

- the change name is specific
- `proposal.md` explains the intent
- `specs/` contains the product behavior
- `design.md` explains the approach
- `tasks.md` is small enough to execute safely

### 5. Apply the Change

In the AI assistant chat:

```text
/opsx:apply add-feature-name
```

The name is the folder under:

```text
openspec/changes/<change-name>/
```

It does not refer to a task inside `tasks.md`.

`/opsx:apply add-feature-name` means:

```text
implement the incomplete tasks inside openspec/changes/add-feature-name/tasks.md
using that change's proposal, design, and specs as context
```

### 6. Test and Review

After apply finishes, run the relevant project checks. For a JavaScript or TypeScript project, that often means:

```sh
npm run typecheck
npm run test
npm run lint
```

Then ask the agent to review against the spec:

```text
Review the implementation against openspec/changes/add-feature-name.
Check for missing tasks, spec drift, shortcuts, weak tests, and broken assumptions.
Do not make unrelated improvements.
```

Fix only what belongs to that change.

### 7. Commit the Implementation

```sh
git diff
git add .
git commit -m "feat: implement add-feature-name"
```

### 8. Archive the Change

When the change is implemented, tested, and reviewed:

```text
/opsx:archive add-feature-name
```

Archive merges the change specs into the main `openspec/specs/` source of truth and moves the completed change into the archive.

Then commit the archive:

```sh
git add .
git commit -m "docs: archive add-feature-name"
```

## Recommended Loop

Use one focused session per change.

```text
1. Start a fresh AI assistant session
2. Pick one OpenSpec change
3. Review proposal, specs, design, and tasks
4. Run /opsx:apply <change-name>
5. Run tests, typecheck, and lint
6. Ask for review against the spec
7. Fix scoped issues
8. Commit implementation
9. Run /opsx:archive <change-name>
10. Commit archive
11. Start a new session for the next change
```

This keeps context clean and avoids the agent mixing unrelated work.

## Working With Large Projects

For a full project, do not create one giant change.

Prefer several ordered changes:

```text
001-foundation
002-data-model
003-domain-logic
004-ui-shell
005-feature-workflow
006-polish
007-verification
```

Then execute them in that order:

```text
/opsx:apply 001-foundation
/opsx:archive 001-foundation

/opsx:apply 002-data-model
/opsx:archive 002-data-model
```

Use numeric prefixes when order matters.

The order is not automatically taken from every `tasks.md` file. The order should be made explicit through change names, dependencies, or your own project plan.

## Good Change Size

A good OpenSpec change should be small enough to review and archive as one unit.

Good examples:

```text
add-password-reset
create-billing-schema
implement-approval-flow
add-dashboard-filters
```

If a change has many unrelated sections in `tasks.md`, split it into smaller changes before implementation.

## Common Checks Before Apply

Before running `/opsx:apply`, ask:

```text
Review this OpenSpec change before implementation.

Check tasks.md against proposal.md, design.md, and specs/.
If tasks.md contains behavior or acceptance criteria missing from specs, update the spec delta first.
If it is only implementation detail, leave it in tasks.md.

Do not implement code yet.
```

Then apply only when the artifacts look correct.

## Common Mistakes

### Archiving Too Early

Do not archive until the whole change is implemented.

If only half of `tasks.md` is complete, keep the change active.

### Letting Tasks Become Hidden Specs

Implementation details can live only in `tasks.md`.

Product behavior should live in `specs/`.

### Keeping Huge Changes

If one change contains a full project, split it into smaller ordered changes.

## Useful Commands

| Command | Where | Use |
| --- | --- | --- |
| `openspec init` | Terminal | Initialize OpenSpec in a project |
| `openspec update` | Terminal | Regenerate assistant instruction files after config or CLI changes |
| `openspec list` | Terminal | List active changes |
| `openspec show <change>` | Terminal | Inspect a change |
| `openspec validate <change>` | Terminal | Validate formatting and structure |
| `openspec archive <change>` | Terminal | Archive a completed change from the CLI |
| `/opsx:explore` | AI chat | Think before creating artifacts |
| `/opsx:propose <change>` | AI chat | Create a new change |
| `/opsx:apply <change>` | AI chat | Implement a change |
| `/opsx:verify <change>` | AI chat | Check implementation against artifacts |
| `/opsx:archive <change>` | AI chat | Finalize and archive a completed change |

## References

- [OpenSpec GitHub](https://github.com/Fission-AI/OpenSpec)
- [OpenSpec Getting Started](https://github.com/Fission-AI/OpenSpec/blob/main/docs/getting-started.md)
- [OpenSpec Commands](https://github.com/Fission-AI/OpenSpec/blob/main/docs/commands.md)
- [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec/blob/main/docs/cli.md)
- [OpenSpec Workflows](https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md)
