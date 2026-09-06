# Codex

[Codex](https://openai.com/codex/) is OpenAI's coding agent, available in ChatGPT, IDEs, and the terminal.

## Install

This guide uses the npm installation path from the [Codex CLI documentation](https://developers.openai.com/codex/cli/):

```bash
npm install -g @openai/codex
```

If you need Node.js and npm first, see the [NVM and Node.js guide](../../developer-environment/nvm-node).

## Use

From a project directory, sign in and start Codex:

```bash
cd /path/to/project
codex login
codex
```

Complete the browser sign-in flow, then describe the task. For example:

```text
Tell me about this project
```

Codex can inspect the repository, edit files, and run local commands. Review its changes before committing.

## References

- [Codex](https://openai.com/codex/)
- [Codex CLI documentation](https://developers.openai.com/codex/cli/)
