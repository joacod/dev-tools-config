# Fair Local-LLM Benchmarking

Use this plan to compare `mlx-lm`, `llama.cpp`, oMLX, and MTPLX on the same Apple Silicon Mac. It is deliberately a measurement protocol rather than a promise that one runtime is universally fastest.

## 1. Freeze the experiment

Record these values before each run:

- exact Mac model, chip/GPU cores, unified memory, macOS version, and power mode
- runtime version, commit or release, model repository, revision, and total weight bytes
- quantization layout, context limit, sampler settings, thinking mode, and response cap
- free disk, memory pressure, and the applications left open
- server flags, port, cache state, concurrency, fan/thermal mode, and benchmark date

Use AC power and the same thermal state for all engines. Close memory-heavy applications, but do not compare a clean machine with a normal daily-work environment without labeling the difference.

```sh
sysctl -n hw.model hw.memsize hw.ncpu
sw_vers
memory_pressure -Q
pmset -g batt
```

Do not run two copies of a 20+ GB model while comparing them. Stop the server you started before changing runtimes, and confirm that port `8080` or `8000` is free before the next launch.

## 2. Choose the comparison lane

There are two useful lanes, and they answer different questions.

### Controlled runtime lane

Use the same base model, tokenizer, revision, and quantization class wherever every runtime can load it. If MTPLX can verify that checkpoint but it has no usable MTP contract, use target-only autoregressive mode (`--no-mtp` or `generation_mode: "ar"`) and record that mode. Do not force an unsupported checkpoint into a server.

This lane estimates runtime overhead and cache behavior. It is the only lane suitable for a direct apples-to-apples speed claim.

### Best-supported runtime lane

Use the model artifact each server is designed to accelerate:

- MTPLX: `Youssofal/Qwen3.8-27B-MTPLX-Optimized-Speed`, with native MTP enabled.
- oMLX: the exact Qwen3.8 27B oQ/MTP conversion selected by its model downloader, recording the repository and revision.
- MLX and `llama.cpp`: the exact Qwen3.8 MLX/GGUF conversions that their current loaders support, or the existing Qwen3.6 profiles when a Qwen3.8 artifact is not available.

This lane answers “what is the strongest practical setup for this runtime?” It must not be summarized as a pure server comparison when the weights or quantization differ. Report the model and runtime mode beside every number.

## 3. Use a small, repeatable matrix

Start with one active request and a deterministic speed lane:

| Variable | Initial value |
| --- | --- |
| Prompt lengths | approximately 2k, 8k, 16k, and 32k tokens |
| Generation | 128 or 256 tokens, fixed across engines |
| Sampling | `temperature: 0`; record `top_p`, `top_k`, and penalties |
| Thinking | disabled for the latency lane; measure a separate thinking lane |
| Trials | one warm-up, then at least three cold trials per row |
| Cache reuse | three identical-prefix repeats after the cold rows |
| Concurrency | one request; add 2 and 4 only in a separate throughput matrix |

Use a unique prompt prefix for cold rows so a previous prefix cannot turn a cold request into a cache hit. Clear or bypass each runtime's cache using its supported mechanism and record what “cold” means:

- MLX: restart the server and use unique prompts; use the repository's [`benchmark-mlx-server.py`](../mlx/scripts/benchmark-mlx-server.py) for the existing MLX profile.
- `llama.cpp`: use a fresh server/context and unique prompts; keep `--ctx-size`, batch, flash attention, and KV-cache types fixed.
- oMLX: use the dashboard's cache controls or a fresh cache state; SSD KV caching is a separate experiment, not a hidden default in a cold row.
- MTPLX: use unique prompts and the documented `POST /admin/cache/clear` between cold rows when testing through its API.

Do not use a short output cap to score a reasoning model. For a quality or accuracy lane, disable the cap or use a generous, equal cap and treat `finish_reason != "stop"` as a void row. A small capped request can spend all of its budget in the think channel.

## 4. Collect the same metrics

Report separate prefill and decode measurements:

- time to first token (TTFT)
- prompt/prefill tokens per second
- decode tokens per second, excluding prefill
- total server time and client wall time
- prompt, completion, and cached-token counts
- peak process/system memory and memory pressure or swap behavior
- errors, timeouts, context rejections, and model-load failures

For MTPLX also record `mtplx_stats`, including `accepted_by_depth`, `drafted_by_depth`, `session_cache_hit`, `new_prefill_tokens`, and the server-side timing fields. Its server-side stats are preferable to a client stopwatch for prefill/decode separation. For oMLX, record the dashboard's PP/TG, cache-hit, and memory values. Do not mix a dashboard metric, a client wall-clock rate, and an SSE chunk rate under one “tokens/sec” label.

A result row should look like this:

```text
engine: mtplx
model: Youssofal/Qwen3.8-27B-MTPLX-Optimized-Speed
revision: <commit or resolved revision>
mode: mtp
context: 8192 prompt tokens
completion cap: 128
sampling: temperature=0, enable_thinking=false
trial: cold-2
prefill_tok_s: <value>
decode_tok_s: <value>
ttft_s: <value>
cached_tokens: <value>
peak_memory: <value>
mtp_acceptance: <accepted/drafted by depth>
```

Keep raw JSON or dashboard exports outside the repository unless a later task explicitly adds a current hardware report. Never turn upstream benchmark claims or another Mac's numbers into this machine's measured profile.

## 5. Compare in stages

1. **Smoke test:** install each server, load a small or target model, verify `/health`, `/v1/models`, and one chat request.
2. **Target load:** run the Qwen3.8 27B candidate with a conservative context and one request. Stop on sustained memory pressure, swap growth, or failures.
3. **Cold latency:** run the prompt-length matrix with three trials and median values.
4. **Cache reuse:** repeat one long prefix and report cold versus cached TTFT separately.
5. **Decode mode:** for MTPLX, compare MTP and AR only when the same model and request policy are held constant. Treat MTP acceptance as a diagnostic, not a substitute for output quality.
6. **Concurrency:** test oMLX's continuous batching and each other server with the same number of simultaneous requests; report per-request latency and aggregate throughput.
7. **Quality:** use a fixed coding prompt set, compare outputs blind when practical, and record correctness, tool-call validity, and context-following separately from speed.

## 6. Interpret the result

- A dense 27B result is not directly comparable with the existing Qwen3.6 MoE result without explaining total and active parameters.
- MTP can raise decode speed while prefill, memory, and model-load time remain unchanged; report both phases.
- SSD/prefix caching primarily changes repeated-prefix latency, not cold prefill. Keep cold and warm results in separate tables.
- A larger quant can improve quality while reducing context headroom. Choose the smallest model/quant that meets the actual coding task, not the highest headline rate.
- A result from an M4 Pro 48 GB or M3/M4 Max is useful context but is not a measurement of another M4 48 GB configuration.

Finish by choosing a runtime per workload: daily-agent stability, cold-start latency, repeated-prefix latency, single-request decode, or concurrent throughput. Defer parameter changes until the baseline is stable and the result table shows which variable is worth changing.

## References

- [MLX hardware qualification guide](../mlx/docs/guides/hardware-qualification.md)
- [MLX HTTP benchmark client](../mlx/scripts/benchmark-mlx-server.py)
- [oMLX benchmark contract and dashboard](https://github.com/jundot/omlx)
- [MTPLX benchmarking guide](https://github.com/youssofal/MTPLX/blob/main/docs/benchmarking.md)
