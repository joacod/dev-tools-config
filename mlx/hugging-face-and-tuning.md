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
run-mlx-server --model mlx-community/Qwen3.6-35B-A3B-4bit
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

`--max-kv-size` controls the rotating KV cache size in `mlx_lm.server`.

- Lower value: less memory, shorter reliable context
- Higher value: more memory, better long-context behavior

Example:

```sh
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit --max-kv-size 8192
```

For a 48 GB Mac, `--max-kv-size 8192` is a safe starting point that balances context length and memory. Higher values like `16384` are possible but use more memory and should be treated as optional advanced settings.
