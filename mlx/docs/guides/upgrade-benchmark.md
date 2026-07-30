# MLX Upgrade And Benchmark Guide

Use this guide after upgrading `mlx-lm`, `mlx`, or `mlx-metal` on a machine that already has a measured profile. For a new machine or model, use the [Hardware Qualification Guide](./hardware-qualification.md) instead.

## Goal

Confirm that the installed packages are current, detect changed server options or runtime behavior, remeasure affected parameters, and leave the repository with one current machine profile and one current benchmark report.

The previous benchmark is a temporary comparison baseline. Compare against it while working, but replace superseded versions and results in the tracked documents. Do not append benchmark history.

## Copy/Paste Agent Prompt

Use the canonical [Requalify After An Upgrade](../getting-started.md#requalify-after-an-upgrade) prompt. It is kept in the beginner workflow so there is one copy/paste source for both new-machine and upgrade sessions.

## 1. Preserve A Temporary Baseline

Before editing, read the current machine guide and benchmark report. Save any comparison notes or raw values outside the tracked documents.

Record:

- exact machine, model repository, model revision, and workload
- current `mlx-lm`, `mlx`, `mlx-metal`, Python, and macOS versions
- current server command and tuned parameters
- TTFT, decode rate, cache behavior, and memory observations
- power mode and any untested areas

Use this baseline only to evaluate the upgrade. The final tracked documents must contain the new environment and new measurements only.

## 2. Inspect The Upgrade

Check the worktree and current environment before installation:

```sh
git status --short
mlx/venv/bin/python -c 'from importlib.metadata import version; print("mlx-lm", version("mlx-lm")); print("mlx", version("mlx")); print("mlx-metal", version("mlx-metal"))'
mlx/venv/bin/mlx_lm.server --help
```

Compare stable releases on PyPI and read upstream release notes. Pay particular attention to:

| Changed area | Rebenchmark |
| --- | --- |
| Server batching, request handling, or prompt cache | HTTP behavior, cache reuse, concurrency |
| Metal attention, quantized matrix operations, normalization, or memory allocation | Prefill, decode, long context, memory |
| Default or available server flags | Every affected parameter and launcher compatibility |
| Tokenizer, chat template, or model implementation | Prompt counts, output behavior, cache, quality smoke test |
| Only unrelated training or platform code | Server smoke test; explain why a full matrix is unnecessary |

Do not infer performance changes from release notes alone. Use them to select the tests.

## 3. Upgrade And Verify

Run:

```sh
mlx/setup-mlx.sh
mlx/venv/bin/python -m pip check
mlx/venv/bin/mlx_lm.server --help
```

Confirm the resolved package versions rather than assuming every transitive dependency was upgraded. Check that all configured launcher flags still exist and retain the expected meaning and defaults.

## 4. Control The Environment

Keep these fixed across comparisons:

- machine and model revision
- prompt targets and prompt construction
- deterministic sampling and disabled thinking
- response limit and trial count
- concurrency and cache settings, except when each is the variable under test
- battery or AC state and macOS power mode
- relevant foreground applications when practical

Before and after each matrix, record:

```sh
memory_pressure -Q
vm_stat
pmset -g batt
```

Ensure port `8080` is free before starting a server. Do not run `mlx_lm.benchmark` while an HTTP server already holds the same large model.

## 5. Start One Candidate Profile

Start the server explicitly so the measured flags are visible. Example:

```sh
mlx/venv/bin/mlx_lm.server \
  --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ \
  --host 127.0.0.1 \
  --port 8080 \
  --max-tokens 8192 \
  --prompt-cache-size 4 \
  --prompt-cache-bytes 4000000000 \
  --decode-concurrency 1 \
  --prompt-concurrency 1 \
  --prefill-step-size 4096 \
  --chat-template-args '{"enable_thinking":false}'
```

Verify `http://127.0.0.1:8080/health` and confirm the final process flags. Benchmark one server configuration at a time. Stop and restart only the process you started when changing server parameters.

## 6. Run The Shared Benchmark

The benchmark client drives a running server through streaming chat completions. It does not start, stop, or replace the server.

From the repository root:

```sh
mlx/venv/bin/python mlx/scripts/benchmark-mlx-server.py \
  --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ \
  --label prefill-4096 \
  --targets 2048 8192 16384 32768 \
  --trials 3 \
  --max-tokens 128 \
  | tee /tmp/mlx-prefill-4096.jsonl
```

The client emits JSON Lines containing metadata, every trial, and median summaries. Actual API `prompt_tokens` are authoritative; targets are approximate because tokenizers and chat templates differ.

Repeat the command after restarting the server with each candidate parameter. Use unique labels and output files. For a typical prefill comparison, test `1024`, `2048`, and `4096`, including the upstream default.

After selecting the profile, measure prompt-cache reuse without repeating the full matrix:

```sh
mlx/venv/bin/python mlx/scripts/benchmark-mlx-server.py \
  --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ \
  --label selected-cache \
  --cache-only \
  --cache-target 8192 \
  --trials 3 \
  | tee /tmp/mlx-cache.jsonl
```

Use `--url` for another host or port and `--chat-template-kwargs '{}'` when the selected model does not use thinking controls. Run `mlx/venv/bin/python mlx/scripts/benchmark-mlx-server.py --help` for all options.

## 7. Select Parameters

Prioritize:

1. stability and memory headroom
2. latency for the target workload
3. prompt-cache reuse
4. decode and aggregate throughput

Change one variable at a time. Do not call a setting optimal without measurements. Keep concurrency at `1/1` for one interactive agent unless overlapping-client tests justify another value.

## 8. Compare, Then Replace

Compare the new medians with the temporary baseline and note meaningful improvements, regressions, or unchanged behavior in the final work report.

Update tracked documents using only the selected current environment:

- exact installed versions and operating conditions
- latest measured parameter matrix
- selected current parameters and rationale
- latest throughput, cache, and memory results
- current untested areas

Remove superseded package versions, prior result tables, old power comparisons, and migration narrative. Git history already preserves old documents.

## 9. Align And Verify

Update the launcher profile, parameter reference, machine guide, benchmark report, and README links when applicable.

Run:

```sh
python3 -m py_compile mlx/scripts/benchmark-mlx-server.py
bash -n mlx/setup-mlx.sh mlx/run-mlx-server.sh
mlx/venv/bin/python -m pip check
mlx/venv/bin/mlx_lm.server --help
git diff --check
```

Verify local Markdown links, the printed launcher command, `/health`, final process flags, and that no benchmark server or second model process remains running.

## PyTorch

Do not install PyTorch for this workflow. `mlx-lm` executes models with MLX and does not require PyTorch. The benchmark imports Hugging Face Transformers only for tokenizer and chat-template utilities, which work without a model backend. The client suppresses Transformers' advisory about unavailable PyTorch model classes.
