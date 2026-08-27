# Model providers

Hermes needs at least one inference provider. This guide keeps the reusable provider, OpenRouter, routing, and fallback notes separate from the VPS-specific setup.

For the full, current provider list and authentication flows, use the official [LLM and Model Providers](https://hermes-agent.nousresearch.com/docs/integrations/providers) guide.

## Choose a provider

Use the interactive model selector to configure a provider or change the active model:

```sh
hermes model
```

`hermes model` configures providers for Hermes. Inside an active session, `/model` switches between providers and models that are already configured.

If you use Nous Portal, the fastest fresh-install path is:

```sh
hermes setup --portal
```

This logs in, selects Nous as the provider, and enables the Tool Gateway. Use `hermes portal info` to inspect the Portal login and routing later.

## OpenRouter

[OpenRouter notes and model shortlist](../../../ai-apis-services/openrouter/README.md) live separately from this Hermes configuration guide.

Configure OpenRouter and its API key interactively with `hermes model`:

```sh
hermes model
```

The model IDs and availability change over time. Treat the [OpenRouter catalog](https://openrouter.ai/) and the repository shortlist as the source of truth for current model choices.

## OpenRouter provider routing

`provider_routing` applies to OpenRouter and Nous Portal. It does not affect direct provider connections.

For example, to require parameter support and prefer providers that deny data collection:

```yaml
provider_routing:
  require_parameters: true
  data_collection: deny
```

The equivalent commands are:

```sh
hermes config set provider_routing.require_parameters true
hermes config set provider_routing.data_collection deny
```

See the official [provider routing reference](https://hermes-agent.nousresearch.com/docs/user-guide/features/provider-routing) for `sort`, `only`, `ignore`, and `order`.

## Fallback providers

Use a top-level `fallback_providers` list for a chain of backup provider/model pairs:

```yaml
fallback_providers:
  - provider: openrouter
    model: deepseek/deepseek-v4-flash-0731
```

The current Hermes fallback manager is also available through:

```sh
hermes fallback
```

The older single `fallback_model` mapping is retained for compatibility, but new configuration should use `fallback_providers`. Verify the resulting configuration with:

```sh
hermes config
hermes config get fallback_providers
hermes config check
```

See the [official provider and fallback documentation](https://hermes-agent.nousresearch.com/docs/integrations/providers) for the current schema and supported providers.

## OAuth from a remote shell

Some OAuth flows can be completed from a remote or headless session. Current xAI Grok OAuth uses a device code rather than a loopback callback:

```sh
hermes auth add xai-oauth --no-browser
```

Open the printed verification URL in a browser on the machine you are using, then let Hermes finish polling. No SSH callback tunnel is required for xAI's current flow. Credentials are stored for the Hermes instance that ran the command, normally under `~/.hermes/auth.json`.

For providers or MCP servers that still use a loopback redirect, follow the upstream [OAuth over SSH / Remote Hosts](https://hermes-agent.nousresearch.com/docs/guides/oauth-over-ssh) guide rather than assuming a fixed callback port.

On the hardened VPS, run remote authentication as the `hermes` user so the credentials belong to that Hermes instance. See [security notes](../security/security-notes.md) for the related permission and access boundaries.

## Credentials and configuration

Hermes stores normal settings in `~/.hermes/config.yaml`, API keys and other secrets in `~/.hermes/.env`, and OAuth credentials in `~/.hermes/auth.json`. Prefer the interactive `hermes model` flow or a secure editor for secrets; putting an API key directly in a `hermes config set` command can leave it in shell history.

For current configuration commands and paths, see the official [configuration reference](https://hermes-agent.nousresearch.com/docs/user-guide/configuration).
