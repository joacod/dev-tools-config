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
