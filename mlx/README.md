# mlx

Run local MLX-compatible models on Apple Silicon with [mlx-lm](https://github.com/ml-explore/mlx-lm).

## What MLX is

MLX is Apple's machine learning framework designed for Apple Silicon.

`mlx-lm` is the package used to run local language models with MLX.

`mlx_lm.server` exposes an OpenAI-style local HTTP API on port `8080`, so you can connect local models to tools, scripts, and chat clients that speak the OpenAI Chat Completions format.

## Install / Upgrade

```sh
cd mlx
./setup-mlx.sh
```

This script creates an isolated Python virtual environment inside `mlx/venv` and installs `mlx-lm`. The same command is safe to run repeatedly and will upgrade to the latest version when you run it again.

## Verify The Server Command

```sh
source venv/bin/activate
mlx_lm.server --help
```

If this works, `mlx-lm` is properly installed and ready to use.

## Get A Model From Hugging Face

The simplest path is to pass a Hugging Face repo to `--model`. On first run, `mlx-lm` downloads the model automatically. Later runs reuse the local Hugging Face cache.

```sh
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit
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

- Browser UI / health check: `http://127.0.0.1:8080`
- API endpoint: `http://127.0.0.1:8080/v1/chat/completions`

### Optional arguments:

```sh
run-mlx-server --m4-48gb
run-mlx-server --model mlx-community/Qwen3.6-35B-A3B-4bit
run-mlx-server --m4-48gb --model mlx-community/Qwen3.6-35B-A3B-4bit
run-mlx-server --model ./models/my-local-mlx-model
```

- `--m4-48gb` applies optimized memory and context defaults for a 48 GB Mac.
- `--model` skips the interactive menu and uses the specified Hugging Face repo or local path.

## Run Manually

```sh
source venv/bin/activate
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit --port 8080
```

## Models To Try

| Model | Good For | Example |
| --- | --- | --- |
| `mlx-community/Qwen3.6-35B-A3B-4bit` | MoE Qwen 3.6 variant, strong reasoning and coding | `run-mlx-server --model mlx-community/Qwen3.6-35B-A3B-4bit` |

## Local Cache And Offline Use

- First run with a Hugging Face repo downloads the model.
- Later runs reuse the local Hugging Face cache.

The cache usually lives under:

```txt
~/.cache/huggingface/hub/
```

To remove a cached model, remove the corresponding `models--org--name` folder:

```sh
rm -rf ~/.cache/huggingface/hub/models--mlx-community/Qwen3.6-35B-A3B-4bit
```

## Learn More

| Resource | Covers |
| --- | --- |
| [Hugging Face And Tuning](./hugging-face-and-tuning.md) | Model selection, MLX vs GGUF, context size, and KV cache |
| [mlx-lm Parameters](./mlx-parameters.md) | Most useful `mlx_lm.server` runtime parameters reference |
| [MacBook Pro M4 Max 48GB](./hardware/m4-48gb.md) | Optimized defaults and troubleshooting for 48 GB Macs |

## Apple Silicon Note

MLX is designed specifically for Apple Silicon. It uses the same unified memory architecture that macOS provides, which makes it a natural fit for modern Macs.

## Official References

- [mlx-lm](https://github.com/ml-explore/mlx-lm)
- [MLX](https://github.com/ml-explore/mlx)
- [MLX Community models](https://huggingface.co/mlx-community)
