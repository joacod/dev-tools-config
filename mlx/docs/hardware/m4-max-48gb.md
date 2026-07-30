# MacBook Pro M4 Max 48GB

Latency-first settings for one interactive coding or tool-using agent.

## Hardware

- `Mac16,5`
- M4 Max: 16-core CPU and 40-core GPU
- 48 GiB unified memory
- 546 GB/s memory bandwidth
- approximately 40.2 GB MLX recommended working set

## Recommended Command

```sh
mlx_lm.server \
  --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ \
  --host 127.0.0.1 \
  --port 8080 \
  --max-tokens 8192 \
  --prompt-cache-size 4 \
  --prompt-cache-bytes 4000000000 \
  --decode-concurrency 1 \
  --prompt-concurrency 1 \
  --prefill-step-size 4096
```

Launcher equivalent:

```sh
run-mlx-server --m4-48gb --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ
```

## Settings

- `--max-tokens 8192`: default response limit, not context size
- `--prompt-cache-size 4`: retains four reusable in-memory caches
- `--prompt-cache-bytes 4000000000`: 4 GB active/retained cache budget in the batchable server path
- `--decode-concurrency 1`: best latency for one active agent
- `--prompt-concurrency 1`: limits prefill memory use
- `--prefill-step-size 4096`: best measured AC prefill setting across 2k-32k prompts
- `--host 127.0.0.1`: keeps the development server local

`--prompt-cache-bytes` is not a hard process-memory limit or OOM guard.

## Model Cache Size

For `Qwen3.6-35B-A3B-4bit-DWQ`, one sequence uses approximately:

```txt
61.4 MiB fixed state + 20 KiB per cached token
```

| Tokens | Approximate cache |
| ---: | ---: |
| 8,192 | 221 MiB |
| 16,384 | 381 MiB |
| 32,768 | 701 MiB |

This excludes model weights, activations, prefill temporaries, allocator overhead, and macOS memory. Cache budget and model context length are separate concepts.

## Adjustments

- Two overlapping clients: test `--decode-concurrency 2`.
- Long-prompt memory pressure: try `--prefill-step-size 2048`, then `1024` or `512`.
- Keep `--prompt-concurrency 1` until peak memory is measured.

## Operating Tips

- Use AC power for sustained long-context work.
- Close memory-heavy applications before large prompts.
- Check pressure with `memory_pressure -Q`.
- Do not change the wired-memory limit unless MLX reports that the model is too large for the available working set.

See [M4 Max 48GB Benchmarks](./m4-max-48gb-benchmark.md) for measured TTFT, decode speed, cache reuse, and memory behavior.

## References

- [MLX-LM HTTP Model Server](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md)
- [MLX-LM repository](https://github.com/ml-explore/mlx-lm)
- [MLX wired-memory limit](https://ml-explore.github.io/mlx/build/html/python/_autosummary/mlx.core.set_wired_limit.html)
- [Apple M4 Max MacBook Pro specifications](https://support.apple.com/en-us/121553)

Tested with `mlx-lm 0.31.3`, `mlx 0.32.0`, `mlx-metal 0.32.0`, and macOS 26.5.2. Run `mlx_lm.server --help` after upgrades.
