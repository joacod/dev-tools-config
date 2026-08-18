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

## Permanent facts
- Each top-level tool directory is independent; `README.md` is the index and must be updated when adding or removing a top-level directory.
- `opencode/` and `claude-code/` contain copyable templates and examples, not active user configuration. Preserve placeholders in `opencode/instructions/*/AGENTS.md` and `claude-code/instructions/*/CLAUDE.md`.
- Keep API keys, passwords, private SSH keys, model caches, `__pycache__`, and generated local-AI virtual environments out of tracked changes. The external [`local-ai`](https://github.com/joacod/local-ai) repository's [MLX setup script](https://github.com/joacod/local-ai/blob/main/mlx/setup-mlx.sh) creates or updates `mlx/venv` on Apple Silicon.
- The external [MLX launcher](https://github.com/joacod/local-ai/blob/main/mlx/run-mlx-server.sh) and [llama.cpp launcher](https://github.com/joacod/local-ai/blob/main/llama-cpp/run-llama-server.sh) both bind local port `8080`; OpenCode's MLX and llama.cpp providers use `http://127.0.0.1:8080/v1`, so run only one backend there at a time.
- The external [MLX benchmark client](https://github.com/joacod/local-ai/blob/main/mlx/scripts/benchmark-mlx-server.py) drives an already-running MLX HTTP server and does not start or stop it. Measure hardware profiles on matching hardware and keep tracked MLX hardware/benchmark documents latest-only.
- Preserve local-machine/VPS and run-as context in `dokploy/`, `hermes-agent/`, `tailscale/`, and `vps-security/` guides.
- OpenSpec CLI commands such as `openspec validate <change>` run in the terminal; `/opsx:*` commands run in the coding assistant chat, never in the terminal.

## Conventions
- Keep edits scoped to the relevant directory and preserve relative links.
- Follow each `opencode/` and `claude-code/` README for copy destinations instead of treating repository examples as active configuration.
