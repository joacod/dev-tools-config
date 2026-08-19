# Hermes Agent

Hermes Agent is a self-hosted AI agent you can run on your own server. This setup installs it on an Ubuntu VPS with a dedicated `hermes` user, separate SSH access, optional rootless Docker isolation, optional Telegram access, and an optional dashboard tunnel.

## Setup assumptions

| Item | Value |
| --- | --- |
| OS | Ubuntu |
| Run from | Local machine and VPS |
| Prerequisites | Completed [`VPS security`](../vps-security/README.md) setup |
| Main user | A non-root admin user with `sudo` |
| Hermes user | Dedicated `hermes` user without `sudo` by default |
| Recommended backend | Rootless Docker for Hermes command execution |

## What this setup does

This guide assumes you already completed the base server setup in [VPS security](../vps-security).

- **Hermes runs as its own user:** keep the agent separate from your main admin account
- **A dedicated SSH key is used:** local access for Hermes does not reuse your other VPS keys
- **A local SSH alias keeps login simple:** `ssh hermes` connects with the right user and key
- **Rootless Docker can isolate command execution:** Hermes does not need access to the system Docker daemon
- **Optional gateways stay private by default:** Telegram is restricted by allowed users and the dashboard is reached through SSH tunneling

**Result:** Hermes is installed on the VPS with a smaller scope, simpler SSH access, and a clean path to follow the official documentation.

## Before you start

You should already have:

- a hardened Ubuntu VPS
- a working non-root admin user with `sudo`
- SSH access working from your local machine
- the base firewall and SSH hardening from [VPS security](../vps-security/README.md)

Use your existing admin user for server-side setup steps unless a linked guide says otherwise.

## Recommended setup path

1. Complete [VPS security](../vps-security/README.md).
2. Create the dedicated Hermes user and SSH alias in [SSH user setup](./ssh-user-setup.md).
3. Install the Hermes CLI and extra system packages in [Install Hermes Agent](./install.md).
4. Configure the rootless [Docker backend](./docker-backend.md) if Hermes should execute commands in Docker.
5. Run `hermes setup` from [Install Hermes Agent](./install.md).
6. Configure a provider and model in [Model providers](./model-providers.md).
7. Run the [sanity check](./sanity-check.md).

## Recommended commands at a glance

After the dedicated SSH user is ready, most Hermes work starts from your local machine with:

```sh
ssh hermes
```

Then, from the VPS as `hermes`:

```sh
hermes setup
hermes model
hermes
```

The detailed guides include the setup commands, run-as context, expected results, and common edge cases.

## Optional features

Use these after the main install path is working.

| Feature | Guide | Notes |
| --- | --- | --- |
| Rootless Docker backend | [Docker backend](./docker-backend.md) | Recommended when the VPS also runs Dokploy or system Docker workloads |
| OpenRouter, xAI OAuth, fallback models | [Model providers](./model-providers.md) | Includes the xAI OAuth callback tunnel and OpenRouter routing settings |
| Telegram bot access | [Telegram gateway](./telegram-gateway.md) | Includes service install, linger, status, and logs |
| Web dashboard | [Hermes dashboard](./dashboard.md) | Uses a localhost SSH tunnel instead of a public port |
| Shared persistent workspace | [Personal workspace setup](./personal-workspace-setup.md) | Defines the `/workspace` and `~/hermes-workspace` folder convention |
| Personality workflow | [SOUL workflow](./soul-workflow.md) | Uses the shared workspace to generate and install `SOUL.md` |

## Security summary

The important defaults for this VPS setup are:

- keep Hermes running as the dedicated `hermes` user with no `sudo` by default
- avoid adding `hermes` to the system `docker` group
- use rootless Docker if Hermes needs Docker-backed command execution
- keep API keys in `~/.hermes/.env` and restrict that file to `600`
- restrict Telegram access to approved user IDs
- keep the dashboard on localhost and access it through an SSH tunnel

For details, see [Security notes](./security-notes.md).

## Troubleshooting

Common setup failures are collected in [Troubleshooting](./troubleshooting.md), including:

- `hermes` command not found
- missing Hermes symlink after install
- Playwright trying to use root or sudo
- `nvm` not visible under `sudo`
- Docker still using the old system socket
- gateway logs and linger checks
- shared workspace ownership issues

## Final verification

Run the [sanity check](./sanity-check.md) after setup to verify:

- the local `ssh hermes` alias works
- Hermes is isolated under its own Ubuntu user
- the Hermes CLI is installed and available
- Hermes uses its own rootless Docker daemon if selected
- a model provider is configured
- secrets have restrictive permissions
- optional gateway service is running if enabled

## References

- [SSH user setup](./ssh-user-setup.md)
- [Install Hermes Agent](./install.md)
- [Docker backend](./docker-backend.md)
- [Model providers](./model-providers.md)
- [Telegram gateway](./telegram-gateway.md)
- [Hermes dashboard](./dashboard.md)
- [Troubleshooting](./troubleshooting.md)
- [Security notes](./security-notes.md)
- [Personal workspace setup](./personal-workspace-setup.md)
- [SOUL workflow](./soul-workflow.md)
- [SOUL template](./SOUL-template.md)
- [sanity check](./sanity-check.md)

## Final step

Start an interactive session when setup is complete.

```sh
hermes
```
