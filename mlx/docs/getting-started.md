# Getting Started With MLX On A Mac

This is the starting point for running local language models on an Apple Silicon Mac. It covers first installation, the `run-mlx-server` alias, a small smoke test, machine-specific tuning, and future package upgrades.

## What Gets Installed

- `mlx`: Apple's machine-learning runtime for Apple Silicon
- `mlx-metal`: the Metal backend used by MLX
- `mlx-lm`: model loading, text generation, and the HTTP server
- `mlx_lm.server`: the OpenAI-compatible local API included with `mlx-lm`

PyTorch is not required. Model execution uses MLX.

## Requirements

- Apple Silicon Mac
- macOS
- Git
- Python 3 available as `python3`
- enough free disk space and unified memory for the model you select

Model download size and runtime memory are different. Start with the small smoke-test model before selecting a larger model for real work.

## Choose A Path

| Situation | Follow |
| --- | --- |
| First installation on this Mac | [New Mac Setup](#new-mac-setup) |
| Already installed; normal daily use | [Daily Use](#daily-use) |
| New machine needs measured parameters | [Qualify A New Mac](#qualify-a-new-mac) |
| `mlx-lm`, `mlx`, or `mlx-metal` was upgraded | [Requalify After An Upgrade](#requalify-after-an-upgrade) |

## New Mac Setup

### 1. Open The Repository

Clone this repository if needed, then enter its `mlx` directory:

```sh
git clone https://github.com/joacod/developer-tools.git
cd developer-tools/mlx
```

If the repository is already present:

```sh
cd "/absolute/path/to/developer-tools/mlx"
```

### 2. Install MLX

```sh
./setup-mlx.sh
```

The script creates `mlx/venv`, upgrades the three MLX packages, verifies the server command, and prints the resolved versions.

Expected version output has this shape:

```txt
mlx-lm <version>
mlx <version>
mlx-metal <version>
```

There is no separate `mlx-server` package. `mlx_lm.server` is part of `mlx-lm`.

### 3. Add The Launcher Alias

While still inside the repository's `mlx` directory, run this once:

```sh
printf "\nalias run-mlx-server='%s/run-mlx-server.sh'\n" "$PWD" >> "$HOME/.zshrc"
source "$HOME/.zshrc"
```

Verify it:

```sh
run-mlx-server --help
```

The alias points to this clone. If the repository moves, replace the alias in `~/.zshrc` with the new absolute path.

### 4. Run A Small Smoke-Test Model

Use this public, ungated model for the first launch:

```sh
run-mlx-server --model mlx-community/Qwen3-1.7B-4bit
```

The first launch downloads approximately 1 GB. Later launches reuse the Hugging Face cache.

Do not apply another machine's hardware flag for this test. For example, use `--m4-48gb` only on the measured M4 Max 48 GB configuration.

### 5. Verify The Server

Leave the server running and open another terminal:

```sh
curl http://127.0.0.1:8080/health
```

Send a chat request:

```sh
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Reply with: MLX is ready. /no_think"}],
    "temperature": 0,
    "max_tokens": 32
  }'
```

Stop the server with `Control-C` in its terminal.

## Daily Use

Start the interactive launcher:

```sh
run-mlx-server
```

Start a specific model:

```sh
run-mlx-server --model ORG/MODEL
```

Use a measured machine profile only when it matches the current Mac:

```sh
run-mlx-server --m4-48gb --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ
```

Useful endpoints:

- health: `http://127.0.0.1:8080/health`
- models: `http://127.0.0.1:8080/v1/models`
- chat: `http://127.0.0.1:8080/v1/chat/completions`

`mlx_lm.server` is an API server, not a browser chat interface.

## Check For Current Versions

Running setup again is the normal upgrade command:

```sh
./setup-mlx.sh
```

To compare installed and published versions without changing the environment:

```sh
venv/bin/python -m pip index versions mlx-lm
venv/bin/python -m pip index versions mlx
venv/bin/python -m pip index versions mlx-metal
```

## Qualify A New Mac

Generic defaults are enough for the smoke test, but a real model and workload should be measured on each new machine. Do not copy another Mac's cache, concurrency, or prefill settings without benchmarking.

The qualification process creates:

- `docs/hardware/<machine>.md`: current hardware-specific command and parameters
- `docs/hardware/<machine>-benchmark.md`: current measurements supporting those parameters
- an optional named flag in `run-mlx-server.sh` when a reusable launcher profile is useful

Replace the bracketed values and give this prompt to the coding agent from the repository root:

```txt
Set up and qualify MLX on this Apple Silicon Mac.

Read mlx/docs/getting-started.md and mlx/docs/guides/hardware-qualification.md before changing anything. Also inspect the setup script, launcher, parameter reference, model guidance, existing hardware profiles, and git status.

Target model: [Hugging Face repository, or help me select one that fits this Mac]
Workload: [one interactive coding agent, concurrent clients, long-context analysis, or another workload]

Requirements:
- Inspect the exact Mac model, chip, CPU/GPU cores, unified memory, macOS version, power mode, and MLX recommended working set.
- Run mlx/setup-mlx.sh and record the exact mlx-lm, mlx, and mlx-metal versions.
- Verify mlx_lm.server --help and current upstream options.
- Ask before downloading uncached model weights or stopping a server you did not start.
- Start with conservative settings. Do not reuse another machine's profile without measurement.
- Use mlx/scripts/benchmark-mlx-server.py with at least three cold trials per setting and median results.
- Measure TTFT, total time, decode rate, actual prompt tokens, cache reuse, and memory pressure.
- Test one variable at a time, including the upstream/default prefill step plus a smaller and larger value when appropriate.
- Stop on request failures, material swap growth, persistent unhealthy memory pressure, or instability.
- Create mlx/docs/hardware/<machine>.md with the selected current command and parameters.
- Create mlx/docs/hardware/<machine>-benchmark.md with only the current environment and latest measurements.
- Add a named launcher profile only if it is useful for repeated use, and document exactly which hardware it matches.
- Update the README and parameter guide where applicable.
- Keep machine documents latest-only. Do not include superseded settings, old package versions, or benchmark history.
- Verify scripts, package consistency, Markdown links, /health, final process flags, and that no benchmark server remains running.

Report the final launch command, measured conclusions, untested areas, files changed, and verification commands.
```

The detailed measurement protocol is in the [Hardware Qualification Guide](./guides/hardware-qualification.md).

## Requalify After An Upgrade

Package upgrades can change Metal kernels, server defaults, caching, batching, memory use, or available options. Keep the current benchmark as a temporary baseline, run the affected measurements, report improvements or regressions, and then replace the tracked machine documents with the latest results only.

Give this prompt to the coding agent from the repository root:

```txt
Upgrade and requalify the existing MLX setup for [machine profile].

Read mlx/docs/getting-started.md, mlx/docs/guides/upgrade-benchmark.md, and mlx/docs/guides/hardware-qualification.md. Read the setup script, launcher, parameter reference, current machine guide, and current benchmark before changing anything.

Target model: [Hugging Face repository]
Workload: [current workload]

Requirements:
- Treat the current machine benchmark as a temporary comparison baseline and summarize measured improvements or regressions in the final response.
- Check the latest stable PyPI releases and upstream release notes for mlx-lm, mlx, and mlx-metal.
- Run mlx/setup-mlx.sh, record the exact resolved versions, inspect mlx_lm.server --help, and identify changes relevant to server behavior, Metal kernels, caching, concurrency, memory, or this model.
- Ask before downloading uncached model weights or stopping a server you did not start.
- Use mlx/scripts/benchmark-mlx-server.py and keep the model revision, prompt construction, sampling, generation length, thinking mode, power mode, and trial count fixed across comparisons.
- Run at least three cold trials and report medians. Test the upstream/default prefill step plus one smaller and larger value unless release changes support another matrix.
- Measure TTFT, total time, decode rate, actual prompt tokens, cache reuse, and memory pressure.
- Do not run a second large model process. Stop on request failures, material swap growth, persistent unhealthy memory pressure, or instability.
- Change machine parameters only when measurements support the change.
- Update the launcher, parameter guide, machine guide, and benchmark report where applicable.
- Keep tracked machine and benchmark documents latest-only: no superseded versions, old result tables, migration notes, or benchmark history.
- Verify scripts, package consistency, server help, Markdown links, /health, final process state, and git diff checks.

Do not install PyTorch. MLX performs model execution; Transformers is used only for tokenizer utilities by the benchmark client.

Report baseline comparisons in the final response, but leave only current versions and current results in tracked documents.
```

The detailed upgrade workflow is in the [Upgrade And Benchmark Guide](./guides/upgrade-benchmark.md).

## Troubleshooting

### The Alias Is Not Found

Open a new terminal or run:

```sh
source "$HOME/.zshrc"
```

Then verify `run-mlx-server --help`. Check that the absolute path in `~/.zshrc` still exists.

### Port 8080 Is Busy

See which process is listening:

```sh
lsof -nP -iTCP:8080 -sTCP:LISTEN
```

Do not stop an unfamiliar process without confirming what it is.

### Find A Running MLX Server

There is no fixed process ID. Find the current process with:

```sh
pgrep -af 'mlx_lm.server'
```

### The First Launch Is Slow

The model is downloading or Metal kernels are warming up. Later launches use cached model files.

### The Mac Runs Out Of Memory

Stop the server, choose a smaller model, close memory-heavy applications, and use only parameters measured for this machine. Check `memory_pressure -Q` before long-context tests.

### A PyTorch Warning Appears

PyTorch is not needed. The Transformers package can use tokenizers and configuration files without PyTorch. The shared benchmark client suppresses that advisory.

## Next References

- [Documentation Index](./README.md)
- [Hardware Qualification Guide](./guides/hardware-qualification.md)
- [Upgrade And Benchmark Guide](./guides/upgrade-benchmark.md)
- [mlx-lm Parameters](./reference/mlx-parameters.md)
- [Hugging Face And Tuning](./reference/hugging-face-and-tuning.md)
- [HTTP Benchmark Client](../scripts/benchmark-mlx-server.py)
