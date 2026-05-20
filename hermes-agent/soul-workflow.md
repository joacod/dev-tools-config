# SOUL Workflow

This guide shows how to use Hermes itself to draft a new `SOUL.md` from the local template in this repo, save the result into the shared workspace, and then install it into Hermes' real home directory.

This workflow exists because, in this setup, Hermes runs inside an ephemeral sandbox. Hermes can write to the shared `/workspace` mount, but it should not be expected to write directly into `~/.hermes/SOUL.md` from inside the sandbox.

## What This Depends On

Before using this workflow, make sure you already configured the shared Docker workspace from the main setup guide.

That setup makes these paths line up:

- inside Hermes: `/workspace/SOUL.md`
- on the VPS host: `/home/hermes/hermes-workspace/SOUL.md`
- final active personality file: `~/.hermes/SOUL.md`

Relevant upstream doc:

- [Hermes Personality & SOUL.md](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality#soulmd)

## Why This Works

Hermes loads its active personality only from `HERMES_HOME/SOUL.md`, which is usually:

```text
~/.hermes/SOUL.md
```

It does not load `SOUL.md` from the current working directory or from `/workspace` automatically.

So the safe pattern here is:

1. Ask Hermes to generate a new soul using the template.
2. Ask Hermes to save the result as `/workspace/SOUL.md`.
3. Copy that file into `~/.hermes/SOUL.md` yourself from the VPS shell.

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

Return the final result as a complete SOUL.md file and save that exact final content to /workspace/SOUL.md.
Do not save a draft, notes, or explanation into the file. Only the final SOUL.md content should be written.

[Paste the full contents of ./SOUL-template.md here]
```

If you have an older soul you want Hermes to incorporate, paste that into the same chat too.

## Verify The Output

After Hermes writes the file, verify it exists on the VPS host:

```sh
ls -l /home/hermes/hermes-workspace/SOUL.md
```

If the file is there and looks right, install it as the active Hermes personality file.

## Install The New SOUL

**Run as:** `hermes` on the VPS

Use the exact command below to copy the generated file into Hermes' real home directory:

```sh
cp /home/hermes/hermes-workspace/SOUL.md ~/.hermes/SOUL.md
```

Start a new Hermes session after copying the file so the updated personality is loaded from the beginning of the prompt.

## Keep The Boundary Clean

Use `SOUL.md` for durable identity and communication defaults.

Keep these elsewhere:

- repo-specific instructions in `AGENTS.md`
- repeatable workflows in skills
- short facts or preferences in Hermes memory
- generated artifacts in the shared workspace
