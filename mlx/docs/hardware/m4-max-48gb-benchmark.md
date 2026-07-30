# M4 Max 48GB Benchmarks

Measurements for `mlx-community/Qwen3.6-35B-A3B-4bit-DWQ` on the hardware described in [M4 Max 48GB](./m4-max-48gb.md).

## Environment

- `mlx-lm 0.31.3`
- `mlx 0.32.0`
- `mlx-metal 0.32.0`
- Python 3.14
- macOS 26.5.2
- Automatic power mode
- AC power
- `--decode-concurrency 1`
- `--prompt-concurrency 1`
- `--prompt-cache-size 4`
- `--prompt-cache-bytes 4000000000`
- model revision `73c707af4243243b18193444467872d20cff9399`

Each cold HTTP request used `benchmark-mlx-server.py` with a unique prefix, deterministic sampling, disabled thinking, and a 128-token response limit. Results are medians of three cold trials. Time to first token (TTFT) includes tokenization, prompt prefill, and first-token sampling.

## Prefill Step

Measured on AC power:

| Prefill step | ~2,046 tokens | ~8,186 tokens | ~16,380 tokens | ~32,764 tokens |
| ---: | ---: | ---: | ---: | ---: |
| `1024` | 1.297s | 5.020s | 11.648s | 27.432s |
| `2048` | 1.364s | **4.931s** | 11.274s | 28.188s |
| `4096` | **1.248s** | 4.947s | **11.053s** | **27.080s** |

`4096` is the best measured setting: it is fastest at 2k, 16k, and 32k, while `2048` is 0.3% faster at 8k. Relative to `2048`, `4096` improves TTFT by 2-9% at the other context sizes.

## Throughput

With prefill step `4096`:

- cold prompt processing: approximately 1.21k-1.65k tokens/s
- decode at 2k context: approximately 78 tokens/s
- decode at 32k context: approximately 64 tokens/s

## Prompt Cache

Repeating the same 8,188-token prompt produced:

| Request | Cached tokens | TTFT |
| --- | ---: | ---: |
| Cold | 0 | 4.866s |
| Cached | 8,187 | 0.141s |
| Cached repeat | 8,187 | 0.142s |

Prompt reuse provides the largest latency improvement and supports retaining four cache entries for a single-agent workflow.

## Memory

The 32k matrix temporarily reduced available memory, which recovered to 83% free after the matrix. No wired-memory adjustment was needed.

Battery power and High Power Mode were not measured in this environment.
