# OpenRouter

[OpenRouter](https://openrouter.ai/) is a unified API and model catalog that makes it easy to switch between LLM providers and models without changing tools every time.

## Why I Use It

For my setup, OpenRouter is useful because it gives me one place to:

- test different model families without rebuilding my workflow
- use strong daily models for agents like Hermes
- keep a cheaper or more available fallback ready
- use provider routing when I want to bias for cost, speed, or lower data retention

This page is a living shortlist of models I am using or actively tracking.

## Recommended Models

This is a practical shortlist, not a fixed ranking.

Model quality, pricing, tool use behavior, and provider availability can change quickly, so I'll keep this page updated as I try new models.

### Coding Models

| Model | Link | Notes |
| --- | --- | --- |
| `z-ai/glm-5.1` | [GLM 5.1](https://openrouter.ai/z-ai/glm-5.1) | Strong coding model worth keeping in regular rotation. Good candidate for harder implementation work when I want a capable non-default option. |
| `moonshotai/kimi-k2.6` | [Kimi K2.6](https://openrouter.ai/moonshotai/kimi-k2.6) | Promising coding-first model with a 262k context window. Looks especially worth testing for long-horizon implementation work, coding-driven UI generation, and more agentic multi-step tasks. |
| `moonshotai/kimi-k2.5` | [Kimi K2.5](https://openrouter.ai/moonshotai/kimi-k2.5) | Earlier Kimi model still worth tracking as a lighter comparison point against K2.6 for everyday coding use. |

### Models For Agents

These are the models I would look at first for daily agent use, where tool use, reliability, and price matter more than pure benchmark appeal.

| Model | Link | Notes |
| --- | --- | --- |
| `x-ai/grok-4.1-fast` | [Grok 4.1 Fast](https://openrouter.ai/x-ai/grok-4.1-fast) | Good daily "brain" candidate for agents. Fast, practical, and a strong default when I want solid tool-oriented behavior at a reasonable price. |
| `deepseek/deepseek-v3.2` | [DeepSeek V3.2](https://openrouter.ai/deepseek/deepseek-v3.2) | Good fallback or alternate daily agent model. Usually a strong price/performance option for regular agent work. |
