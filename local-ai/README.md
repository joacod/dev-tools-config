# Local AI Inference

Run and compare local language-model servers on Apple Silicon. These guides are copyable setup notes; they do not install packages, download models, or start servers automatically.

## Runtime guides

| Runtime | Best first question | Guide |
| --- | --- | --- |
| MLX / `mlx-lm` | What is the current single-agent baseline? | [`../mlx`](../mlx) |
| `llama.cpp` | How does the same family behave with GGUF and Metal? | [`../llama-cpp`](../llama-cpp) |
| oMLX | Does batching and tiered KV caching improve daily-agent use? | [`../omlx`](../omlx) |
| MTPLX | How much does native MTP speculative decoding improve Qwen 3.8 decode? | [`../mtplx`](../mtplx) |

Use the [fair comparison plan](./benchmarking.md) after each runtime can serve a smoke-test request.

## Starting point for an M4 Mac with 48 GB

The target in this experiment is a **dense Qwen3.8 27B** model, not the existing Qwen3.6 MoE profile. Keep those results as separate baselines: dense and MoE models have different weight footprints, active compute, cache behavior, and quality trade-offs.

| Candidate | First use | Why it belongs in the first pass | Important caveat |
| --- | --- | --- | --- |
| [`Youssofal/Qwen3.8-27B-MTPLX-Optimized-Speed`](https://huggingface.co/Youssofal/Qwen3.8-27B-MTPLX-Optimized-Speed) | MTPLX | 4-bit dynamic quantization with the native MTP head retained; the model card recommends it for coding on Macs with 32 GB or more. | The model is about 21.3 GB on disk; disk size is not the same as runtime memory. Start with a conservative context and measure headroom. |
| `Qwen3.8-27B-MLX-oQ4e-mtp` | oMLX | The current oMLX benchmark catalog uses this 4-bit oQ/MTP model label on 48 GB M4 hardware. | Select it from oMLX's model downloader and record the actual Hugging Face repository and revision. Do not assume the catalog label is a repository ID or that an MTPLX checkpoint is interchangeable. |
| Existing `mlx-lm` profile | MLX | Provides the repository's measured Apple Silicon workflow and a known OpenAI-compatible API. | The tracked M4 profile uses `Qwen3.6-35B-A3B-4bit-DWQ`, a MoE model; it is an operational baseline, not a controlled dense-model comparison. |
| Existing GGUF profile | `llama.cpp` | Shows how a GGUF runtime behaves on the same machine and API shape. | Use a Qwen3.8 GGUF only after verifying that the exact model and quant exist. Otherwise label the existing Qwen3.6 GGUF run as a separate family baseline. |

The MTPLX model has a native MTP contract. A server that can load ordinary MLX safetensors is not automatically able to use that MTP path. Record the exact model repository, revision, quantization layout, and runtime mode for every result.

## Shared local-server rules

- Run only one large model server at a time. The existing MLX and `llama.cpp` launchers use port `8080`; oMLX and MTPLX use `8000` by default.
- Keep the bind address on `127.0.0.1` unless remote access is intentional and authenticated.
- Check `/health` and `/v1/models` before sending benchmark requests.
- Use one model, one active request, and a fixed context/generation policy for the first comparison. Tune concurrency, SSD caching, KV-cache precision, MTP depth, and thermal settings in a later pass.
- Treat a model download as a separate decision from a server install. Confirm free disk and memory headroom first.

## API shape

All four runtimes can expose an OpenAI-compatible chat endpoint, but their model IDs and metrics differ. Use the ID returned by the running server rather than guessing it:

```sh
curl http://127.0.0.1:<port>/health
curl http://127.0.0.1:<port>/v1/models
```

Then send a small smoke-test request:

```sh
curl http://127.0.0.1:<port>/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "<id-from-v1-models>",
    "messages": [{"role": "user", "content": "Reply with: local server is ready."}],
    "temperature": 0,
    "max_tokens": 32,
    "stream": false
  }'
```

For coding tools, the usual OpenAI-compatible base URL is `http://127.0.0.1:<port>/v1`. Keep runtime-specific configuration in the tool's own guide.

## Official references

- [oMLX](https://github.com/jundot/omlx)
- [MTPLX](https://github.com/youssofal/MTPLX)
- [MLX LM](https://github.com/ml-explore/mlx-lm)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)
