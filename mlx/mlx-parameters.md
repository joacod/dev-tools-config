# mlx-lm Parameters

This guide covers the most useful `mlx_lm.server` runtime parameters for this repo.

## Parameter Reference

| Flag | Meaning |
| --- | --- |
| `--model` | Hugging Face repo or local model path to load |
| `--port` | Server port. This repo uses `8080` |
| `--host` | Server host. Keep local by default; only use `0.0.0.0` intentionally |
| `--max-kv-size` | Rotating KV cache size. Larger uses more memory but helps longer context |
| `--trust-remote-code` | Allows model-specific tokenizer/model code when required |

## Request-Time Parameters

Many generation settings are sent in the API request body instead of the startup command. This lets you change them per-request without restarting the server.

Common request-time parameters:

- `temperature` — Controls randomness. Lower is more deterministic.
- `top_p` — Nucleus sampling threshold.
- `max_tokens` — Maximum number of tokens in the response.
- `stream` — Whether to stream tokens as they are generated (`true` or `false`).

Example request:

```sh
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Explain recursion in simple terms."}],
    "temperature": 0.7,
    "top_p": 0.9,
    "max_tokens": 512,
    "stream": false
  }'
```
