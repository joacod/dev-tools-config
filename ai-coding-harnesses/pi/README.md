# Pi

[Pi](https://pi.dev/) is a minimal terminal coding harness. Its core stays small and can be extended with skills, extensions, prompt templates, themes, and Pi packages.

For a new setup, follow this guide in order: install Pi, authenticate, start it from a project root, review the project's instructions, and then add optional integrations such as [Playwright MCP](./mcp-playwright.md). See the [MCP catalog](./mcps.md) for the integrations currently used here.

## Installation

Pi requires Node.js and npm. Use an LTS release; the repository's [NVM and Node.js guide](../../developer-environment/nvm-node) covers that setup.

Install Pi globally with npm:

```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Verify the installation:

```bash
pi --version
```

Start it from the project directory where it should work:

```bash
cd /path/to/project
pi
```

## Configuration

Copy [`config/models.json`](./config/models.json) to `~/.pi/agent/models.json` when creating the file. If `models.json` already contains custom providers, merge the `mtplx` entry under `providers` instead of replacing the existing file.

The example adds an OpenAI-compatible MTPLX provider at `http://127.0.0.1:8000/v1` and registers `mtplx-qwen38-27b-optimized-speed`. With the MTPLX server running, select the model with `/model` or `Ctrl+L`, then choose `mtplx/mtplx-qwen38-27b-optimized-speed`. The local `mtplx-local` key is only a compatibility value; no remote API key is required.

Pi reloads `models.json` when you open `/model`, so you do not need to restart after editing the file.

## Authentication

Use `/login` inside Pi to authenticate with a supported subscription provider or to store an API key.

Pi stores credentials from `/login` in `~/.pi/agent/auth.json`. Keep that file private and out of version control.

See the [provider documentation](https://pi.dev/docs/latest/providers) for supported providers and environment variables.

## Basic usage

Start an interactive session and type a request:

```text
Summarize this repository and tell me how to run its checks.
```

Pi can read and modify files and run shell commands in the current working directory.

### Useful commands

| Command | Purpose |
| --- | --- |
| `/login` | Authenticate or manage provider credentials. |
| `/model` | Select a model. `Ctrl+L` opens the same selector. |
| `/settings` | Change interactive and model settings. |
| `/resume` | Browse previous sessions. |
| `/tree` | Navigate through the current session's branches. |
| `/session` | Show the current session file, ID, usage, and cost. |
| `/trust` | Save the project trust decision for future sessions. |
| `/reload` | Reload context files, skills, extensions, prompts, and themes. |
| `/mcp` | Inspect MCP servers when `pi-mcp-adapter` is installed. |
| `/quit` | Exit Pi. |

Use `@` in the editor to search for and reference project files. Files can also be passed on the command line:

```bash
pi @README.md "Summarize this file"
pi @src/app.ts @src/app.test.ts "Review these files together"
```

## Reusable commands

Pi's file-backed slash commands are called **prompt templates**. The templates in [`prompts/`](./prompts) provide reusable git workflows.

Install them globally:

```bash
# Run from this repository's root.
mkdir -p ~/.pi/agent/prompts
cp ai-coding-harnesses/pi/prompts/*.md ~/.pi/agent/prompts/
```

Restart Pi or run `/reload` afterward. To keep them project-local, copy them into that repository's `.pi/prompts/` directory instead.

| Command | Description |
| --- | --- |
| `/git-commit` | Stage and commit changes with safety checks and a generated message. |
| `/git-push` | Push the current branch with safety checks and optionally create a PR. |

Prompt templates expand into prompts. These templates tell Pi to run the checks through its bash tool.

Run a shell command and send its output to the model with `!`:

```text
!npm test
```

Use `!!command` to run a command without adding its output to the model context.

## Recommended working loop

1. Start Pi from the repository root so it sees the intended project files and local configuration.
2. Let Pi inspect the relevant `README.md`, `AGENTS.md`, `CLAUDE.md`, and existing code before making changes.
3. Ask for a short plan when the task spans multiple files, then keep the requested scope explicit.
4. Review the generated diff and ask Pi to explain any surprising change before accepting it.
5. Run the repository's documented checks yourself; for this repository, start with `git diff --check`.
6. Use `/reload` after changing instructions, skills, prompts, or extensions. Restart Pi after installing packages or changing integrations that initialize at startup.

## Model effort and thinking level

Pi calls a model's reasoning effort its **thinking level**. This is separate from selecting the model itself:

- Use `/model` or `Ctrl+L` to choose a model.
- Use `/settings` to change the thinking level used by the interactive session.
- Use `Shift+Tab` to cycle the thinking level while working.

The documented thinking levels are `off`, `minimal`, `low`, `medium`, `high`, `xhigh`, and `max`. To persist a default, set `defaultThinkingLevel` in the global `~/.pi/agent/settings.json` or project `.pi/settings.json`:

```json
{
  "defaultThinkingLevel": "medium"
}
```

Project settings override global settings. See the [Pi settings documentation](https://pi.dev/docs/latest/settings) for the complete configuration reference.

## Project instructions

Pi loads context files when it starts:

- `~/.pi/agent/AGENTS.md` for global instructions
- `AGENTS.md` or `CLAUDE.md` from parent directories and the current project
- `AGENTS.override.md` when a directory needs to replace its normal context file

Use these files for project conventions, commands, safety rules, and preferences. Run `/reload` after changing them during a session.

## Security

Pi runs with the permissions of the user who starts it and does not include a built-in sandbox. Project trust controls whether project-local Pi settings and resources are loaded, but it does not restrict file access or shell commands.

Review project instructions, skills, extensions, packages, and MCP configuration before using them. `--approve` and `/trust` allow project-local resources to load; they are trust decisions, not a sandbox. Use a container, VM, or other sandbox for untrusted repositories or unattended work. See the [security documentation](https://pi.dev/docs/latest/security) for details.

## MCP integrations

Pi does not include MCP in its core. The [MCP catalog](./mcps.md) tracks the integrations currently used here, including Context7 and GitHub. The [Playwright MCP guide](./mcp-playwright.md) documents global and project-local setups using `pi-mcp-adapter`, the official `@playwright/mcp` server, and approval gates for destructive or credential-related tool names. MCP servers inherit Pi's user permissions, so review their commands and keep secrets out of MCP configuration files.

## Further reading

- [Pi documentation](https://pi.dev/docs/latest)
- [Quickstart](https://pi.dev/docs/latest/quickstart)
- [Using Pi](https://pi.dev/docs/latest/usage)
- [Providers](https://pi.dev/docs/latest/providers)
- [Custom models](https://pi.dev/docs/latest/models)
- [Prompt templates](https://pi.dev/docs/latest/prompt-templates)
- [Skills](https://pi.dev/docs/latest/skills)
- [Pi packages](https://pi.dev/docs/latest/packages)
- [MCP catalog](./mcps.md)
- [Playwright MCP setup](./mcp-playwright.md)
