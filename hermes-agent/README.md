# Hermes Agent

Hermes Agent is a self-hosted AI agent you can run on your own server. This setup installs it on an Ubuntu VPS with a dedicated `hermes` user, separate SSH access, optional rootless Docker isolation, optional Telegram access, and an optional dashboard tunnel.

## Setup Assumptions

| Item | Value |
| --- | --- |
| OS | Ubuntu |
| Run from | Local machine and VPS |
| Prerequisites | Completed [`VPS Security`](../vps-security/README.md) setup |
| Main user | A non-root admin user with `sudo` |
| Hermes user | Dedicated `hermes` user without `sudo` by default |
| Recommended backend | Rootless Docker for Hermes command execution |

## What This Setup Does

This guide assumes you already completed the base server setup in [VPS Security](../vps-security).

- **Hermes runs as its own user:** keep the agent separate from your main admin account
- **A dedicated SSH key is used:** local access for Hermes does not reuse your other VPS keys
- **A local SSH alias keeps login simple:** `ssh hermes` connects with the right user and key
- **Rootless Docker can isolate command execution:** Hermes does not need access to the system Docker daemon
- **Optional gateways stay private by default:** Telegram is restricted by allowed users and the dashboard is reached through SSH tunneling

**Result:** Hermes is installed on the VPS with a smaller scope, simpler SSH access, and a clean path to follow the official documentation.

## Before You Start

You should already have:

- a hardened Ubuntu VPS
- a working non-root admin user with `sudo`
- SSH access working from your local machine
- the base firewall and SSH hardening from [VPS Security](../vps-security/README.md)

Use your existing admin user for server-side setup steps unless a linked guide says otherwise.

## Recommended Setup Path

1. Complete [VPS Security](../vps-security/README.md).
2. Create the dedicated Hermes user and SSH alias in [SSH User Setup](./ssh-user-setup.md).
3. Install the Hermes CLI and extra system packages in [Install Hermes Agent](./install.md).
4. Configure the rootless [Docker Backend](./docker-backend.md) if Hermes should execute commands in Docker.
5. Run `hermes setup` from [Install Hermes Agent](./install.md).
6. Configure a provider and model in [Model Providers](./model-providers.md).
7. Run the [Sanity Check](./sanity-check.md).

## Recommended Commands At A Glance

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

## Optional Features

Use these after the main install path is working.

| Feature | Guide | Notes |
| --- | --- | --- |
| Rootless Docker backend | [Docker Backend](./docker-backend.md) | Recommended when the VPS also runs Dokploy or system Docker workloads |
| OpenRouter, xAI OAuth, fallback models | [Model Providers](./model-providers.md) | Includes the xAI OAuth callback tunnel and OpenRouter routing settings |
| Telegram bot access | [Telegram Gateway](./telegram-gateway.md) | Includes service install, linger, status, and logs |
| Web dashboard | [Hermes Dashboard](./dashboard.md) | Uses a localhost SSH tunnel instead of a public port |
| Shared persistent workspace | [Personal Workspace Setup](./personal-workspace-setup.md) | Defines the `/workspace` and `~/hermes-workspace` folder convention |
| Personality workflow | [SOUL Workflow](./soul-workflow.md) | Uses the shared workspace to generate and install `SOUL.md` |

## Security Summary

The important defaults for this VPS setup are:

- keep Hermes running as the dedicated `hermes` user with no `sudo` by default
- avoid adding `hermes` to the system `docker` group
- use rootless Docker if Hermes needs Docker-backed command execution
- keep API keys in `~/.hermes/.env` and restrict that file to `600`
- restrict Telegram access to approved user IDs
- keep the dashboard on localhost and access it through an SSH tunnel

For details, see [Security Notes](./security-notes.md).

## Troubleshooting

Common setup failures are collected in [Troubleshooting](./troubleshooting.md), including:

- `hermes` command not found
- missing Hermes symlink after install
- Playwright trying to use root or sudo
- `nvm` not visible under `sudo`
- Docker still using the old system socket
- gateway logs and linger checks
- shared workspace ownership issues

## Final Verification

Run the [Sanity Check](./sanity-check.md) after setup to verify:

- the local `ssh hermes` alias works
- Hermes is isolated under its own Ubuntu user
- the Hermes CLI is installed and available
- Hermes uses its own rootless Docker daemon if selected
- a model provider is configured
- secrets have restrictive permissions
- optional gateway service is running if enabled

## References

- [SSH User Setup](./ssh-user-setup.md)
- [Install Hermes Agent](./install.md)
- [Docker Backend](./docker-backend.md)
- [Model Providers](./model-providers.md)
- [Telegram Gateway](./telegram-gateway.md)
- [Hermes Dashboard](./dashboard.md)
- [Troubleshooting](./troubleshooting.md)
- [Security Notes](./security-notes.md)
- [Personal Workspace Setup](./personal-workspace-setup.md)
- [SOUL Workflow](./soul-workflow.md)
- [SOUL Template](./SOUL-template.md)
- [Sanity Check](./sanity-check.md)

## Final Step

Start an interactive session when setup is complete.

```sh
hermes
```
