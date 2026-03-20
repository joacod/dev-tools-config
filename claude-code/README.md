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

## Available Agents

- [Senior Code Reviewer](agents/senior-code-reviewer.md) — Reviews code for quality, reuse, and efficiency.
