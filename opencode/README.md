# OpenCode

[OpenCode](https://opencode.ai) is an open source AI coding agent.

## Configuration

Copy the config examples from [`./config`](./config) into `~/.config/opencode/`.

- Copy [`config/opencode.json`](./config/opencode.json) to `~/.config/opencode/opencode.json`
- Copy [`config/tui.json`](./config/tui.json) to `~/.config/opencode/tui.json`

`opencode.json` contains runtime, provider, and MCP settings.

`tui.json` contains TUI-only settings like `theme` and keybinds.

The runtime config example includes:

- Settings for using local models through [llama.cpp](https://github.com/ggml-org/llama.cpp) and [LM Studio](https://lmstudio.ai)
- Playwright MCP configuration for local server using `@playwright/mcp@latest`

Relevant documentation:

- [llama.cpp provider docs](https://opencode.ai/docs/providers/#llamacpp)
- [LM Studio provider docs](https://opencode.ai/docs/providers/#lm-studio)

## Instructions

OpenCode reads `AGENTS.md` files for persistent instructions. Use global instructions for behavior that should apply everywhere, and project instructions for repository-specific context and stack choices.

### Global instructions

Copy the global template to `~/.config/opencode/AGENTS.md`:

```bash
cp instructions/global/AGENTS.md ~/.config/opencode/AGENTS.md
```

The global template focuses on reusable behavior:

- Ask before assuming
- Prefer the simplest correct change
- Avoid touching unrelated code
- Flag uncertainty explicitly
- Confirm before destructive or external actions

### Project instructions

Copy the project template into a repo that needs project-specific OpenCode context:

```bash
cp instructions/project/AGENTS.md /path/to/project/AGENTS.md
```

Use project instructions for:

- Project goals and audience
- Stack and tooling constraints
- Permanent architectural facts
- Project-specific behavior rules

Do not put project-specific stack choices in the global file. A decision that is correct for one repository may be wrong for another.

### Available instruction templates

| Scope | Path | Description |
| --- | --- | --- |
| Global | [`instructions/global/AGENTS.md`](./instructions/global/AGENTS.md) | Reusable OpenCode behavior and safety rules. |
| Project | [`instructions/project/AGENTS.md`](./instructions/project/AGENTS.md) | Project-specific context, stack, and behavior rules. |

### Extra

Prefer `AGENTS.md` for OpenCode-specific setup. Use the `instructions` field in `opencode.json` only when you want to load extra non-standard files such as `CONTRIBUTING.md`, `docs/guidelines.md`, or globbed rule files.

## Local llama.cpp note

If you want to use OpenCode with local models, start with the [llama.cpp guide in the local-ai repository](https://github.com/joacod/local-ai/tree/main/llama-cpp).

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
