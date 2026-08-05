# Model Providers

Configure a provider, authenticate xAI OAuth if needed, select a model, and optionally configure OpenRouter routing and fallback models.

## Configure A Model Provider

**Run as:** `hermes` on the VPS

Hermes needs a provider before it can chat normally.

If you want to use your X subscription with Hermes, use the xAI OAuth flow from the `hermes` user on the VPS.

## xAI OAuth With X Premium

Because Hermes is running on the VPS but the login happens in a browser on your laptop, use an SSH tunnel for the OAuth callback.

On your local machine, open a new terminal and keep this tunnel running:

```sh
ssh -N -L 56121:127.0.0.1:56121 hermes
```

In another terminal, log in to the VPS as `hermes` and start the xAI OAuth flow:

```sh
ssh hermes
hermes auth add xai-oauth --no-browser
```

Hermes will print a `Waiting for callback on http://127.0.0.1:56121/callback` line and an authorization URL.

Copy that full URL into the browser on your laptop, sign in with the X account that has your Premium subscription, and approve the request.

When the login succeeds, Hermes saves the token under the `hermes` user's home directory:

```text
~/.hermes/auth.json
```

After that, you can close the tunnel and choose the xAI provider normally.

Notes:

- keep the OAuth login under the `hermes` user so the saved token is available to that Hermes install
- this does not require opening any public ports
- the token refresh is handled by Hermes after the initial login

If you added API keys to `~/.hermes/.env`, restrict the file so only the `hermes` user can read and edit it.

```sh
chmod 600 ~/.hermes/.env
```

Why this matters:

- `600` means only the file owner can read and write the file
- your API keys stay private to the `hermes` account instead of being readable by other users on the VPS
- this matters even more if you expose Hermes through Telegram

## Select a Model

After you completed providers login or API key setup, you can run the model selector.

```sh
hermes model
```

## Optional: OpenRouter Routing And Fallback Models

**Run as:** `hermes` on the VPS

If you use OpenRouter, you can configure Hermes to use it as the main provider and optionally add provider routing rules and a fallback chain.

This is useful if you want a broader model catalog and a cleaner way to keep a primary model plus a backup.

For OpenRouter-specific notes, recommended models, and the shortlist I am actively using, see [`../openrouter`](../openrouter).

In Hermes, `provider_routing` is OpenRouter-specific.

If you are looking for Zero Data Retention style behavior, the relevant documented Hermes setting here is `provider_routing.data_collection deny`.

```sh
hermes config set model.provider openrouter
hermes config set model.default deepseek/deepseek-v4-pro

hermes config set provider_routing.require_parameters true
hermes config set provider_routing.data_collection deny

# Optional: explicit cheapest routing
# OpenRouter already defaults to sorting by price
# hermes config set provider_routing.sort price

# Use Hermes' current fallback manager, then add:
# provider: openrouter
# model: deepseek/deepseek-v4-flash-0731
hermes fallback
```

What this does:

- `provider_routing.require_parameters true` avoids OpenRouter providers that do not support all request parameters Hermes wants to send
- `provider_routing.data_collection deny` is the documented Hermes/OpenRouter setting closest to Zero Data Retention style routing and prefers providers that do not allow training or retention on your data
- `fallback_providers` gives Hermes one or more backup provider/model pairs if the primary provider or model fails during a session
- `hermes fallback` manages the current fallback chain; older `fallback_model.*` settings are legacy compatibility keys

Relevant Hermes docs:

- [Hermes AI Providers](https://hermes-agent.nousresearch.com/docs/integrations/providers)
- [Hermes Provider Routing](https://hermes-agent.nousresearch.com/docs/user-guide/features/provider-routing)
- [Hermes Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration)

### Quick Verification

After setting the OpenRouter model, routing, and fallback values, run:

```sh
hermes config
hermes config check
hermes fallback list
```

Notes:

- `hermes config` shows a high-level summary of your current Hermes configuration
- `hermes config check` helps detect missing or stale configuration after changes
- `hermes fallback list` confirms the active fallback chain and its order
- some advanced settings may not appear in the summary output, so if you need to confirm exact values like `provider_routing.*` or `fallback_providers`, inspect the raw file path shown by `hermes config path`
