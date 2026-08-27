# Security notes

These notes describe the boundaries of the optional hardened Hermes VPS profile. They are not requirements for a normal Hermes installation.

## Dedicated Hermes user

Keep Hermes running as the dedicated `hermes` user with no `sudo` by default.

This keeps the agent separate from the main admin account and limits what it can modify on the host without an explicit admin step.

## No sudo for Hermes

Do not add `hermes` to broad admin groups unless there is a specific reason. System package installation and host ownership changes should run from the admin account; Hermes itself remains non-sudo.

## Rootless Docker vs system Docker

Use rootless Docker for Hermes when the VPS also runs Dokploy or other system Docker workloads.

Adding `hermes` to the system `docker` group would give it root-equivalent control over the system Docker daemon and anything attached to `/var/run/docker.sock`.

A separate rootless Docker daemon keeps Hermes from controlling Dokploy containers through the system socket. See [Docker backend](./docker-backend.md) for the setup and verification commands.

## API key and OAuth permissions

Keep API keys in `~/.hermes/.env` and make sure that file is only readable by `hermes`:

```sh
chmod 600 ~/.hermes/.env
```

Hermes OAuth credentials are stored in `~/.hermes/auth.json` for the Hermes user that authenticates. Do not copy them to another account or expose them through a mounted workspace.

Why this matters:

- `600` means only the file owner can read and write the API key file
- credentials stay private to the `hermes` account instead of being readable by other VPS users
- this matters even more if you expose Hermes through Telegram or a remote dashboard

## OAuth from this VPS

Current xAI Grok OAuth uses a device-code flow, not a fixed loopback callback. Run it as the account that owns this Hermes installation:

> **Run as:** `hermes` on the VPS

```sh
hermes auth add xai-oauth --no-browser
```

Open the printed verification URL in a browser on your local machine and let Hermes finish polling. No `ssh -N -L 56121:...` tunnel is required for the current xAI flow.

For a provider or MCP server that still uses a loopback redirect, use the official [OAuth over SSH / Remote Hosts](https://hermes-agent.nousresearch.com/docs/guides/oauth-over-ssh) instructions and the exact port Hermes prints. The generic [model provider guide](../guides/model-providers.md) links to the same upstream reference.

## Telegram allowed users

Keep Telegram restricted to the bot token and approved Telegram user IDs. Hermes denies users who are not authorized by an allowlist or pairing configuration by default; do not enable open access for a bot with terminal access.

The [Telegram gateway guide](./telegram-gateway.md) includes the setup and service commands.

## Dashboard localhost tunnel

Keep the dashboard bound to localhost on the VPS and reach it through an SSH tunnel:

```sh
ssh -N -L 9119:127.0.0.1:9119 hermes
```

Then open:

```text
http://127.0.0.1:9119
```

This avoids exposing the dashboard on a public VPS port. See [Hermes dashboard](./dashboard.md).

Security reference:

- [Hermes security documentation](https://hermes-agent.nousresearch.com/docs/user-guide/security)
