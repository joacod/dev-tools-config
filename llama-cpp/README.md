# llama.cpp

Run local GGUF models from the terminal with [llama.cpp](https://github.com/ggml-org/llama.cpp)

## What llama.cpp is

`llama.cpp` is a local LLM runtime.

- `llama-cli` runs prompts directly in the terminal
- `llama-server` exposes a local OpenAI-compatible API
- `GGUF` is the model file format `llama.cpp` loads

This makes `llama.cpp` a practical way to chat with models locally, test different model sizes, and connect local models to tools like OpenCode.

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

This repo includes a small wrapper that makes `llama-server` the default out-of-the-box path:

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

`llama-server` is an OpenAI-compatible local HTTP server. After launch, use:

- Browser UI: `http://127.0.0.1:8080`
- API endpoint: `http://127.0.0.1:8080/v1/chat/completions`

Optional arguments:

```sh
run-llama-server --port 8080
run-llama-server --port 8080 --ctx-size 8192
```

What it does:

- Lists cached `llama.cpp` models
- Lets you choose one from a numbered menu
- Starts `llama-server` with `--offline`

The launcher uses `--offline`, so it only starts models already present in the local cache. If the model you want is not installed yet, download it first with `llama-cli -hf ...` or `llama-server -hf ...`.

For predictable results, install and run the full `repo:quant` value you want instead of leaving the quant implicit.

### Run Manually

If you want to skip the launcher, you can still start the server manually with an exact cached model:

```sh
llama-server -hf ggml-org/gemma-4-31B-it-GGUF:Q4_K_M --offline --port 8080
```

### OpenCode

For tools like OpenCode, `llama-server` is usually the right entrypoint. Coding tools usually send more text than normal chat, including system prompts, tool schemas, diffs, and file contents. If prompts start failing or feel cramped, try a larger context.

If you want the simplest first try, omit `--ctx-size` and let the model use its default context. If memory or performance becomes a problem, add it later to cap memory use.

If you need advanced tuning for a single local coding session, run `llama-server` directly. The wrapper in this repo only exposes `--port` and `--ctx-size`.

## Models To Try

These are useful starting points for local testing:

| Model | Good For | Example |
| --- | --- | --- |
| [`ggml-org/gemma-3-1b-it-GGUF`](https://huggingface.co/ggml-org/gemma-3-1b-it-GGUF) | Fast local testing and basic prompting | `llama-cli -hf ggml-org/gemma-3-1b-it-GGUF` |
| [`unsloth/Qwen3.6-27B-GGUF`](https://huggingface.co/unsloth/Qwen3.6-27B-GGUF) | Strong all-around Qwen 3.6 for coding and tool use | `llama-cli -hf unsloth/Qwen3.6-27B-GGUF:UD-Q6_K_XL` |
| [`unsloth/Qwen3.6-35B-A3B-GGUF`](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF) | MoE Qwen 3.6 variant for agentic coding with lower active params | `llama-cli -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_M` |

## Learn More

If you want help understanding model names, quant choices, context size, and common `llama-server` tuning flags, see [Hugging Face And Tuning](./hugging-face-and-tuning.md).

## Apple Silicon Note

`llama.cpp` supports Metal on Apple Silicon, which makes it a strong fit for modern Macs.

## Official References

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Install docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/install.md)
- [Build docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
