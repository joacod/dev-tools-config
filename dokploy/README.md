# Dokploy

Dokploy is a self-hosted deployment platform for running and managing apps, databases, and services on your own server. This guide covers a minimal Dokploy install on an Ubuntu VPS and private first access over Tailscale.

| Item | Value |
| --- | --- |
| OS | Ubuntu |
| Run from | Local machine and VPS |
| Prerequisites | Completed [`VPS Security`](../vps-security/README.md) setup |
| Outcome | Dokploy installed and reachable from your local machine over Tailscale |

## What This Setup Does

This guide keeps the setup close to the official Dokploy docs and covers a minimal install flow with private access over Tailscale.

- **Uses the official installer:** the same install script from Dokploy's installation docs
- **Uses Tailscale for access:** reach the Dokploy panel from your local machine without exposing it publicly
- **Keeps Dokploy on the system Docker daemon:** this matches the default Dokploy install flow
- **Keeps the setup minimal:** install first, then use a private Tailscale URL to complete the admin setup

**Result:** Dokploy is installed on the VPS and reachable privately from your local machine through Tailscale.

## Before You Start

This guide assumes all steps in [VPS Security](../vps-security/README.md) are already done.

You should already have:

- a working Ubuntu VPS
- a non-root admin user with `sudo`
- SSH access working from your local machine
- Tailscale installed and working on the VPS and your local machine
- ports `80` and `443` available before install

This guide assumes the Dokploy panel is meant to stay private and be opened through `tailscale serve`, not directly from the public internet.

Dokploy installs Docker automatically if it is not already present.

Dokploy also initializes a single-node Docker Swarm by default as part of its standard install flow.

If you do not use Tailscale, follow the official Dokploy installation documentation instead of this guide.

Use your existing admin user for the VPS commands below unless a section says otherwise.

## Install Dokploy

**Run as:** your existing admin user on the VPS

Run the official installer.

```sh
sudo curl -sSL https://dokploy.com/install.sh | sudo sh
```

What this does:

- installs Docker if needed
- initializes the single-node Docker Swarm Dokploy uses
- creates Dokploy services and supporting containers
- exposes the panel on port `3000`

## Serve Dokploy Over Tailscale

**Run as:** your existing admin user on the VPS

Expose Dokploy only inside your tailnet so you can open it safely from your local machine.

```sh
sudo tailscale serve --bg --https=3000 localhost:3000
```

Check the current Tailscale Serve status:

```sh
tailscale serve status
```

You should see a Tailscale HTTPS URL ending in `:3000`.

This keeps Dokploy reachable from your local machine without opening port `3000` to the public internet.

If you have not set up Tailscale yet, use the steps in [Tailscale](../tailscale/README.md) first.

## Open The Web UI

**Run as:** your user on your `local machine`

Open the Tailscale Serve URL from the previous step in your browser.

It should look similar to:

```text
https://your-machine.your-tailnet.ts.net:3000
```

If the page does not load, recheck:

- the Dokploy installer finished without errors
- `tailscale serve status` shows the mapping
- your local machine is connected to the same tailnet

## Create The Admin Account

**Run as:** your user in the Dokploy web UI

Complete the initial setup page and create the first Dokploy administrator account.

This account becomes the main admin account for the Dokploy panel.

## Notes

- Dokploy uses Docker Swarm under the hood as part of the default installation flow.
- This guide assumes Tailscale is your safe way to reach the Dokploy panel during setup.
- If you later run Hermes on the same machine, keep Dokploy on the system Docker daemon and keep Hermes on a separate rootless Docker daemon for the `hermes` user.
- If you want version pinning, custom swarm network options, or manual installation details, use the official manual installation docs.
- If you later update Dokploy, the basic update command is `sudo curl -sSL https://dokploy.com/install.sh | sudo sh -s update`.

## Official References

- [Dokploy Core Docs](https://docs.dokploy.com/docs/core)
- [Dokploy Domains](https://docs.dokploy.com/docs/core/domains)
- [Dokploy Remote Server Security Recommendations](https://docs.dokploy.com/docs/core/remote-servers/security#security-recommendations)
