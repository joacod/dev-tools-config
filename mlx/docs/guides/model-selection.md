# MLX Model Selection Research Brief

This document is a self-contained prompt for an AI with web access and, ideally, terminal access to the target Mac. Paste the entire document into the AI. Its task is to research current MLX models and recommend the best-supported options for this machine and workload.

Do not rely on model names or recommendations already present in this repository. Model availability, conversions, runtime support, and community experience change quickly; perform fresh online research every time.

## Task And Scope

Research and rank instruction-tuned, text-only models that:

- are available in MLX format from `mlx-community` or another reputable publisher
- are supported by the installed `mlx-lm`
- leave practical unified-memory headroom for macOS, development tools, and context cache
- match the requested coding, reasoning, context, and tool-use workload
- have enough primary-source and community evidence to justify their download size

This task is research and recommendation only. Do not download models, start or stop servers, upgrade packages, edit files, tune parameters, or run benchmarks. End with an exact `run-mlx-server --model ORG/MODEL` command for the recommended model. The user will launch it and qualify its runtime parameters separately.

If terminal access is unavailable, ask the user for the machine details and installed package versions required below. If workload requirements are missing, ask concise questions before ranking candidates.

When terminal access is available, run commands from the repository root, the directory that contains `mlx/`.

## 1. Inspect The Mac And Runtime

Inspect and report the machine before searching for models:

```sh
sysctl -n hw.model hw.memsize hw.ncpu
system_profiler SPHardwareDataType SPDisplaysDataType
sw_vers
df -h .
mlx/venv/bin/python -c 'import mlx.core as mx; print(mx.device_info())'
mlx/venv/bin/python -c 'from importlib.metadata import version; print("mlx-lm", version("mlx-lm")); print("mlx", version("mlx")); print("mlx-metal", version("mlx-metal"))'
mlx/venv/bin/mlx_lm.server --help
```

Also identify the applications that must remain open. Unified memory is shared by the model, KV cache, MLX allocations, macOS, the IDE, browser, and every other process.

## 2. Define The Workload

Determine the requirements that affect model choice:

- primary tasks: completion, focused edits, debugging, tests, agentic tool use, or repository-wide changes
- languages and frameworks
- expected prompt size and desired response length
- one active request or concurrent clients
- latency versus output-quality priority
- text-only or image input
- acceptable download size and free disk space

A small model can be useful for completion and focused changes without being reliable for architecture decisions or large multi-file refactors. Do not turn "fits in memory" into a quality claim.

## 3. Discover Current Candidates And Sources

Search current sources rather than relying on memory or search-result summaries. Open and inspect the underlying pages.

Start with:

