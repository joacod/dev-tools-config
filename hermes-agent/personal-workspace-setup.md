# Personal Workspace Setup

This note defines a simple convention for the shared Docker workspace mounted at `/workspace` in the Hermes sandbox.

This is a personal organization choice for this setup, not an official Hermes requirement.

## Recommended Layout

```text
~/hermes-workspace/
├── repos/
├── wikis/
├── outputs/
└── inbox/
```

Inside the Docker sandbox, this same structure appears under `/workspace`.

## What Each Folder Is For

- `repos/`: cloned git repositories Hermes works on
- `wikis/`: long-form project or ops documentation that is useful across sessions
- `outputs/`: reports, plans, exports, and other generated deliverables
- `inbox/`: raw material to process later, such as PDFs, transcripts, zip extracts, CSVs, prompts, and copied snippets

## What Not To Put Here

Do not use the shared workspace for things Hermes already stores better elsewhere.

- short durable facts belong in Hermes memory
- repeatable workflows belong in Hermes skills
- project-specific rules belong in each repo's `AGENTS.md`

## Suggested Usage

- clone repos into `~/hermes-workspace/repos/`
- create or maintain wiki-style notes in `~/hermes-workspace/wikis/`
- keep generated artifacts in `~/hermes-workspace/outputs/`
- drop unprocessed source material into `~/hermes-workspace/inbox/`
