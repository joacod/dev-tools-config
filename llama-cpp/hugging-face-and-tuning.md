# Hugging Face And Tuning

This guide covers the `llama.cpp` terms and runtime settings that are useful once you are past the first-run setup.

For most `llama.cpp` users, Hugging Face is the main place to find `GGUF` models, and it is where much of the community publishes them.

## Basic Terminology

| Term | Meaning |
| --- | --- |
| Model | The actual model family, such as Gemma, Qwen, or Llama. |
| GGUF | A local model format that packages weights and metadata for direct use in `llama.cpp`. |
| Quantization | Compressing model weights so the model is smaller and easier to run. |
| Quant | A specific compressed variant, such as `Q4_K_M` or `Q8_0`. |
| Base model | A raw model, usually not tuned for assistant-style chat. |
| Instruct / IT / Chat | A model tuned for prompts, chat, Q&A, and coding help. |
| Dense model | A traditional model where all parameters are used for every token during inference. |
| MoE | Mixture of Experts. A model with many expert subnetworks where only a few are activated per token. |
| Total parameters | The full size of the model, which usually matters for storage, loading, and overall memory footprint. |
| Active parameters | The parameters actually used for each token during inference. This is more relevant to speed and compute cost. |
| Context window | How much text the model can keep in working memory for the current request. |
| KV cache | Temporary memory the model uses to keep long prompts and chats fast. Larger contexts use more KV cache memory. |

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

## Context Size And KV Cache

Use `-c` to set the context window size.

```sh
llama-cli -hf ggml-org/gemma-4-31B-it-GGUF:Q4_K_M -c 4096
```

`-c 4096` means the model can keep about 4096 tokens of prompt and conversation history in working memory.

That working memory relies heavily on the KV cache, which is why longer contexts usually need more RAM or unified memory.

- Smaller context: less memory usage
- Larger context: more room for longer chats, larger prompts, and coding tools

At very large contexts, the KV cache becomes a major part of memory use. If you need longer coding sessions on limited hardware, `llama-server` also supports KV cache quantization with `--cache-type-k` and `--cache-type-v`.

Context size is a runtime setting. You can change it later without downloading the model again.

## Model Size vs Active Parameters

Many newer open models, including some Qwen releases, use `MoE` instead of a `Dense` architecture.

- `Dense` model: all parameters are active for every token.
- `MoE` model: only a subset of experts is active for each token.

That is why some model names include both total and active parameter counts:

- `Qwen3-30B-A3B`: about `30B` total parameters, about `3B` active per token
- `Qwen3-235B-A22B`: about `235B` total parameters, about `22B` active per token

As a rule of thumb:

- Total parameters tell you more about model capacity and model size.
- Active parameters tell you more about inference speed and compute cost.

So an `MoE` model like `30B-A3B` is not a direct comparison with a `Dense` `30B` or `32B` model. For local use, an `MoE` model can be much cheaper to run while still performing surprisingly well.

## Advanced llama-server Notes

Online examples often mix short and long flag names. These common pairs are equivalent:

- `-m` = `--model`
- `-ngl` = `--gpu-layers`
- `-c` = `--ctx-size`
- `-np` = `--parallel`
- `-fa` = `--flash-attn`

If you want to run `llama-server` directly instead of using the launcher, the same tuning flags still apply:

```sh
llama-server \
  -hf Jackrong/Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-GGUF \
  --offline \
  -c 65536 \
  -ngl all \
  -np 1 \
  -fa on \
  --cache-type-k q4_0 \
  --cache-type-v q4_0
```

Many shared examples use `-ngl 99` to mean "offload as much as possible to the GPU." `--gpu-layers all` is the clearer version of that idea, so this repo uses `all` in examples.

Start lower if you are unsure about your hardware. `--ctx-size 32768` or `65536` is a safer first step than `131072` on most local machines, and reducing context is usually the first fix if the server runs out of memory. Treat `131072` as an aggressive long-context tuning choice, not a general default.

By default, `llama-server` listens on `127.0.0.1`, which keeps it local to your machine. If you set `--host 0.0.0.0`, the server listens on all interfaces and may become reachable from other machines on your network, so only use that when you intentionally want network access.
