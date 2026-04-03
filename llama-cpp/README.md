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

## Run A Model From Hugging Face

The simplest way to get started is to let `llama.cpp` download a compatible GGUF model from Hugging Face.

```sh
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF
```

Run a one-off prompt:

```sh
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF -p "Explain recursion in simple terms."
```

`llama.cpp` expects models in `GGUF` format. The `-hf <user>/<model>[:quant]` flag downloads a compatible model directly.

## Basic Terminology

| Term | Meaning |
| --- | --- |
| Model | The actual model family, such as Gemma, Qwen, or Llama. |
| GGUF | A local model format that packages weights and metadata for direct use in `llama.cpp`. |
| Quantization | Compressing model weights so the model is smaller and easier to run. |
| Quant | A specific compressed variant, such as `Q4_K_M` or `Q8_0`. |
| Base model | A raw model, usually not tuned for assistant-style chat. |
| Instruct / IT / Chat | A model tuned for prompts, chat, Q&A, and coding help. |
| Context window | How much text the model can keep in working memory for the current request. |

For most local assistant use, start with an `Instruct`, `it`, or `Chat` model instead of a base model.

## How To Read A Hugging Face GGUF Page

When you open a model page on Hugging Face, check these things in order:

1. Is it a `GGUF` repo?
2. Is it an `Instruct`, `it`, or `Chat` model?
3. Does the Files tab include `.gguf` files?
4. Does the model card recommend a quant such as `Q4_K_M`?
5. Who published it?

As a beginner, trust sources in this order:

1. Official model publisher GGUF repo
2. [`ggml-org`](https://huggingface.co/ggml-org)
3. Well-known community quantizers with a clear model card

Many GGUF repos are quantized copies of an upstream model. That usually means the original model was converted to `GGUF` and published in a local-friendly format.

## Choose The Right Quant

Common quant names:

- `Q4_K_M`: safest default for most people
- `Q5_K_M`: better quality, more memory
- `Q6_K`: higher quality, heavier
- `Q8_0`: strong quality, much heavier
- `F16` or `BF16`: very large, usually only for strong hardware

Simple rule:

- Smaller quant: easier to run
- Larger quant: usually better quality

For a new model, start with `Q4_K_M`. If it runs comfortably, try a larger quant.

## Use -hf With An Explicit Quant

If a repo contains multiple GGUF files, specify the quant you want.

```sh
llama-cli -hf ggml-org/gemma-4-31B-it-GGUF:Q4_K_M
```

In that command:

- `ggml-org/gemma-4-31B-it-GGUF` is the Hugging Face repo
- `:Q4_K_M` selects the exact quantized GGUF file

If you leave off `:Q4_K_M`, `llama.cpp` can still choose a file from the repo, but being explicit gives you predictable results.

## Context Size

Use `-c` to set the context window size.

```sh
llama-cli -hf ggml-org/gemma-4-31B-it-GGUF:Q4_K_M -c 4096
```

`-c 4096` means the model can keep about 4096 tokens of prompt and conversation history in working memory.

- Smaller context: less memory usage
- Larger context: more room for longer chats, larger prompts, and coding tools

Context size is a runtime setting. You can change it later without downloading the model again.

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

### OpenCode

For tools like OpenCode, `llama-server` is usually the right entrypoint. Coding tools usually send more text than normal chat, including system prompts, tool schemas, diffs, and file contents. If prompts start failing or feel cramped, try a larger context.

If you want the simplest first try, omit `--ctx-size` and let the model use its default context. If memory or performance becomes a problem, add it later to cap memory use.

### Run Manually

If you want to skip the launcher, you can still start the server manually with an exact cached model:

```sh
llama-server -hf ggml-org/gemma-4-31B-it-GGUF:Q4_K_M --offline --port 8080
llama-server -hf ggml-org/Qwen3-Coder-30B-A3B-Instruct-Q8_0-GGUF:Q8_0 --offline --port 8080
```

## Models To Try

These are useful starting points for local testing:

| Model | Good For | Example |
| --- | --- | --- |
| `ggml-org/gemma-3-1b-it-GGUF` | Fast local testing and basic prompting | `llama-cli -hf ggml-org/gemma-3-1b-it-GGUF` |
| `ggml-org/gemma-4-31B-it-GGUF` | Larger instruct model from a high-trust GGUF publisher | `llama-cli -hf ggml-org/gemma-4-31B-it-GGUF:Q4_K_M` |
| `ggml-org/Qwen3-Coder-30B-A3B-Instruct-Q8_0-GGUF` | Larger coding-focused model if you have strong hardware | `llama-cli -hf ggml-org/Qwen3-Coder-30B-A3B-Instruct-Q8_0-GGUF` |

If you have more hardware headroom, try larger quants such as `Q5_K_M`, `Q6_K`, or `Q8_0` when the repo provides them.

## Apple Silicon Note

`llama.cpp` supports Metal on Apple Silicon, which makes it a strong fit for modern Macs.

## Official References

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Install docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/install.md)
- [Build docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
