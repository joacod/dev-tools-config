# SOUL Workflow

This guide shows how to use Hermes itself to update the active `SOUL.md` from the local template in this repo.

The host personality file is mounted directly into the persistent default sandbox, so Hermes can update the authoritative file without a manual copy step.

## What This Depends On

Before using this workflow, configure the persistent Docker workspace from [Install Hermes Agent](./install.md) and verify the authoritative mount in [Sanity Check](./sanity-check.md).

The active paths are:

- inside the default Hermes sandbox: `/root/.hermes/SOUL.md`
- on the VPS host: `/home/hermes/.hermes/SOUL.md`
- gateway identity source: `HERMES_HOME/SOUL.md`

Relevant upstream doc:

- [Hermes Personality & SOUL.md](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality#soulmd)

## Why This Works

Hermes loads its active personality only from `HERMES_HOME/SOUL.md`, which is usually:

```text
~/.hermes/SOUL.md
```

It does not load `SOUL.md` from the current working directory or from `/workspace` automatically. The explicit file bind maps the host file to the path Hermes edits inside the default sandbox.

So the safe pattern here is:

1. Verify the authoritative file bind is active.
2. Ask Hermes to generate a new soul using the template.
3. Ask Hermes to save the result as `/root/.hermes/SOUL.md`.
4. Review the change and start a new session.

## Source Template

Use the template in this repo:

- [SOUL Template](./SOUL-template.md)

Paste that template directly into the Hermes chat when asking it to create a new soul.

## Recommended Prompt

Start a Hermes session and send a prompt like this, with the full template pasted below it.

```text
Create a new version of my SOUL.md using the template pasted below.

Use the template structure, but do not leave placeholders.
Fill it with the most relevant durable personality, tone, working style, and operating preferences you already know about me from our past interactions.

If I provide an older SOUL.md in this chat, use it as reference material too, but improve it instead of copying it blindly.

Focus on durable identity, communication style, pushback style, autonomy boundaries, mission, and operating mode.
Do not fill it with repo-specific instructions, temporary project notes, or file-path conventions unless they clearly belong in a persistent personal identity.

Return the final result as a complete SOUL.md file and save that exact final content to /root/.hermes/SOUL.md.
Do not save a draft, notes, or explanation into the file. Only the final SOUL.md content should be written.

[Paste the full contents of ./SOUL-template.md here]
```

If you have an older soul you want Hermes to incorporate, paste that into the same chat too.

## Verify The Output

After Hermes writes the file, verify the authoritative host file metadata:

```sh
stat -c '%U:%G %a %s %y %n' /home/hermes/.hermes/SOUL.md
```

Review the resulting file through an approved interface, then start a new Hermes session so the updated personality is loaded from the beginning of the prompt. No host-side copy is required.

Because this file controls durable agent behavior, retain a recoverable previous version and explicitly review changes to safety boundaries, permissions, or autonomy.

## Keep The Boundary Clean

Use `SOUL.md` for durable identity and communication defaults.

Keep these elsewhere:

- repo-specific instructions in `AGENTS.md`
- repeatable workflows in skills
- short facts or preferences in Hermes memory
- generated artifacts in the shared workspace
