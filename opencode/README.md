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

## Custom agents/modes

You can define project-specific custom agents by adding an `.opencode/agent/` folder inside your project.

This makes the custom mode available only for that project.

Copy the `.opencode` folder into your project to try it.

- Example: `[your-project]/.opencode/agent/funmode.md`

Once copied, init OpenCode and press Tab to switch modes, you should see a new `FunMode` available.
