# MLX

Run local MLX-compatible models on Apple Silicon with [mlx-lm](https://github.com/ml-explore/mlx-lm).

## Start Here

New to local models on a Mac? Follow [Getting Started With MLX On A Mac](./docs/getting-started.md) for installation, the launcher alias, a small smoke test, machine qualification, and package upgrades.

Quick start from this directory:

```sh
./setup-mlx.sh
./run-mlx-server.sh --model mlx-community/Qwen2.5-1.5B-Instruct-4bit
```

## Folder Layout

| Path | Purpose |
| --- | --- |
| `README.md` | Short entry point and common commands |
| `setup-mlx.sh` | Install or upgrade the local MLX environment |
| `run-mlx-server.sh` | Interactive and profile-aware server launcher |
| [`docs/`](./docs/README.md) | Getting started, guides, reference, and hardware profiles |
| [`scripts/`](./scripts/) | Reusable benchmark and maintenance utilities |
| `venv/` | Generated local Python environment (not committed) |

## What MLX is

MLX is Apple's machine learning framework designed for Apple Silicon.

`mlx-lm` is the package used to run local language models with MLX.

`mlx_lm.server` exposes an OpenAI-style local HTTP API on port `8080`, so you can connect local models to tools, scripts, and chat clients that speak the OpenAI Chat Completions format.

## Install / Upgrade

```sh
cd mlx
./setup-mlx.sh
```

This creates `mlx/venv` and installs or upgrades `mlx-lm`, `mlx`, and `mlx-metal`. It prints the resolved versions and verifies `mlx_lm.server` after upgrades.

PyTorch is not required. Model execution uses MLX; the included benchmark client uses Transformers only for tokenizer and chat-template utilities.

## Verify The Server Command

```sh
source venv/bin/activate
mlx_lm.server --help
```

If this works, `mlx-lm` is properly installed and ready to use.

## Get A Model From Hugging Face

The simplest path is to pass a Hugging Face repo to `--model`. On first run, `mlx-lm` downloads the model automatically. Later runs reuse the local Hugging Face cache.

```sh
mlx_lm.server --model mlx-community/Qwen2.5-1.5B-Instruct-4bit
```

Hugging Face MLX models are commonly published under [huggingface.co/mlx-community](https://huggingface.co/mlx-community).

## Run The Local Server

This repo includes a small launcher that makes starting the server the default out-of-the-box path.

For `zsh`, add an alias to `~/.zshrc` that points to this script:

```sh
# Add this line to ~/.zshrc, then replace [path-to-your-local-developer-tools-repo] with your local clone path.
alias run-mlx-server='[path-to-your-local-developer-tools-repo]/mlx/run-mlx-server.sh'

source ~/.zshrc
```

Then start the launcher with:

```sh
run-mlx-server
```

What it does:

- activates `mlx/venv`
- lets you pick a model from a numbered menu (or skip it with `--model`)
- downloads from Hugging Face on first use if needed
- starts `mlx_lm.server` on port `8080`

After launch, use:

- Health check: `http://127.0.0.1:8080/health`
- Model list: `http://127.0.0.1:8080/v1/models`
- API endpoint: `http://127.0.0.1:8080/v1/chat/completions`

`mlx_lm.server` does not include a browser chat UI.

### Optional arguments:

```sh
run-mlx-server --m4-48gb
run-mlx-server --model mlx-community/Qwen2.5-1.5B-Instruct-4bit
run-mlx-server --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ
run-mlx-server --m4-48gb --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ
run-mlx-server --model ./models/my-local-mlx-model
```

- `--m4-48gb` applies latency-first cache, concurrency, and prefill defaults for an M4 Max with 48 GB.
- `--model` skips the interactive menu and uses the specified Hugging Face repo or local path.
- `--` passes all remaining options to `mlx_lm.server`, for example `-- --log-level DEBUG`.

## Run Manually

```sh
source venv/bin/activate
mlx_lm.server --model mlx-community/Qwen2.5-1.5B-Instruct-4bit --port 8080
```

## Models To Try

| Model | Good For | Example |
| --- | --- | --- |
| [`mlx-community/Qwen2.5-1.5B-Instruct-4bit`](https://huggingface.co/mlx-community/Qwen2.5-1.5B-Instruct-4bit) | Small, public smoke test for a first MLX launch | `run-mlx-server --model mlx-community/Qwen2.5-1.5B-Instruct-4bit` |
| [`mlx-community/Qwen3.6-35B-A3B-4bit-DWQ`](https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-4bit-DWQ) | Text-only MoE model for reasoning, coding, and tool use; mixed 4-bit and 8-bit quantization | `run-mlx-server --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ` |

The separate [`mlx-community/Qwen3.6-35B-A3B-4bit`](https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-4bit) vision-language conversion requires `mlx-vlm` for image input. This repository's `mlx_lm.server` launcher is text-only.

## Local Cache And Offline Use

- First run with a Hugging Face repo downloads the model.
- Later runs reuse the local Hugging Face cache.

The cache usually lives under the following directory. `HF_HUB_CACHE` or `HF_HOME` can override it.

```txt
~/.cache/huggingface/hub/
```

To remove a cached model, remove the corresponding `models--org--name` folder:

```sh
rm -rf ~/.cache/huggingface/hub/models--mlx-community--Qwen3.6-35B-A3B-4bit-DWQ
```

## Apple Silicon Note

MLX is designed specifically for Apple Silicon. It uses the same unified memory architecture that macOS provides, which makes it a natural fit for modern Macs.

## Official References

- [mlx-lm](https://github.com/ml-explore/mlx-lm)
- [mlx-lm HTTP server](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md)
- [MLX](https://github.com/ml-explore/mlx)
- [MLX Community models](https://huggingface.co/mlx-community)
