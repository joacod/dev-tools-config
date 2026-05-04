# llama.cpp Parameters

This guide covers the most useful `llama-server` runtime parameters and what they do.

## Parameter Reference

| Flag | Meaning |
| --- | --- |
| `-ngl` | GPU layers to offload. Higher values move more layers to the GPU for faster inference. |
| `-fa` | Flash Attention. Enables a more efficient attention algorithm for faster speeds and better long-context quality. |
| `--cache-type-k` | KV cache key quantization type. Higher precision keeps responses sharper over long conversations. |
| `--cache-type-v` | KV cache value quantization type. Higher precision keeps responses sharper over long conversations. |
| `-b` | Prompt batch size. Larger values speed up initial prompt processing. |
| `-ub` | Upper batch size. Controls the maximum batch size during token generation. |
| `-c` | Context size. Sets how many tokens the model can keep in working memory. |
| `--jinja` | Enables Jinja chat template handling. Required for correct prompting with modern models like Qwen3.6. |
| `--port` | Port the server listens on. Default is `8080`. |
| `--offline` | Runs without network access. Only loads models from local cache. |
| `-np` | Number of parallel streams. Default is `1`. |

## Quantization Types For KV Cache

Common values for `--cache-type-k` and `--cache-type-v`:

- `q4_0`: smallest cache, fastest, but may degrade quality over long chats
- `q8_0`: strong quality, moderate memory use
- `f16`: full precision, best quality, highest memory cost

## Recommended Setup for specific Hardware

### MacBook Pro M4 Max, 48GB RAM

The following parameter combination delivers strong performance and quality for **Qwen3.6-35B-A3B** (recommended) and **Qwen3.6-27B** (strong alternative):

```sh
llama-server -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q6_K_XL --offline --port 8080 -ngl 99 -fa 1 --cache-type-k q8_0 --cache-type-v q8_0 -b 2048 -ub 2048 -c 131072 --jinja
```

- **Model**: `Qwen3.6-35B-A3B` MoE is the best daily-driver on 48GB — only ~3B active params per token, but stronger reasoning, coding, and tool-use than the dense 27B
- **Quant**: `UD-Q6_K_XL` (~31.8 GB) or `UD-Q5_K_XL` (~26.6 GB) — both leave plenty of room for the 128k KV cache. If you prefer more speed, `UD-Q4_K_XL` (~22 GB) is still very high quality
- `-ngl 99` → full Metal GPU offload (biggest speed win)
- `-fa 1` → Flash Attention (faster + better long-context quality)
- `--cache-type-k q8_0 --cache-type-v q8_0` → high-precision KV cache (keeps responses sharp over long chats)
- `-b 2048 -ub 2048` → large prompt batch size (much faster initial processing)
- `-c 131072` → usable context length (Qwen3.6's native strength)
- `--jinja` → correct modern chat template handling (free quality boost, harmless elsewhere)

If you'd rather run the dense **Qwen3.6-27B**, keep the exact same command and swap the model to `unsloth/Qwen3.6-27B-GGUF:UD-Q6_K_XL`.

### MacBook Air M2, 16GB RAM

The practical Qwen3.6 option on 16GB is the **35B-A3B MoE** — only ~3–4B active parameters per token, but with much stronger reasoning and tool-use than a true 8B model.

Best quant for this hardware: **UD-IQ2_XXS** (~10.8 GB), **UD-Q2_M** (~11.5 GB)

```sh
llama-server -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-IQ2_XXS --offline --port 8080 -ngl 99 -fa 1 --cache-type-k q8_0 --cache-type-v q8_0 -b 512 -ub 512 -c 16384 --jinja
```

- Model: `Qwen3.6-35B-A3B` MoE — the only Qwen3.6 variant that fits comfortably and performs well on 16GB
- Quant: Ultra-low 2-bit `IQ2_XXS` to leave headroom for KV cache and system use
- `-b 512 -ub 512`: Small prompt batch size to avoid swapping or crashing on 16GB
- `-c 16384`: Safe realistic context on 16GB
- `-ngl 99` and `-fa 1`: Kept (M2 Metal still benefits hugely)
- `--cache-type-k/v q8_0`: Kept (small context keeps memory use low)
- `--jinja`: Kept (required for Qwen3.6 chat formatting)

Expected speed: ~12–25 tokens/sec generation. If you ever get OOM, drop `-ngl` to `60` or lower to let some layers run on CPU.
