# Repository Instructions

## Project
- **Name:** Developer Tools
- **Goal:** Maintain personal setup notes, copyable agent configurations, and operational guides for developer tools, local model runtimes, and VPS services.
- **Avoid:** Treating this as a runnable application or adding root-level package/build tooling; do not run setup, install, model-download, server, SSH, `sudo`, or destructive examples just to validate documentation.

## Stack
- **Language:** Markdown, Bash, Python, JSON, and tool-specific configuration formats
- **Framework:** None
- **Package manager:** None at the repository root; individual guides document external tools
- **Database:** None
- **Testing:** No repository-wide suite; use the static checks in Commands
- **Styling:** Markdown with relative links, short README entrypoints, and linked detail guides

## Commands
- **Install:** None at the repository root
- **Dev:** None
- **Test:** `git diff --check`; also run `bash -n` for changed shell scripts, `python3 -m py_compile` for changed Python files, and `python3 -m json.tool <file> >/dev/null` for changed JSON
- **Lint:** None
- **Typecheck:** None
- **Build:** None

## Repository layout
- Group tool directories under the category containers `ai-coding-harnesses/`, `ai-agents-workflows/`, `ai-apis-services/`, `developer-environment/`, and `server-infrastructure/`.
- Keep category containers organizational; do not add individual tool directories at the repository root.
- Local AI remains an external repository linked from the root `README.md` until this repository has local notes for it.

## Permanent facts
- Each tool directory is independent, and its own `README.md` is its local entry point where present.
- Update the root `README.md` when adding, moving, or removing a category or tool. When moving content, update every affected relative link and repository-root path.
- `ai-coding-harnesses/opencode/` and `ai-coding-harnesses/claude-code/` contain copyable templates and examples, not active user configuration. Preserve placeholders in `ai-coding-harnesses/opencode/instructions/*/AGENTS.md` and `ai-coding-harnesses/claude-code/instructions/*/CLAUDE.md`.
- Keep API keys, passwords, private SSH keys, model caches, `__pycache__`, and generated local-AI virtual environments out of tracked changes. The external [`local-ai`](https://github.com/joacod/local-ai) repository's [MLX setup script](https://github.com/joacod/local-ai/blob/main/mlx/setup-mlx.sh) creates or updates `mlx/venv` on Apple Silicon.
- The external [MLX launcher](https://github.com/joacod/local-ai/blob/main/mlx/run-mlx-server.sh) and [llama.cpp launcher](https://github.com/joacod/local-ai/blob/main/llama-cpp/run-llama-server.sh) both bind local port `8080`; OpenCode's MLX and llama.cpp providers use `http://127.0.0.1:8080/v1`, so run only one backend there at a time.
- The external [`local-ai`](https://github.com/joacod/local-ai) repository is focused on practical Apple Silicon local-model setup and notes, not benchmarking, leaderboards, or runtime comparisons.
- Preserve local-machine/VPS and run-as context in `server-infrastructure/dokploy/`, `ai-agents-workflows/hermes-agent/`, `server-infrastructure/tailscale/`, and `server-infrastructure/vps-security/` guides.
- OpenSpec CLI commands such as `openspec validate <change>` run in the terminal; `/opsx:*` commands run in the coding assistant chat, never in the terminal.

## Conventions
- Keep edits scoped to the relevant directory and preserve relative links.
- Follow each `ai-coding-harnesses/opencode/` and `ai-coding-harnesses/claude-code/` README for copy destinations instead of treating repository examples as active configuration.
