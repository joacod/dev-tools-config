# oMLX

Run MLX-compatible language models on Apple Silicon with [oMLX](https://github.com/jundot/omlx), an OpenAI-compatible server with continuous batching, a paged hot/cold KV cache, model management, and a macOS menu-bar app.

This guide covers the first install and a conservative baseline. It intentionally leaves detailed cache, concurrency, and model tuning for the [shared comparison plan](../local-ai/benchmarking.md).

## Requirements

- Apple Silicon Mac
- macOS 15 or newer
- Apple Silicon-compatible MLX model files
- enough disk space and unified-memory headroom for the selected model

The macOS app is the simplest path. The Homebrew and source paths are useful when the server should be managed from a terminal.

## Install

### macOS app

Download the [latest oMLX release](https://github.com/jundot/omlx/releases), open the `.dmg`, and drag oMLX to Applications. The app includes a CLI shim at `~/.omlx/bin/omlx` and walks through the model directory and first download.

### Homebrew

```sh
brew tap jundot/omlx https://github.com/jundot/omlx
brew install omlx
omlx help
```

Start and manage the Homebrew service with:

```sh
omlx start
omlx stop
omlx restart
```

Use the foreground command below when you want the exact server flags visible in a terminal or when collecting benchmark evidence.

### From source

The upstream source install requires Python 3.11–3.13 and Apple Silicon:

```sh
git clone https://github.com/jundot/omlx.git
cd omlx
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -e .
```

## First server

Use the default model directory and keep the server local:

```sh
mkdir -p "$HOME/.omlx/models"
omlx serve \
  --model-dir "$HOME/.omlx/models" \
  --host 127.0.0.1 \
  --port 8000
```

The server discovers model subdirectories under `~/.omlx/models`. Open the admin dashboard at <http://127.0.0.1:8000/admin> and use its Hugging Face model downloader to select a model, inspect its files, and download it. The dashboard also exposes built-in chat, model status, settings, and benchmarking.

For the first 48 GB-Mac experiment, look for the current oMLX catalog entry named `Qwen3.8-27B-MLX-oQ4e-mtp`. The oMLX benchmark site has reported that model label on 48 GB M4 hardware, but the result was on an M4 Pro and is not a measurement of every M4 Mac. Record the actual repository, revision, quantization, and model ID returned by your install before comparing it.

If the catalog does not contain a compatible Qwen3.8 conversion, use the model that oMLX currently recommends rather than assuming that the MTPLX-specific checkpoint can use oMLX's MTP path.

## Verify the API

```sh
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/v1/models
```

Use the model ID returned by `/v1/models` for a smoke test:

```sh
curl http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "<id-from-v1-models>",
    "messages": [{"role": "user", "content": "Reply with: oMLX is ready."}],
    "temperature": 0,
    "max_tokens": 32,
    "stream": false
  }'
```

The OpenAI-compatible base URL for coding tools is:

```text
http://127.0.0.1:8000/v1
```

Do not expose the server beyond localhost without configuring an API key and an intentional network boundary.

## Conservative baseline

For a first run, keep the upstream defaults and change only the settings needed to make the experiment observable:

- one model loaded
- `127.0.0.1:8000`
- one active request for a single-agent comparison
- the default balanced memory guard
- a practical 32k context ceiling until memory behavior is measured
- SSD KV caching disabled for a cold baseline

For a single-request benchmark, the explicit concurrency override is:

```sh
omlx serve \
  --model-dir "$HOME/.omlx/models" \
  --host 127.0.0.1 \
  --port 8000 \
  --max-concurrent-requests 1
```

That is a benchmark baseline, not a universal daily-use setting. After the baseline, test the tiered cache deliberately with a dedicated directory:

```sh
omlx serve \
  --model-dir "$HOME/.omlx/models" \
  --paged-ssd-cache-dir "$HOME/.omlx/cache"
```

Record whether a result is cold, in-memory cached, or SSD-restored. oMLX's cache is a feature to measure, not a reason to mix warm and cold numbers.

## Stop and troubleshoot

- Stop a foreground server with `Control-C`; use `omlx stop` for a managed service.
- If port `8000` is busy, inspect it before stopping anything: `lsof -nP -iTCP:8000 -sTCP:LISTEN`.
- If memory pressure grows, stop the server, lower the context ceiling, unload other models, or choose a smaller quant. Do not assume a model's weight size is its peak process size.
- Run only one large model backend at a time. The existing MLX and `llama.cpp` launchers use port `8080`; oMLX and MTPLX use `8000` by default.

## Official references

- [oMLX repository](https://github.com/jundot/omlx)
- [oMLX releases](https://github.com/jundot/omlx/releases)
- [oMLX performance explorer](https://omlx.ai/benchmarks/performance)
- [oMLX quantization notes](https://github.com/jundot/omlx/blob/main/docs/oQ_Quantization.md)
- [Local AI comparison plan](../local-ai/benchmarking.md)
