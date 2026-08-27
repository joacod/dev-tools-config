# Security-Hardened Hermes VPS Setup

This is an optional, more restrictive Hermes deployment profile for an Ubuntu VPS. It keeps the agent's host-level access narrower than a normal local installation and preserves the existing VPS-specific setup notes.

> This configuration intentionally trades some convenience and integration capability for stronger isolation. It is not required for a normal Hermes install.

The normal/default path is the [main Hermes README](../README.md) plus the [official Hermes documentation](https://hermes-agent.nousresearch.com/docs). Use this directory when the VPS isolation tradeoffs are worth the extra setup.

## What this profile changes

The setup uses:

- a hardened Ubuntu VPS as the starting point ([VPS security](../../../server-infrastructure/vps-security/README.md))
- a dedicated `hermes` Linux user with no `sudo` by default
- dedicated SSH access and a local `ssh hermes` alias
- rootless Docker for Hermes instead of access to the system Docker daemon
- a controlled persistent workspace mounted at `/workspace`
- restrictive permissions for Hermes secrets and OAuth state
- Telegram access restricted to approved users when enabled
- a dashboard bound to localhost and reached through an SSH tunnel
- a final sanity check for the user, CLI, backend, provider, mounts, and services

## Recommended setup path

1. Complete the base [VPS security](../../../server-infrastructure/vps-security/README.md) setup.
2. Create the dedicated user and SSH alias in [SSH user setup](./ssh-user-setup.md).
3. Install the Hermes CLI in [Install Hermes Agent](./install.md).
4. Configure [rootless Docker](./docker-backend.md) if Hermes should execute commands in a separate Docker daemon.
5. Return to [Install Hermes Agent](./install.md) to run `hermes setup` and configure the persistent workspace.
6. Configure a provider and model using the reusable [model provider guide](../guides/model-providers.md). The guide also notes the current device-code flow for remote xAI OAuth.
7. Add optional [Telegram gateway](./telegram-gateway.md) or [dashboard](./dashboard.md) access.
8. Use the [SOUL workflow](./soul-workflow.md) if you want Hermes to update the mounted personality file.
9. Run the [sanity check](./sanity-check.md).

Use the run-as notes in each guide. System packages and ownership changes run as the existing admin user; Hermes installation and user services run as `hermes`.

## Optional components

| Component | Guide | Purpose |
| --- | --- | --- |
| Dedicated SSH access | [SSH user setup](./ssh-user-setup.md) | Separate key, user, and local alias |
| Rootless Docker | [Docker backend](./docker-backend.md) | Keep Hermes separate from Dokploy and other system Docker workloads |
| Persistent workspace | [Personal workspace setup](./personal-workspace-setup.md) | Organize files mounted at `/workspace` |
| Telegram gateway | [Telegram gateway](./telegram-gateway.md) | Run a restricted messaging bot as a user service |
| Private dashboard | [Hermes dashboard](./dashboard.md) | Reach the dashboard through a localhost SSH tunnel |
| Security decisions | [Security notes](./security-notes.md) | Record the permissions, gateway, OAuth, and network boundaries |

## Verification and recovery

Run the [sanity check](./sanity-check.md) after the selected components are configured. It verifies the dedicated account, CLI, provider, rootless Docker separation, secret permissions, persistent `SOUL.md` mount, and optional gateway service.

For common failures, see [Troubleshooting](./troubleshooting.md). The detailed guides remain intentionally procedural so the setup can be reproduced instead of reduced to generic security advice.
