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

These are not meant to be a permanent ranking.

Model quality, pricing, tool use behavior, and provider availability can change fast, so this page should stay practical and easy to update.

### General Models

| Model | Link | Notes |
| --- | --- | --- |
| `z-ai/glm-5.1` | [GLM 5.1](https://openrouter.ai/z-ai/glm-5.1) | Strong general model worth checking regularly. Good candidate when I want a capable non-default option in rotation. |
| `minimax/minimax-m2.7` | [MiniMax M2.7](https://openrouter.ai/minimax/minimax-m2.7) | Good general-purpose model to keep an eye on. Useful when testing newer non-OpenAI/Anthropic options. |
| `minimax/minimax-m2.5` | [MiniMax M2.5](https://openrouter.ai/minimax/minimax-m2.5) | Another solid general model in the same family. Good to compare against M2.7 on quality and cost. |
| `moonshotai/kimi-k2.5` | [Kimi K2.5](https://openrouter.ai/moonshotai/kimi-k2.5) | Good general model to keep in the shortlist. Worth testing for broad everyday use and comparison against other budget-friendly options. |

### Models For Agents

These are the models I would look at first for daily agent use, where tool use, reliability, and price matter more than pure benchmark appeal.

| Model | Link | Notes |
| --- | --- | --- |
| `x-ai/grok-4.1-fast` | [Grok 4.1 Fast](https://openrouter.ai/x-ai/grok-4.1-fast) | Good daily "brain" candidate for agents. Fast, practical, and a strong default when I want solid tool-oriented behavior at a reasonable price. |
| `deepseek/deepseek-v3.2` | [DeepSeek V3.2](https://openrouter.ai/deepseek/deepseek-v3.2) | Good fallback or alternate daily agent model. Usually a strong price/performance option for regular agent work. |

## Current Hermes Direction

Current Hermes-oriented setup I want to keep documented:

- primary daily brain: `x-ai/grok-4.1-fast`
- fallback model: `deepseek/deepseek-v3.2`
- complex tasks: `z-ai/glm-5.1`

## Using OpenRouter With Hermes

Hermes can use OpenRouter as its main provider and can also use OpenRouter-specific provider routing and fallback configuration.

Hermes-specific setup notes live in [`../hermes-agent`](../hermes-agent).

Important Hermes note:

- `provider_routing` is specific to OpenRouter in Hermes
- `provider_routing.data_collection deny` is the documented Hermes/OpenRouter setting closest to Zero Data Retention style routing

## References

- [OpenRouter](https://openrouter.ai/)
- [Hermes AI Providers](https://hermes-agent.nousresearch.com/docs/integrations/providers)
- [Hermes Provider Routing](https://hermes-agent.nousresearch.com/docs/user-guide/features/provider-routing)
- [Hermes Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration)
