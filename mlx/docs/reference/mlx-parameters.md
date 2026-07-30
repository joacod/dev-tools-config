# mlx-lm Parameters

Use the installed command as the authoritative reference:

```sh
mlx_lm.server --help
```

## Server Parameters

| Flag | Meaning |
| --- | --- |
| `--model` | Hugging Face repository or local model directory to load |
| `--host` | Bind address; keep `127.0.0.1` for local use |
| `--port` | Server port; this repository uses `8080` |
| `--max-tokens` | Default response limit; requests can override it and it does not set context size |
| `--prompt-cache-size` | Maximum number of reusable in-memory cache entries |
| `--prompt-cache-bytes` | Active/retained cache budget in the batchable path; not a hard memory limit |
| `--decode-concurrency` | Requests decoded together for aggregate throughput |
| `--prompt-concurrency` | Prompts prefilling together; higher values use more memory |
| `--prefill-step-size` | Tokens per prefill step; smaller values can reduce peak memory |
| `--trust-remote-code` | Allows code from a trusted model repository |

## M2 16GB Profile

For one interactive coding agent using `Qwen3-4B-Instruct-2507-4bit`, use:

```sh
--max-tokens 8192
--prompt-cache-size 2
--prompt-cache-bytes 3000000000
--decode-concurrency 1
--prompt-concurrency 1
--prefill-step-size 1024
```

See [MacBook Air M2 16GB](../hardware/m2-16gb.md) for the measured context and memory limits.

## M4 Max 48GB Profile

For one interactive coding agent using `Qwen3.6-35B-A3B-4bit-DWQ`, start with:

```sh
--max-tokens 8192
--prompt-cache-size 4
--prompt-cache-bytes 4000000000
--decode-concurrency 1
--prompt-concurrency 1
--prefill-step-size 4096
```

See [MacBook Pro M4 Max 48GB](../hardware/m4-max-48gb.md) for hardware and cache details.

## Cache Behavior

Prompt caching reuses processed prefixes:

- `--prompt-cache-size` limits the number of distinct entries.
- `--prompt-cache-bytes` trims retained entries relative to active batch-cache use.

In `mlx-lm 0.31.3`, the byte budget is not enforced in every path and cannot shrink an active sequence. Cache size depends on model architecture, sequence length, and concurrency.

## Request-Time Parameters

Common API fields are `temperature`, `top_p`, `top_k`, `min_p`, `max_tokens`, `max_completion_tokens`, and `stream`.

Example:

```sh
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Explain recursion in simple terms."}],
    "temperature": 0.0,
    "max_tokens": 512,
    "stream": false
  }'
```

## Launcher Passthrough

Use `--` to pass installed server options that the launcher does not manage directly:

```sh
run-mlx-server \
  --m4-48gb \
  --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ \
  -- --log-level DEBUG
```

Arguments after `--` are appended last and can override earlier scalar options supported by `argparse`, such as `--port` or `--prefill-step-size`.
