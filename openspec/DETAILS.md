# OpenSpec details

This file contains more details and OpenSpec reference material.

## What this setup does

This guide covers the practical OpenSpec loop for planning, implementing, verifying, and archiving agent-driven changes.

- **Separates current behavior from proposed changes:** current specs live in `openspec/specs/`, active changes live in `openspec/changes/`
- **Uses specs for behavior:** product requirements belong in spec files, not hidden inside task checklists
- **Uses tasks for execution:** `tasks.md` tells the agent what to implement and in what order
- **Keeps changes reviewable:** one OpenSpec change should be small enough to validate, test, and archive as one unit

## Mental model

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

## Creating a change

When the scope is clear, run this inside the AI coding assistant chat:

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

## Exploring first

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

## Working with large projects

For a full project, do not create one giant change.

Prefer several ordered changes:

```text
foundation-001
data-model-002
domain-logic-003
ui-shell-004
feature-workflow-005
polish-006
verification-007
```

Then execute them in that order:

```text
/opsx:apply foundation-001
/opsx:archive foundation-001

/opsx:apply data-model-002
/opsx:archive data-model-002
```

Use numeric suffixes when order matters. OpenSpec change names must start with a letter.

The order is not automatically taken from every `tasks.md` file. The order should be made explicit through change names, dependencies, or your own project plan.

## Good change size

A good OpenSpec change should be small enough to review and archive as one unit.

Good examples:

```text
add-password-reset
create-billing-schema
implement-approval-flow
add-dashboard-filters
```

If a change has many unrelated sections in `tasks.md`, split it into smaller changes before implementation.

## Common checks before apply

Before running `/opsx:apply`, ask:

```text
Review this OpenSpec change before implementation.

Check tasks.md against proposal.md, design.md, and specs/.
If tasks.md contains behavior or acceptance criteria missing from specs, update the spec delta first.
If it is only implementation detail, leave it in tasks.md.

Do not implement code yet.
```

Then apply only when the artifacts look correct.

## Common mistakes

### Archiving too early

Do not archive until the whole change is implemented.

If only half of `tasks.md` is complete, keep the change active.

### Letting tasks become hidden specs

Implementation details can live only in `tasks.md`.

Product behavior should live in `specs/`.

### Keeping huge changes

If one change contains a full project, split it into smaller ordered changes.

## Useful commands

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
| `/opsx:archive <change>` | AI chat | Finalize and archive a completed change |

The default OpenSpec profile includes `/opsx:explore`, `/opsx:propose`, `/opsx:apply`, `/opsx:sync`, and `/opsx:archive`. Expanded workflow commands such as `/opsx:verify`, `/opsx:new`, `/opsx:continue`, and `/opsx:ff` can be enabled with `openspec config profile` and `openspec update`.

## References

- [OpenSpec GitHub](https://github.com/Fission-AI/OpenSpec)
- [OpenSpec Getting Started](https://github.com/Fission-AI/OpenSpec/blob/main/docs/getting-started.md)
- [OpenSpec Commands](https://github.com/Fission-AI/OpenSpec/blob/main/docs/commands.md)
- [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec/blob/main/docs/cli.md)
- [OpenSpec Workflows](https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md)
