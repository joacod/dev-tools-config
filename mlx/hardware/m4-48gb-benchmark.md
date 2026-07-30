# M4 Max 48GB Benchmarks

Measurements for `mlx-community/Qwen3.6-35B-A3B-4bit-DWQ` on the hardware described in [M4 Max 48GB](./m4-48gb.md).

## Environment

- `mlx-lm 0.31.3`
- `mlx 0.31.2`
- macOS 26.5.2
- Automatic power mode
- `--decode-concurrency 1`
- `--prompt-concurrency 1`

Each cold HTTP request used a unique prefix, deterministic sampling, disabled thinking, and a 128-token response limit. Time to first token (TTFT) includes tokenization, prompt prefill, and first-token sampling.

## Prefill Step

Measured on battery power:

| Prefill step | 2,089 tokens | 8,233 tokens | 16,426 tokens | 32,810 tokens |
| ---: | ---: | ---: | ---: | ---: |
| `1024` | 1.365s | 5.025s | 10.834s | 27.366s |
| `2048` | **1.364s** | 4.997s | 10.759s | **27.060s** |
| `4096` | 1.366s | **4.864s** | **10.557s** | 30.211s |

`2048` is the best balanced setting. `4096` is slightly faster at 8k-16k but 11.6% slower at 32k. `1024` is slightly slower throughout.

## AC Power

The `2048` preset was repeated on AC power in Automatic mode:

| Prompt tokens | Battery TTFT | AC TTFT | AC improvement |
| ---: | ---: | ---: | ---: |
| 2,089 | 1.364s | 1.348s | 1.2% |
| 8,233 | 4.997s | 4.995s | <0.1% |
| 16,426 | 10.759s | 10.738s | 0.2% |
| 32,810 | 27.060s | 26.123s | 3.5% |

AC power mainly benefits sustained long-context prefill. It does not require different server settings.

## Throughput

With prefill step `2048`:

- cold prompt processing: approximately 1.2k-1.65k tokens/s
- decode at 2k context: approximately 76 tokens/s
- decode at 32k context: approximately 61 tokens/s

## Prompt Cache

Repeating the same 8,218-token prompt produced:

| Request | Cached tokens | TTFT |
| --- | ---: | ---: |
| Cold | 0 | 5.446s |
| Cached | 8,217 | 0.152s |
| Cached repeat | 8,217 | 0.145s |

Prompt reuse provides the largest latency improvement and supports retaining four cache entries for a single-agent workflow.

## Memory

The 32k matrix temporarily reduced available memory, which recovered above 80% after ten idle seconds. No wired-memory adjustment was needed.

Results are directional measurements from one run per setting. High Power Mode was not measured.
