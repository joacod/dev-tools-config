# llama.cpp

Run local GGUF models from the terminal with [llama.cpp](https://github.com/ggml-org/llama.cpp)

## What llama.cpp is

`llama.cpp` is a local LLM runtime.

- `llama-cli` runs prompts directly in the terminal
- `llama-server` exposes a local OpenAI-compatible API
- `GGUF` is the model file format `llama.cpp` loads

This makes `llama.cpp` a practical way to chat with models locally, test different model sizes, and connect local models to tools like OpenCode.

For a controlled comparison with MLX, oMLX, and MTPLX, see the [Local AI overview](../local-ai/README.md) and [fair comparison plan](../local-ai/benchmarking.md).

## Install

Install `llama.cpp` with Homebrew.

```sh
brew install llama.cpp
```

## Verify The Binaries

Check that the main binaries are available.

```sh
llama-cli --help
llama-server --help
```

## Get A GGUF Model From Hugging Face

For most `llama.cpp` users, Hugging Face is the main place to find `GGUF` models, and it is where much of the community publishes them.

The simplest way to get started is to let `llama.cpp` download a compatible model directly from a Hugging Face repo.

```sh
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF
```

Run a one-off prompt:

```sh
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF -p "Explain recursion in simple terms."
```

`llama.cpp` expects models in `GGUF` format. The `-hf <user>/<model>[:quant]` flag downloads a compatible model directly.

### Remove A Downloaded Model

Models downloaded with `-hf` are typically cached under `~/.cache/huggingface/hub/`.

For the `ggml-org/gemma-3-1b-it-GGUF` example above, remove the cached model with:

```sh
rm -rf ~/.cache/huggingface/hub/models--ggml-org--gemma-3-1b-it-GGUF
```

## Run The Local Server

This repo includes a small wrapper that makes `llama-server` the default out-of-the-box path.

For `zsh`, add an alias to `~/.zshrc` that points to this script:

```sh
# Add this line to ~/.zshrc, then replace [path-to-your-local-developer-tools-repo] with your local clone path.
alias run-llama-server='[path-to-your-local-developer-tools-repo]/llama-cpp/run-llama-server.sh'

source ~/.zshrc
```

Then start the launcher with:

```sh
run-llama-server
```

What it does:

- Lists downloaded `llama.cpp` models
- Lets you choose one from a numbered menu
- Starts `llama-server` (an OpenAI-compatible local HTTP server) on port `8080` with `--offline` (only starts models already present in the local cache)

After launch, use:

- Browser UI: `http://127.0.0.1:8080`
- API endpoint: `http://127.0.0.1:8080/v1/chat/completions`

### Optional arguments:

```sh
run-llama-server --m4-48gb
run-llama-server --m2-16gb
```

These flags apply optimized parameters for specific hardware. See the full breakdown:

| Hardware | Config |
| --- | --- |
| MacBook Pro M4 Max 48GB | [hardware/m4-48gb.md](./hardware/m4-48gb.md) |
| MacBook Air M2 16GB | [hardware/m2-16gb.md](./hardware/m2-16gb.md) |

### Run Manually

If you want to skip the launcher, you can still start the server manually with an exact cached model:

```sh
llama-server -hf ggml-org/gemma-3-1b-it-GGUF --offline --port 8080
```

## Models To Try

These are useful starting points for local testing:

| Model | Good For | Example |
| --- | --- | --- |
| [`ggml-org/gemma-3-1b-it-GGUF`](https://huggingface.co/ggml-org/gemma-3-1b-it-GGUF) | Fast local testing and basic prompting | `llama-cli -hf ggml-org/gemma-3-1b-it-GGUF` |
| [`unsloth/Qwen3.6-27B-GGUF`](https://huggingface.co/unsloth/Qwen3.6-27B-GGUF) | Strong all-around Qwen 3.6 for coding and tool use (best on 32GB+ RAM) | `llama-cli -hf unsloth/Qwen3.6-27B-GGUF:UD-Q6_K_XL` |
| [`unsloth/Qwen3.6-35B-A3B-GGUF`](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF) | MoE Qwen 3.6 variant — stronger reasoning and coding than 27B, fits well on 48GB with Q5/Q6 quants | `llama-cli -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q6_K_XL` |

## Learn More

| Resource | Covers |
| --- | --- |
| [Hugging Face And Tuning](./hugging-face-and-tuning.md) | Model names, quant choices, context size, and common `llama-server` tuning flags |
| [llama.cpp Parameters](./llama-cpp-parameters.md) | Most useful `llama-server` runtime parameters reference |

## Apple Silicon Note

`llama.cpp` supports Metal on Apple Silicon, which makes it a strong fit for modern Macs.

## Official References

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Install docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/install.md)
- [Build docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
