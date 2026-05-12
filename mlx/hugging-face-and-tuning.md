# Hugging Face And Tuning

This guide covers the Hugging Face model terms and runtime settings that are useful for `mlx-lm` once you are past the first-run setup.

## Basic Terminology

| Term | Meaning |
| --- | --- |
| MLX | Apple Silicon machine learning framework |
| `mlx-lm` | CLI/Python package for running LLMs with MLX |
| Quantization | Smaller compressed weights, commonly `4bit` |
| Instruct / Chat | Model tuned for assistant-style use |
| Context window | Text the model can consider at once |
| KV cache | Runtime memory used to keep context efficient |

For most local assistant use, start with an Instruct or Chat model instead of a base model.

## What Is DWQ

DWQ (Distilled Weight Quantization) is an MLX-only quantization technique that produces noticeably higher quality than regular 4-bit quantization at the same RAM footprint.

How it works:

1. Starts from a higher-precision model (usually 6-bit).
2. "Distills" the knowledge into 4-bit weights by training the quantization scales and a few extra parameters.
3. Result: same ~20.7 GB RAM usage and speed as regular 4-bit, but quality that "feels like 8-bit in a 4-bit package".

The community-recommended model is `mlx-community/Qwen3.6-35B-A3B-4bit-DWQ`. It consistently outperforms the regular `...-4bit` version on Apple Silicon.

### DWQ vs Regular 4-bit

The MLX community made two separate conversions of Qwen3.6-35B-A3B:

- **`...-4bit-DWQ`** — Quantized with the DWQ technique for maximum text quality. The vision stack was dropped during distillation, so this is a text-only model.
- **`...-4bit`** — Converted with mlx-vlm, keeps the full vision stack for multimodal/image use.

Choose DWQ for reasoning, coding, and text tasks. Choose the regular 4-bit if you need to feed images to the model.

## How To Read A Hugging Face MLX Model Page

When you open a model page on Hugging Face, check these things in order:

1. Is it an MLX-compatible model?
2. Is it an instruct/chat model?
3. Is it already quantized, usually `4bit`?
4. Is the publisher trustworthy?
5. Does the model fit your Mac?

Trust order:

1. Official model publisher, when they publish MLX-compatible weights
2. `mlx-community`
3. Reputable community publishers with clear model cards

## First Download vs Offline Reuse

```sh
run-mlx-server --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ
```

- First run: downloads the model from Hugging Face.
- Later runs: reuse the cached model from `~/.cache/huggingface/hub/`.

The model files stay on disk. You do not need to re-download them unless you delete the cache.

## Use A Local Model Path

```sh
run-mlx-server --model ./models/my-local-mlx-model
```

This is useful when the model is already in a repo folder or converted locally. The path can be absolute or relative to where you run the command.

This first version of the guide focuses on running `mlx-community` models directly from Hugging Face. Model conversion scripts are not included here.

## Context Size And KV Cache

`--prompt-cache-bytes` sets the maximum KV cache memory in bytes in `mlx_lm.server`. It dynamically trims the oldest cache entries when memory pressure approaches the limit, preventing kernel panics or OOM crashes.

For a 48 GB Mac, `--prompt-cache-bytes 20000000000` (20 GB) is the optimal setting that provides ~12–16k effective context while leaving plenty of headroom for model weights and system overhead.

Example:

```sh
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ --prompt-cache-bytes 20000000000
```