- current [`mlx-community` model activity](https://huggingface.co/organizations/mlx-community/activity/models)
- Hugging Face searches for workload terms such as `coder`, `code`, `instruct`, `reasoning`, and `tool use`
- the original model publisher's card, evaluations, license, and release notes
- [`mlx-lm`](https://github.com/ml-explore/mlx-lm) source, releases, issues, and discussions for architecture support and known failures
- Hugging Face model discussions and issues for the exact conversion
- relevant MLX and local-model communities, including comparable-machine reports in forums and communities such as `r/LocalLLaMA`
- reproducible third-party benchmarks when their model revision, quantization, runtime, hardware, context, and test method are disclosed

For repeatable research, the Hugging Face API can provide current metadata:

```txt
https://huggingface.co/api/models?author=mlx-community&search=coder&sort=downloads&direction=-1&limit=50&full=true
https://huggingface.co/api/models?author=mlx-community&sort=lastModified&direction=-1&limit=100&full=true
https://huggingface.co/api/models/ORG/MODEL?blobs=true
```

Search beyond the newest models. Recent uploads have little adoption evidence, while older supported models can remain the better operational choice. Treat search snippets, generated summaries, popularity, and unsourced recommendation lists as discovery aids rather than evidence.

## 4. Apply Hard Filters

Reject a candidate before ranking it when any required check fails.

### Runtime And Architecture

- Fetch `config.json` and record `model_type` and `architectures`.
- Check the installed `mlx_lm` loader and model implementations for that exact type or an explicit remapping.
- Do not infer compatibility from an `mlx` tag, `library_name`, repository name, or model-card example alone.
- Treat custom modeling code, novel architectures, and conflicting metadata as unsupported until verified.
- Confirm the repository contains the weight layout expected by the current loader.

An unsupported architecture may download completely and then fail while the server loads the model. The HTTP process may continue answering `/health` even though generation is unavailable.

### Task And Modality

- Require an Instruct, Chat, or assistant-tuned model with a chat template.
- Exclude Base models for normal coding-agent use.
- This repository uses text-only `mlx_lm.server`. Exclude VLM, image, audio, video, OCR, embedding, and diffusion models.
- Inspect repository files for processors or separate vision/audio weights when metadata is ambiguous.

### Memory And Quantization

- Use actual weight-file bytes from repository metadata, not parameter count alone.
- Add headroom for MLX allocations, KV cache, prompts, macOS, and development applications.
- Weight quantization does not quantize the KV cache or guarantee that advertised context is practical.
- Penalize ambiguous mixed quantization, conflicting bit labels, and very low-bit conversions unless current runtime support and quality evidence are clear.

For a 16 GB Mac used alongside an IDE, a roughly 4-5 GB 4-bit model is a conservative starting class. An 8-9 GB model may load but leaves much less room for useful context and other applications. These are screening heuristics, not measured limits.

## 5. Evaluate Evidence

Rank surviving candidates with evidence from different source types:

| Evidence | What it can establish |
| --- | --- |
| Exact Hugging Face repository files and config | Architecture, quantization, weight bytes, chat template, and modality |
| Installed and upstream `mlx-lm` source, releases, and issues | Runtime compatibility and known failures |
| Original model card and evaluations | Intended workload and comparative quality |
| Conversion model card | Conversion method and required runtime |
| Current downloads, likes, and Hugging Face discussions | Adoption and conversion-specific problem signals, not quality proof |
| Reports from comparable Macs and workloads | Possible speed, memory, quality, and usability; usually anecdotal |
| Reproducible independent benchmarks | Comparative evidence within the benchmark's exact scope |

For community reports, record the URL, publication date, hardware, runtime, quantization, context, and task. A GGUF result from Ollama can inform model-quality expectations but does not establish MLX compatibility or speed. Prefer multiple independent reports, avoid repeating claims that cannot be traced to their source, and state when evidence conflicts.

Use a shortlist instead of declaring one universal winner:

| Candidate | Coding evidence | Compatibility confidence | Weight bytes | Expected headroom | Community evidence | Risks |
| --- | --- | --- | ---: | --- | --- | --- |
| `ORG/MODEL` | Why it matches | Verified facts | Exact or estimated | High/medium/low | Linked summary | Unknowns |

## 6. Produce The Recommendation

Return a self-contained report with these sections:

1. **Target machine**: exact hardware, usable MLX working set, installed runtime versions, free disk, and applications competing for memory.
2. **Workload assumptions**: tasks, languages, expected context, concurrency, and quality-versus-latency priority. Clearly mark assumptions the user did not provide.
3. **Research date and sources**: link every important source and distinguish primary documentation, measured evidence, and community anecdotes.
4. **Hard-filter results**: briefly list attractive candidates rejected for unsupported architecture, wrong modality, missing chat tuning, unsafe memory use, stale packaging, or weak evidence.
5. **Ranked shortlist**: include at least three viable candidates when available, using the comparison table above.
6. **Recommendation**: select one model, explain why it is the best fit, state what it will likely do well, and state where its size or capability will fall short.
7. **Runner-up**: identify when the alternative is preferable, such as trading responsiveness for quality or preserving more context headroom.
8. **Exact next command**:

```sh
run-mlx-server --model ORG/MODEL
```

Include the exact expected download size, cache location, license, compatibility confidence, and unresolved risks before the command. Do not claim that a model is "best" without scoping the claim to this machine, workload, evidence, and research date.
