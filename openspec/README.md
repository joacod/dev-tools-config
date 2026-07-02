# OpenSpec

[OpenSpec](https://openspec.dev/) is a lightweight spec-driven workflow for AI coding agents.

Use it when a task is large enough that a normal prompt would be too vague, risky, or easy for the agent to misinterpret.

**Agree on what to build before asking the agent to build it.**

## Daily Workflow

Use one focused OpenSpec change at a time.

### 1. Validate the Change

Run this in the terminal:

```sh
openspec validate foundation-001
```

The name is the folder under:

```text
openspec/changes/foundation-001/
```

### 2. Apply the Change

Run this inside the AI coding assistant chat:

```text
/opsx:apply foundation-001
```

This means:

```text
Implement the incomplete tasks inside openspec/changes/foundation-001/tasks.md
using that change's proposal, design, and specs as context.
```

### 3. Review Against the Spec

After implementation, ask the agent to review only that change:

```text
Review the implementation against openspec/changes/foundation-001.
Check for missing tasks, spec drift, shortcuts, weak tests, and broken assumptions.
Do not make unrelated improvements.
```

Fix only issues that belong to the active OpenSpec change.

### 4. Archive the Change

When the implementation is complete, tested, and reviewed, run this inside the AI coding assistant chat:

```text
/opsx:archive foundation-001
```

Archive merges the completed change specs into `openspec/specs/` and moves the change into the archive.

## Change Naming

OpenSpec change names must start with a letter.

Use numeric ordering as a suffix:

```text
foundation-001
data-model-002
domain-logic-003
ui-shell-004
feature-workflow-005
polish-006
verification-007
```

Do not put the number first. OpenSpec rejects change names that start with a number.

## Terminal Commands vs AI Chat Commands

Run OpenSpec CLI commands in the terminal:

```sh
openspec init
openspec update
openspec list
openspec show <change-name>
openspec validate <change-name>
openspec view
openspec archive <change-name>
```

Run `/opsx:*` commands inside the AI coding assistant chat:

```text
/opsx:explore
/opsx:propose <change-name>
/opsx:apply <change-name>
/opsx:archive <change-name>
```

Do not type `/opsx:*` commands in the terminal.

## Keep Specs and Tasks Separate

```text
specs define behavior
tasks define execution
```

If something in `tasks.md` changes product behavior, it should also be represented in `specs/`.

## More Detail

See [`DETAILS.md`](DETAILS.md) for the longer reference guide, including the mental model, larger workflows, common checks, mistakes, and command reference.
