# Personal workspace setup

This note defines a simple convention for the shared Docker workspace mounted at `/workspace` in the Hermes sandbox.

This is a personal organization choice for this setup, not an official Hermes requirement.

Make sure the whole `~/hermes-workspace` tree is owned by the `hermes` user. If files or folders under it are owned by `root`, Hermes may see `/workspace` mounted correctly but still fail to write inside folders like `/workspace/wikis` or `/workspace/outputs`.

## Recommended layout

```text
~/hermes-workspace/
├── repos/
├── wikis/
├── outputs/
└── inbox/
```

Inside the Docker sandbox, this same structure appears under `/workspace`.

If you use this mount convention, point wiki-backed skills at the shared wiki folder with:

```sh
hermes config set skills.config.wiki.path /workspace/wikis
```

## What each folder is for

- `repos/`: cloned git repositories Hermes works on
- `wikis/`: long-form project or ops documentation that is useful across sessions
- `outputs/`: reports, plans, exports, and other generated deliverables
- `inbox/`: raw material to process later, such as PDFs, transcripts, zip extracts, CSVs, prompts, and copied snippets

## What not to put here

Do not use the shared workspace for things Hermes already stores better elsewhere.

- short durable facts belong in Hermes memory
- repeatable workflows belong in Hermes skills
- project-specific rules belong in each repo's `AGENTS.md`

## Suggested usage

- clone repos into `~/hermes-workspace/repos/`
- create or maintain wiki-style notes in `~/hermes-workspace/wikis/`
- keep generated artifacts in `~/hermes-workspace/outputs/`
- drop unprocessed source material into `~/hermes-workspace/inbox/`

If you want work to persist across Docker-backed Hermes sessions, make sure it is written under `/workspace/...` inside the container.
