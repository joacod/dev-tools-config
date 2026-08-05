# Pi

[Pi](https://pi.dev/) is a minimal terminal coding harness. Its core stays small and can be extended with skills, extensions, prompt templates, themes, and Pi packages.

## Installation

Install Pi globally with npm:

```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Start it from the project directory where it should work:

```bash
cd /path/to/project
pi
```

## Authentication

Use `/login` inside Pi to authenticate with a supported subscription provider or to store an API key.

Pi stores credentials from `/login` in `~/.pi/agent/auth.json`. Keep that file private and out of version control.

See the [provider documentation](https://pi.dev/docs/latest/providers) for supported providers and environment variables.

## Basic Usage

Start an interactive session and type a request:

```text
Summarize this repository and tell me how to run its checks.
```

Pi can read and modify files and run shell commands in the current working directory.

### Useful Commands

| Command | Purpose |
| --- | --- |
| `/login` | Authenticate or manage provider credentials. |
| `/model` | Select a model. `Ctrl+L` opens the same selector. |
| `/settings` | Change interactive and model settings. |
| `/resume` | Browse previous sessions. |
| `/tree` | Navigate through the current session's branches. |
| `/reload` | Reload context files, skills, extensions, prompts, and themes. |
| `/quit` | Exit Pi. |

Use `@` in the editor to search for and reference project files. Files can also be passed on the command line:

```bash
pi @README.md "Summarize this file"
pi @src/app.ts @src/app.test.ts "Review these files together"
```

Run a shell command and send its output to the model with `!`:

```text
!npm test
```

Use `!!command` to run a command without adding its output to the model context.

## Model Effort and Thinking Level

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

## Project Instructions

Pi loads context files when it starts:

- `~/.pi/agent/AGENTS.md` for global instructions
- `AGENTS.md` or `CLAUDE.md` from parent directories and the current project
- `AGENTS.override.md` when a directory needs to replace its normal context file

Use these files for project conventions, commands, safety rules, and preferences. Run `/reload` after changing them during a session.

## Security

Pi runs with the permissions of the user who starts it and does not include a built-in sandbox. Project trust controls whether project-local Pi settings and resources are loaded, but it does not restrict file access or shell commands.

Review project instructions, skills, extensions, and packages before using them. Use a container, VM, or other sandbox for untrusted repositories or unattended work. See the [security documentation](https://pi.dev/docs/latest/security) for details.

## Further Reading

- [Pi documentation](https://pi.dev/docs/latest)
- [Quickstart](https://pi.dev/docs/latest/quickstart)
- [Using Pi](https://pi.dev/docs/latest/usage)
- [Providers](https://pi.dev/docs/latest/providers)
- [Skills](https://pi.dev/docs/latest/skills)
- [Pi packages](https://pi.dev/docs/latest/packages)
