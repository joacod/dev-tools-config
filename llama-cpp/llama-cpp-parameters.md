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

The following parameter combination delivers strong performance and quality for models like Qwen3.6-27B:

```sh
llama-server -hf unsloth/Qwen3.6-27B-GGUF:UD-Q6_K_XL --offline --port 8080 -ngl 99 -fa 1 --cache-type-k q8_0 --cache-type-v q8_0 -b 2048 -ub 2048 -c 131072 --jinja
```

- `-ngl 99` → full Metal GPU offload (biggest speed win)
- `-fa 1` → Flash Attention (faster + better long-context quality)
- `--cache-type-k q8_0 --cache-type-v q8_0` → high-precision KV cache (keeps responses sharp over long chats)
- `-b 2048 -ub 2048` → large prompt batch size (much faster initial processing)
- `-c 131072` → usable context length (Qwen3.6's native strength)
- `--jinja` → correct modern chat template handling (free quality boost for Qwen3.6, harmless elsewhere)

### MacBook Air M2, 16GB RAM

Use the `UD-Q3_K_XL` quant and the following parameters for Qwen3.6-27B:

```sh
llama-server -hf unsloth/Qwen3.6-27B-GGUF:UD-Q3_K_XL --offline --port 8080 -ngl 99 -fa 1 --cache-type-k q8_0 --cache-type-v q8_0 -b 512 -ub 512 -c 16384 --jinja
```

- Quant: Dropped from `UD-Q6_K_XL` to `UD-Q3_K_XL` (weights alone must leave room for system + KV cache)
- `-b 512 -ub 512`: Smaller prompt batch size to avoid swapping or crashing on 16GB
- `-c 16384`: Realistic max context on 16GB
- `-ngl 99` and `-fa 1`: Kept (M2 Metal still benefits hugely)
- `--cache-type-k/v q8_0`: Kept (small context keeps memory use low)
- `--jinja`: Kept (required for Qwen3.6 chat formatting)

Expected speed: ~8-18 tokens/sec generation. If you ever get OOM, drop `-ngl` to `60` or lower to let some layers run on CPU.
