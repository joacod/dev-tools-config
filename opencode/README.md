# OpenCode

[OpenCode](https://opencode.ai) the open source AI coding agent

## Configuration

Paste the content of `opencode.json` into `/Users/[your-username]/.config/opencode/`

This file includes:

- Settings needed to use local models through [LM Studio](https://lmstudio.ai), official [documentation](https://opencode.ai/docs/providers/#lm-studio)

## Commands

Copy the `commands` folder to `/Users/[your-username]/.config/opencode/commands/`

Available commands:

- `/git-commit`: Stage and commit changes with safety checks and a generated message.
- `/git-push`: Push the current branch with safety checks and optionally create a PR.
