# SOUL workflow

This guide shows how to use Hermes itself to update the active `SOUL.md` from the template in this repository.

The workflow below is for the hardened Docker setup, where the host personality file is mounted directly into the persistent default sandbox. A normal local Hermes install does not need this mount; edit `~/.hermes/SOUL.md` directly and follow the upstream [Personality & SOUL.md](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality#soulmd) documentation.

## What this depends on

Before using this workflow, configure the persistent Docker workspace from [Security install](./install.md) and verify the authoritative mount in the [security sanity check](./sanity-check.md).

The active paths are:

- inside the default Hermes sandbox: `/root/.hermes/SOUL.md`
- on the VPS host: `/home/hermes/.hermes/SOUL.md`
- Hermes identity source: `HERMES_HOME/SOUL.md`

## Why this works

Hermes loads its active personality from `HERMES_HOME/SOUL.md`, usually:

```text
~/.hermes/SOUL.md
```

It does not load `SOUL.md` from the current working directory or from `/workspace` automatically. The explicit file bind maps the host file to `/root/.hermes/SOUL.md` inside the default sandbox.

Hermes must not use `write_file` directly on the mounted destination. `write_file` performs an atomic temporary-file rename, and Linux cannot rename over a bind-mount point, so that operation fails with `Device or resource busy`. A normal `cp` opens and overwrites the mounted file in place without replacing the mountpoint.

The safe pattern is:

1. Verify the authoritative file bind is active.
2. Ask Hermes to generate a new soul using the template.
3. Ask Hermes to stage the complete result at `/workspace/outputs/SOUL.proposed.md`.
4. Approve the terminal copy into `/root/.hermes/SOUL.md`.
5. Review the result and start a new session.

## Source template

Use the [SOUL template](../templates/SOUL-template.md) in this repository.

Paste that template directly into the Hermes chat when asking it to create a new soul.

## Recommended prompt

Start a Hermes session and send a prompt like this, with the full template pasted below it.

```text
Create a new version of my SOUL.md using the template pasted below.

Use the template structure, but do not leave placeholders.
Fill it with the most relevant durable personality, tone, working style, and operating preferences you already know about me from our past interactions.

If I provide an older SOUL.md in this chat, use it as reference material too, but improve it instead of copying it blindly.

Focus on durable identity, communication style, pushback style, autonomy boundaries, mission, and operating mode.
Do not fill it with repo-specific instructions, temporary project notes, or file-path conventions unless they clearly belong in a persistent personal identity.

Return the final result as a complete SOUL.md file and save that exact final content to /workspace/outputs/SOUL.proposed.md.
Then request approval to run exactly:
cp -- /workspace/outputs/SOUL.proposed.md /root/.hermes/SOUL.md
Do not use write_file directly on /root/.hermes/SOUL.md because its atomic rename cannot replace the bind-mount point.
Do not save notes or explanation into the proposal. Only the complete final SOUL.md content should be written.

[Paste the full contents of ../templates/SOUL-template.md here]
```

If you have an older soul you want Hermes to incorporate, paste that into the same chat too.

## Apply and verify

After Hermes stages the proposal, approve this command in the terminal tool:

```sh
cp -- /workspace/outputs/SOUL.proposed.md /root/.hermes/SOUL.md
```

Then verify the staged and active files have the same hash without printing their contents:

```sh
sha256sum /workspace/outputs/SOUL.proposed.md /root/.hermes/SOUL.md
```

From the host, verify the authoritative file metadata:

```sh
stat -c '%U:%G %a %s %y %n' /home/hermes/.hermes/SOUL.md
```

Review the resulting file through an approved interface, then start a new Hermes session so the updated personality is loaded from the beginning of the prompt. No separate host-side copy is required.

Because this file controls durable agent behavior, retain a recoverable previous version and explicitly review changes to safety boundaries, permissions, or autonomy.

## Keep the boundary clean

Use `SOUL.md` for durable identity and communication defaults.

Keep these elsewhere:

- repo-specific instructions in `AGENTS.md`
- repeatable workflows in skills
- short facts or preferences in Hermes memory
- generated artifacts in the shared workspace
