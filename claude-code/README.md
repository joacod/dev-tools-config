# Claude Code

[Claude Code](https://claude.com/product/claude-code) is an agentic coding tool by Anthropic that lives in your terminal.

## Subagents

Subagents are specialized agents that Claude Code can delegate tasks to. Each subagent is defined in a Markdown file (`.md`).

When Claude Code encounters a task that matches a subagent's description, it can launch that subagent to handle the work autonomously. Subagents run with their own context and return results back to the main conversation.

### Making an agent available globally

To make an agent available across all your projects, copy the `.md` file to your global agents directory:

```bash
cp agents/senior-code-reviewer.md ~/.claude/agents/
```

### Making an agent available per-project

To make an agent available only within a specific project, copy the `.md` file to the `.claude/agents/` directory inside the project repo:

```bash
mkdir -p .claude/agents
cp agents/senior-code-reviewer.md .claude/agents/
```

## Instructions

Claude Code reads `CLAUDE.md` files for persistent instructions. Use global instructions for behavior that should apply everywhere, and project instructions for repository-specific context and stack choices.

### Global instructions

Copy the global template to `~/.claude/CLAUDE.md`:

```bash
cp instructions/global/CLAUDE.md ~/.claude/CLAUDE.md
```

The global template focuses on reusable behavior:

- Ask before assuming
- Prefer the simplest correct change
- Avoid touching unrelated code
- Flag uncertainty explicitly
- Confirm before destructive or external actions

### Project instructions

Copy the project template into a repo that needs project-specific Claude Code context:

```bash
cp instructions/project/CLAUDE.md /path/to/project/CLAUDE.md
```

Use project instructions for:

- Project goals and audience
- Stack and tooling constraints
- Permanent architectural facts
- Project-specific behavior rules

Do not put project-specific stack choices in the global file. A decision that is correct for one repository may be wrong for another.

## MCP

Claude Code supports MCP servers, which let it connect to external tools and capabilities.

For example, you can install the Playwright MCP server with:

```bash
claude mcp add playwright npx @playwright/mcp@latest
```

## Available Agents

| Name | Path | Description |
| --- | --- | --- |
| Senior Code Reviewer | [`agents/senior-code-reviewer.md`](./agents/senior-code-reviewer.md) | Reviews code for quality, reuse, and efficiency. |

## Available Instruction Templates

| Scope | Path | Description |
| --- | --- | --- |
| Global | [`instructions/global/CLAUDE.md`](./instructions/global/CLAUDE.md) | Reusable Claude Code behavior and safety rules. |
| Project | [`instructions/project/CLAUDE.md`](./instructions/project/CLAUDE.md) | Project-specific context, stack, and behavior rules. |
