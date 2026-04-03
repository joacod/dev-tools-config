# OpenCode

[OpenCode](https://opencode.ai) is an open source AI coding agent.

## Configuration

Paste the content of `opencode.json` into `/Users/[your-username]/.config/opencode/`

This file includes:

- Settings for using local models through [llama.cpp](https://github.com/ggml-org/llama.cpp) and [LM Studio](https://lmstudio.ai)

Official documentation:

- [llama.cpp provider docs](https://opencode.ai/docs/providers/#llamacpp)
- [LM Studio provider docs](https://opencode.ai/docs/providers/#lm-studio)

## Local llama.cpp Note

If you want to use OpenCode with local models, start with the guide in [`../llama-cpp`](../llama-cpp).

For coding-agent use, OpenCode should connect to a running `llama-server` instance.

Coding tools usually need more prompt space than normal chat, so context size can matter more here than it does for casual terminal use.

## Commands

Copy the `commands` folder to `/Users/[your-username]/.config/opencode/commands/`

Available commands:

| Command | Path | Description |
| --- | --- | --- |
| `/git-commit` | [`commands/git-commit.md`](./commands/git-commit.md) | Stage and commit changes with safety checks and a generated message. |
| `/git-push` | [`commands/git-push.md`](./commands/git-push.md) | Push the current branch with safety checks and optionally create a PR. |

## Custom agents/modes

You can define project-specific custom agents by adding an `.opencode/agent/` folder inside your project.

This makes the custom mode available only for that project.

Copy the `.opencode` folder into your project to try it.

| Name | Scope | Path | Description |
| --- | --- | --- | --- |
| `FunMode` | Project-specific | [`.opencode/agent/funmode.md`](./.opencode/agent/funmode.md) | Example custom mode with a playful, high-personality response style. |

Once copied, init OpenCode and press Tab to switch modes, you should see a new `FunMode` available.
