# MTPLX

Run Apple Silicon language models with [MTPLX](https://github.com/youssofal/MTPLX), an OpenAI-compatible server that can use a model's native Multi-Token Prediction (MTP) head for speculative decoding.

This guide covers installation, the first Qwen3.8 model, and a safe server baseline. Use the [shared comparison plan](../local-ai/benchmarking.md) before drawing speed conclusions.

## Requirements

- Apple Silicon Mac (M1 or newer)
- macOS 14 or newer
- Python 3.11+ when using the Python install path
- enough disk space and unified-memory headroom for the selected model

The upstream project recommends Qwen3.8 Optimized Speed on Macs with 32 GB or more. A 48 GB Mac is a reasonable starting target, but context length, other applications, and model allocations still determine whether a run is comfortable.

## Install

Homebrew is the most reproducible terminal path:

```sh
brew install youssofal/mtplx/mtplx
mtplx help
mtplx doctor --summary
```

The [signed macOS app](https://mtplx.com/download) is another supported path. It can set up its own runtime and place `mtplx` on `PATH`. A Python-only alternative is:

```sh
python3 -m pip install -U mtplx
```

Use one installation path for the first experiment so the executable and version are unambiguous.

## Pull and inspect Qwen3.8

Start with the model recommended by the upstream MTPLX quickstart:

```sh
MODEL='Youssofal/Qwen3.8-27B-MTPLX-Optimized-Speed'
mtplx pull "$MODEL"
mtplx inspect "$MODEL" --json
```

The [model card](https://huggingface.co/Youssofal/Qwen3.8-27B-MTPLX-Optimized-Speed) describes this as a 4-bit dynamic quantization with the native MTP head retained. It reports about 21.3 GB of model files on disk. The download size is not a runtime-memory guarantee; leave room for macOS, the KV cache, context, and the server.

Other Qwen3.8 candidates are available after the baseline:

- [Bare Speed](https://huggingface.co/Youssofal/Qwen3.8-27B-MTPLX-Bare-Speed) trades quality for burst speed.
- [Optimized Quality](https://huggingface.co/Youssofal/Qwen3.8-27B-MTPLX-Optimized-Quality) uses an 8-bit dynamic quantization and needs more memory.
- The FP16 build is intended for older M1/M2 hardware, not the first choice for a 48 GB experiment.

Do not use the MTPLX-specific checkpoint in oMLX or `llama.cpp` without first verifying that the target runtime supports its layout and quantization. A shared model name is not proof of shared loader behavior.

## Start the API server

For a reproducible foreground launch, specify the model, local host, and port:

```sh
mtplx serve \
  --model "$MODEL" \
  --host 127.0.0.1 \
  --port 8000 \
  --no-stats-footer
```

`mtplx start` is the interactive/app-managed path when you want MTPLX to select a model and surface. Use `serve` for the first benchmark so the command and generation policy are visible.

## Verify the server

```sh
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/metrics
curl http://127.0.0.1:8000/v1/models
```

A smoke-test request can use the same OpenAI-compatible shape as the other local servers:

```sh
curl http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "Youssofal/Qwen3.8-27B-MTPLX-Optimized-Speed",
    "messages": [{"role": "user", "content": "Reply with: MTPLX is ready."}],
    "temperature": 0,
    "max_tokens": 32,
    "enable_thinking": false,
    "stream": false
  }'
```

The OpenAI-compatible base URL for coding tools is:

```text
http://127.0.0.1:8000/v1
```

Keep the server on `127.0.0.1`. Non-localhost binds require an API key and an intentional network boundary.

## Confirm MTP mode

MTPLX exposes its active serving policy through `/health`. Check fields such as `load_mtp`, `mtp_enabled`, `depth`, and `generation_mode` before recording a result.

- Normal MTPLX serving uses native MTP when the model contract is verified.
- `generation_mode: "mtp"` explicitly requests MTP for a request.
- `generation_mode: "ar"` uses target-only autoregressive generation while keeping the MTP runtime available for a later request.
- `--no-mtp` selects target-only AR at server startup.

For the first speed comparison, keep MTP enabled and record its acceptance/depth statistics. Run an AR comparison only as a separate, explicitly labeled lane; MTP and AR numbers answer different questions.

## First benchmark baseline

Before tuning fan control, scheduler modes, context, or draft depth:

- use one active request and a fixed response cap
- disable thinking for a latency-only lane, then run a separate reasoning lane
- use unique cold prompts and at least three trials per context size
- read the authoritative `mtplx_stats` block from the final response chunk
- record `prefill_tok_s`, `decode_tok_s`, `ttft_s`, cached tokens, peak memory, and `accepted_by_depth` / `drafted_by_depth`

MTPLX's [benchmarking guide](https://github.com/youssofal/MTPLX/blob/main/docs/benchmarking.md) documents cache clearing, capped reasoning requests, server-side timing, and thermal discipline. Use the [cross-runtime plan](../local-ai/benchmarking.md) to compare those results with MLX, `llama.cpp`, and oMLX without mixing cold and cached measurements.

## Troubleshooting

- If `doctor` reports a missing MLX dependency, fix that installation before diagnosing a model.
- If model inspection rejects the checkpoint, do not bypass the compatibility gate; choose a supported model or record the rejection.
- If memory pressure or swap grows, stop the server and lower context or choose a smaller model/quant.
- Run only one large model backend at a time. Existing MLX and `llama.cpp` launchers use port `8080`; oMLX and MTPLX use `8000` by default.

## Official references

- [MTPLX repository](https://github.com/youssofal/MTPLX)
- [MTPLX installation](https://github.com/youssofal/MTPLX/blob/main/INSTALL.md)
- [MTPLX quickstart](https://github.com/youssofal/MTPLX/blob/main/docs/quickstart.md)
- [MTPLX architectures](https://github.com/youssofal/MTPLX/blob/main/docs/architectures.md)
- [MTPLX API](https://github.com/youssofal/MTPLX/blob/main/docs/api.md)
- [Local AI comparison plan](../local-ai/benchmarking.md)
