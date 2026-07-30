# Hugging Face And Tuning

This reference covers Hugging Face model terms and runtime settings that are useful for `mlx-lm` once you are past the first-run setup. To research current models for a specific Mac, use the [Model Selection Research Brief](../guides/model-selection.md).

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

DWQ means Distilled Weight Quantization. Quality and performance depend on the specific conversion and should be verified with benchmarks.

For `mlx-community/Qwen3.6-35B-A3B-4bit-DWQ`, note that:

- the repository is approximately 20.7 GB on disk
- its configuration uses mixed quantization: many expert projections are 4-bit while other weights are 8-bit
- the Hugging Face model card does not publish quality or speed benchmarks
- it is published for text generation and contains no vision weights

### DWQ vs Regular 4-bit

The MLX community publishes two conversions with different runtimes:

- **`...-4bit-DWQ`** - text-only mixed-quantization model for `mlx-lm`
- **`...-4bit`** - vision-language conversion published for `mlx-vlm`

This repository's `run-mlx-server` launcher always starts `mlx_lm.server`, whose chat endpoint accepts text content only. It cannot serve image input from the vision-language conversion. For images, install and use `mlx-vlm` separately as shown on that model's Hugging Face page.

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

The model files stay on disk. You do not need to download them again unless the cache is removed or the requested revision changes.

## Use A Local Model Path

```sh
run-mlx-server --model ./models/my-local-mlx-model
```

This is useful when the model is already in a repository folder or converted locally. Absolute paths are passed through. Paths beginning with `./` or `../` are resolved relative to the directory where you invoke `run-mlx-server`.

This guide focuses on running existing `mlx-community` models. Model conversion is not covered.

## Context Size And KV Cache

Context length and retained-cache budget are different controls:

- The model configuration advertises its supported position range.
- Request prompt and completion tokens determine the active sequence length.
- `--prompt-cache-size` limits the number of reusable in-memory cache entries.
- `--prompt-cache-bytes` is used by the batchable server path to trim retained entries relative to active cache accounting.

`--prompt-cache-bytes` does not set the context window, monitor macOS memory pressure, or guarantee OOM prevention. Cache use is model-dependent.

For the M4 Max 48 GB single-agent profile, start with:

```sh
mlx_lm.server \
  --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ \
  --prompt-cache-size 4 \
  --prompt-cache-bytes 4000000000
```

See [MacBook Pro M4 Max 48GB](../hardware/m4-max-48gb.md) for this model's cache formula and memory table.
