# M2 16GB Benchmarks

Measurements for `mlx-community/Qwen3-4B-Instruct-2507-4bit` on the hardware described in [MacBook Air M2 16GB](./m2-16gb.md).

## Environment

- `mlx-lm 0.31.3`
- `mlx 0.32.0`
- `mlx-metal 0.32.0`
- Python 3.13.4
- macOS 26.5.2
- Automatic power mode
- AC power
- `--decode-concurrency 1`
- `--prompt-concurrency 1`
- `--prompt-cache-size 2`
- `--prompt-cache-bytes 3000000000`
- model revision `50d427756c6b1b2fe0c0a10f67fbda1fc8e82c1b`

Each HTTP request used `benchmark-mlx-server.py` with deterministic sampling, disabled thinking, and a 128-token response limit. Reported 2k-16k results are medians of three unique cold trials after one warm-up. TTFT includes tokenization, prompt prefill, and first-token sampling.

## Prefill Step

| Prefill step | ~2,045 tokens | ~8,190 tokens | ~16,380 tokens |
| ---: | ---: | ---: | ---: |
| `1024` | **10.878s** | **51.492s** | **143.562s** |
| `2048` | 11.159s | 64.019s | 151.698s |
| `4096` | 11.152s | 57.748s | 158.131s |

`1024` had the lowest median TTFT at every tested context size. The fanless machine slowed during sustained long-prompt runs, so the table represents end-to-end interactive behavior rather than isolated peak throughput.

## Throughput

With prefill step `1024`:

| Prompt tokens | Total time | Decode rate |
| ---: | ---: | ---: |
| 2,043 | 15.740s | 26.12 tokens/s |
| 8,188 | 58.077s | 19.29 tokens/s |
| 16,379 | 153.221s | 13.09 tokens/s |

Longer context reduces both approximate prompt processing and decode throughput.

## Prompt Cache

Repeating the same 8,189-token prompt with prefill step `1024` produced:

| Request | Cached tokens | TTFT | Total time |
| --- | ---: | ---: | ---: |
| Cold | 5 | 51.344s | 57.892s |
| Cached | 8,188 | 0.711s | 9.837s |
| Cached repeat | 8,188 | 0.422s | 19.974s |

Prefix reuse removes almost all prefill latency. Decode slowed across the sustained sequence, consistent with thermal throttling, so cached TTFT is the relevant cache comparison.

## Memory

- MLX reported a 12,713,115,648-byte recommended working set.
- Idle server RSS was approximately 2.4 GiB after model loading.
- Memory pressure returned to 82-85% free after the completed 2k-16k matrices.
- The `2048` and `4096` matrices each added roughly 250 MiB of swap-outs during sustained testing.
- One 32,762-token cold request at prefill step `1024` had 401.212s TTFT, 417.677s total time, and 7.71 tokens/s decode. Swap-outs then grew by approximately 2.09 GiB and memory availability fell to 52%, so the 32k matrix was stopped after that trial.

Contexts above 16k, concurrent clients, battery power, and alternative cache budgets were not qualified.
