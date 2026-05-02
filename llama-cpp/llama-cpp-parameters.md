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

## Recommended Setup: MacBook Pro M4 Max, 48GB RAM

For this hardware, the following parameter combination delivers strong performance and quality for models like Qwen3.6-27B:

```sh
llama-server -hf unsloth/Qwen3.6-27B-GGUF:UD-Q6_K_XL --offline --port 8080 -ngl 99 -fa 1 --cache-type-k q8_0 --cache-type-v q8_0 -b 2048 -ub 2048 -c 131072 --jinja
```

What each flag does:

- `-ngl 99` → full Metal GPU offload (biggest speed win)
- `-fa 1` → Flash Attention (faster + better long-context quality)
- `--cache-type-k q8_0 --cache-type-v q8_0` → high-precision KV cache (keeps responses sharp over long chats)
- `-b 2048 -ub 2048` → large prompt batch size (much faster initial processing)
- `-c 131072` → usable context length (Qwen3.6's native strength)
- `--jinja` → correct modern chat template handling (free quality boost for Qwen3.6, harmless elsewhere)

If you run into memory pressure, reduce `-c` first. `65536` is a comfortable fallback that still supports very long conversations.
