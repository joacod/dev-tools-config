# Hermes Agent

Install Hermes Agent on an already-configured Ubuntu VPS using a dedicated `hermes` user and a dedicated SSH key.

| Item | Value |
| --- | --- |
| OS | Ubuntu |
| Run from | Local machine and VPS |
| Prerequisites | Completed [`VPS Security`](../vps-security/README.md) setup |
| Outcome | Hermes installed under its own user with optional Docker and Telegram setup |

## What This Setup Does

This guide assumes you already completed the base server setup in [VPS Security](../vps-security).

- **Hermes runs as its own user:** keep the agent separate from your main admin account
- **A dedicated SSH key is used:** local access for Hermes does not reuse your other VPS keys
- **A local SSH alias keeps login simple:** `ssh hermes` connects with the right user and key
- **The official Hermes installer is used:** this guide points to upstream commands instead of replacing the docs

**Result:** Hermes is installed on the VPS with a smaller scope, simpler SSH access, and a cleaner path to follow the official documentation.

## Before You Start

This guide assumes all steps in [VPS Security](../vps-security/README.md) are already done.

You should already have:

- a hardened Ubuntu VPS
- a working non-root admin user with `sudo`
- SSH access working from your local machine

Use your existing admin user for the server-side setup steps below unless a section says otherwise.

## Add Hermes User

**Run as:** your existing admin user on the VPS

Create a dedicated Ubuntu user for Hermes without setting a local password or filling in profile fields.

```sh
sudo adduser --disabled-password --gecos "" hermes
id hermes
```

Why this user exists:

- Hermes should not run as `root`
- keeping Hermes on its own account limits what it can touch by default
- your own admin account stays separate from the agent account
- avoiding `sudo` for Hermes reduces what the agent can modify on the system

## Generate SSH Key For Hermes

**Run as:** your user on your `local machine`

Generate a dedicated SSH key for the `hermes` user on this VPS.

```sh
ssh-keygen -t ed25519 -C "hermes_vps"
```

When prompted for the file path, use `/Users/[username]/.ssh/hermes_vps`.

## Install The Public Key For Hermes

**Run as:** your existing admin user on the VPS

Because password login is already disabled from the base VPS setup, `ssh-copy-id` will usually fail for a brand new `hermes` user.

Instead, install the public key from the server side while logged in with your existing admin user.

First, print the public key on your local machine.

```sh
cat ~/.ssh/hermes_vps.pub
```

Copy the full output, then on the VPS create the SSH directory and paste the key into `authorized_keys`.

```sh
sudo mkdir -p /home/hermes/.ssh
sudo nano /home/hermes/.ssh/authorized_keys
```

Paste the public key on its own line, then save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

Set the correct ownership and permissions.

```sh
sudo chown -R hermes:hermes /home/hermes/.ssh
sudo chmod 700 /home/hermes/.ssh
sudo chmod 600 /home/hermes/.ssh/authorized_keys
```

What these commands do:

- `sudo chown -R hermes:hermes /home/hermes/.ssh` makes sure the `.ssh` folder and everything inside it belongs to the `hermes` user
- `sudo chmod 700 /home/hermes/.ssh` makes the `.ssh` folder private so only `hermes` can access it
- `sudo chmod 600 /home/hermes/.ssh/authorized_keys` makes the `authorized_keys` file private so only `hermes` can read or edit it

This matters because SSH is strict about file ownership and permissions. If these are too open, SSH may ignore the key and refuse login.

## Add Local SSH Config

**Run as:** your user on your `local machine`

Add a host alias so you can connect with `ssh hermes`.

**Important**: If `~/.ssh/config` already exists and has other hosts in it, do not replace the file contents. Add this as a new block alongside your existing SSH config.

```sh
nano ~/.ssh/config
```

Add the following config.

```sshconfig
Host hermes
  HostName YOUR_VPS_IP
  User hermes
  IdentityFile ~/.ssh/hermes_vps
  IdentitiesOnly yes
```

Save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

If the VPS later uses [SSH Over Tailscale For VPS](../tailscale/ssh-over-tailscale-for-vps.md), replace `HostName YOUR_VPS_IP` with the VPS Tailscale IP or MagicDNS hostname. The `User` and `IdentityFile` lines stay the same.

## Login As Hermes

**Run as:** your user on your `local machine`

Verify the new key and host alias work.

```sh
ssh hermes
```

## Install Hermes Agent

**Run as:** `hermes` on the VPS

Download and run the official install script.

```sh
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

During the installer:

- if prompted to install `ripgrep` and `ffmpeg`, answer `n`
- if prompted to install build tools, answer `n`
- if Playwright tries to switch to root and asks for a `sudo` password, stop there with `CTRL + C`

Why this guide installs those packages after the main install:

- `ripgrep`, `ffmpeg`, build tools, and Playwright system dependencies may require `sudo`
- this guide keeps `hermes` as a non-sudo user
- installing them in separate steps keeps the permissions clear and avoids mixing admin tasks into the Hermes user session

Reload your shell so the new `hermes` command is available in the current session.

```sh
source ~/.bashrc
```

Check whether the command is available.

```sh
hermes version
```

If `hermes version` works, continue to the next section.

Official install docs:

- [Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation)
- [Quickstart](https://hermes-agent.nousresearch.com/docs/getting-started/quickstart)

## Fix PATH If Hermes Is Not Found

**Run as:** `hermes` on the VPS

If `hermes version` returns `command not found`, add `~/.local/bin` to your `PATH` and reload your shell.

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then rerun:

```sh
hermes version
```

If Hermes is still not found, the installer may have completed the core install but skipped creating the final command symlink.

First verify the Hermes binary exists inside the installation directory.

```sh
ls -l ~/.hermes/hermes-agent/venv/bin/hermes
```

If that file exists, create the missing symlink manually.

```sh
ln -sf ~/.hermes/hermes-agent/venv/bin/hermes ~/.local/bin/hermes
```

Then rerun `hermes version`.

## Install Extra System Packages

**Run as:** your admin user on the VPS for `apt` and Playwright system dependencies, then `hermes` on the VPS for Playwright browsers

Install the extra system packages Hermes can use separately from your admin account.

These packages are installed system-wide, so once your admin user installs them, the `hermes` user can use them too.

```sh
sudo apt update
```

Then install the packages Hermes can use.

### ripgrep & ffmpeg

```sh
sudo apt install ripgrep ffmpeg -y
```

### Playwright

Playwright also needs Linux browser dependencies that require `sudo`.

If your admin user installed Node.js with `nvm`, `sudo` will usually not see `node` or `npx` automatically. Run the next two commands exactly as written. The first command automatically captures the current Node.js binary directory for your admin user, and the second passes that directory into `sudo`.

```sh
NODE_BIN_DIR="$(dirname "$(command -v node)")"
```

```sh
sudo env "PATH=$NODE_BIN_DIR:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" bash -lc 'cd /home/hermes/.hermes/hermes-agent && npx playwright install-deps'
```

Then switch back to `hermes` and install the Playwright browser binaries under the `hermes` user.

Before running the command below, make sure `hermes` also has its own `nvm` and Node.js installation. Your admin user's `nvm` setup is separate and is not shared with `hermes`.

```sh
npx playwright install
```

When that is done, continue to the next section.

## Install Docker Backend

**Run as:** your admin user on the VPS unless a step says otherwise

If you want Hermes to execute commands inside Docker instead of directly on the host, use a separate rootless Docker daemon for the `hermes` user.

This is the recommended path when Hermes shares a machine with something like Dokploy.

Why this guide uses rootless Docker for Hermes:

- Dokploy uses the system Docker daemon
- adding `hermes` to the system `docker` group would give `hermes` root-equivalent control of that daemon
- a separate rootless Docker daemon keeps Hermes from controlling Dokploy containers through `/var/run/docker.sock`

### 1. Install rootless Docker prerequisites

If Docker is already installed for Dokploy, you do not need to reinstall the base engine. You only need the rootless extras package and the user namespace helpers.

```sh
sudo apt update
sudo apt install docker-ce-rootless-extras uidmap -y
```

### 2. Remove `hermes` from the system `docker` group

```sh
sudo gpasswd -d hermes docker
id hermes
```

Expected result:

- `id hermes` no longer lists the `docker` group

### 3. Set up rootless Docker as `hermes`

**Run as:** `hermes` on the VPS

```sh
dockerd-rootless-setuptool.sh install
```

Then add the Docker socket path for the current `hermes` user and reload the shell.

```sh
echo 'export PATH=/usr/bin:$PATH' >> ~/.bashrc
echo "export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock" >> ~/.bashrc
source ~/.bashrc
```

If the rootless Docker service is not already running after setup, start it once in the current session.

```sh
systemctl --user start docker
```

This guide uses `DOCKER_HOST` as the one explicit way to tell Hermes which Docker daemon to use.

That matters because Hermes only knows it should use the `docker` backend. The actual Docker socket still comes from the `hermes` user environment.

If `docker context ls` later warns that `DOCKER_HOST` overrides the active context, that is expected and safe to ignore in this setup.

### 4. Verify rootless Docker as `hermes`

**Run as:** `hermes` on the VPS

```sh
docker context ls
docker info
docker run hello-world
```

Expected result:

- `docker info` shows `rootless` under `Security Options`
- `docker run hello-world` completes successfully
- the Docker client is no longer using `/var/run/docker.sock`
- `docker ps` does not show Dokploy containers from the system Docker daemon

### 5. If Hermes still uses the old system Docker socket

**Run as:** `hermes` on the VPS

```sh
echo "$DOCKER_HOST"
docker context ls
```

If you still see the system socket, log out completely and reconnect as `hermes`, then rerun the verification commands.

### 6. Make the rootless socket available to Hermes services too

**Run as:** `hermes` on the VPS

If you run Hermes as a long-lived user service, make the same Docker socket available outside interactive shells too.

```sh
mkdir -p ~/.config/environment.d
nano ~/.config/environment.d/docker.conf
```

Add:

```ini
DOCKER_HOST=unix:///run/user/1002/docker.sock
PATH=/usr/bin
```

Save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

If your `hermes` user has a different UID on another machine, replace `1002` with the value from `id -u`.

Reload the user environment:

```sh
systemctl --user daemon-reload
systemctl --user import-environment DOCKER_HOST PATH
systemctl --user show-environment | grep DOCKER_HOST
```

Expected result:

- `systemctl --user show-environment | grep DOCKER_HOST` shows the rootless Docker socket path

Docker reference:

- [Docker Rootless Mode](https://docs.docker.com/engine/security/rootless/)

## Run Hermes Setup

**Run as:** `hermes` on the VPS

Once the CLI is working, run the setup wizard.

```sh
hermes setup
```

For this guide's VPS setup:

- choose `Docker` as the terminal backend
- choose a persistent filesystem
- if you want Telegram access, you can configure it during `hermes setup` or later with `hermes gateway setup`

### Telegram Settings

**Important**, during Telegram setup, make sure you provide:

- your Telegram bot token from BotFather
- your own Telegram user ID in the allowed users list

## Configure Persistent Docker Workspace

**Run as:** `hermes` on the VPS

After `hermes setup`, configure Hermes to keep its Docker sandbox filesystem between sessions and to use a predictable host-mounted workspace at `/workspace`.

This keeps Docker as the isolation boundary while giving Hermes a simple persistent folder for inputs and outputs.

```sh
hermes config set terminal.container_persistent true
mkdir -p ~/hermes-workspace
hermes config set terminal.docker_volumes '["/home/hermes/hermes-workspace:/workspace"]'
```

What this does:

- `terminal.container_persistent true` tells Hermes to preserve the Docker sandbox filesystem across sessions
- `terminal.docker_volumes` bind-mounts `~/hermes-workspace` from the VPS into the container as `/workspace`
- files Hermes writes to `/workspace` inside the container will appear in `/home/hermes/hermes-workspace` on the VPS

## Configure A Model Provider

**Run as:** `hermes` on the VPS

Hermes needs a provider before it can chat normally.

Run the model selector and complete login or API key setup.

```sh
hermes model
```

If you added API keys to `~/.hermes/.env`, restrict the file so only the `hermes` user can read and edit it.

```sh
chmod 600 ~/.hermes/.env
```

Why this matters:

- `600` means only the file owner can read and write the file
- your API keys stay private to the `hermes` account instead of being readable by other users on the VPS
- this matters even more if you expose Hermes through Telegram

## Optional: OpenRouter Routing And Fallback Model

**Run as:** `hermes` on the VPS

If you use OpenRouter, you can configure Hermes to use it as the main provider and optionally add provider routing rules and a fallback model.

This is useful if you want a broader model catalog and a cleaner way to keep a primary model plus a backup.

For OpenRouter-specific notes, recommended models, and the shortlist I am actively using, see [`../openrouter`](../openrouter).

In Hermes, `provider_routing` is OpenRouter-specific.

If you are looking for Zero Data Retention style behavior, the relevant documented Hermes setting here is `provider_routing.data_collection deny`.

```sh
hermes config set model.provider openrouter
hermes config set model.default x-ai/grok-4.1-fast

hermes config set provider_routing.require_parameters true
hermes config set provider_routing.data_collection deny

# Optional: explicit cheapest routing
# OpenRouter already defaults to sorting by price
# hermes config set provider_routing.sort price

hermes config set fallback_model.provider openrouter
hermes config set fallback_model.model deepseek/deepseek-v3.2
```

What this does:

- `provider_routing.require_parameters true` avoids OpenRouter providers that do not support all request parameters Hermes wants to send
- `provider_routing.data_collection deny` is the documented Hermes/OpenRouter setting closest to Zero Data Retention style routing and prefers providers that do not allow training or retention on your data
- `fallback_model.*` gives Hermes a backup model if the primary provider or model fails during a session

### Quick Verification

After setting the OpenRouter model, routing, and fallback values, run:

```sh
hermes config
hermes config check
```

Notes:

- `hermes config` shows a high-level summary of your current Hermes configuration
- `hermes config check` helps detect missing or stale configuration after changes
- some advanced settings may not appear in the summary output, so if you need to confirm exact values like `provider_routing.*` or `fallback_model.*`, inspect the raw file path shown by `hermes config path`

## Optional: Set Up Telegram Gateway

**Run as:** `hermes` on the VPS for gateway setup, and your admin user on the VPS for the linger step

If you skipped Telegram during `hermes setup`, configure it now.

`hermes gateway setup` is the interactive configuration step. It does not keep the bot running in the background by itself.

```sh
hermes gateway setup
```

Install and start the gateway service while logged in as `hermes`.

```sh
hermes gateway install
hermes gateway start
hermes gateway status
```

Then, from your admin user's shell on the VPS, enable systemd linger for the `hermes` user.

This is what keeps the `hermes` user service running after logout and allows it to start again after a VPS reboot.

```sh
sudo loginctl enable-linger hermes
loginctl show-user hermes
```

Expected result:

- `hermes gateway status` shows the service as running
- `loginctl show-user hermes` includes `Linger=yes`
- the gateway stays available after logout and starts again automatically after a VPS reboot

### Later Maintenance

You do not need these commands for the first setup.

Use them later if you change gateway settings or need to troubleshoot the running service.

```sh
hermes gateway restart
```

If you need to watch the gateway logs while logged in as `hermes`:

```sh
journalctl --user -u hermes-gateway -f
```

Gateway reference:

- [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/)

## Optional: Hermes Dashboard

**Run as:** `hermes` on the VPS

Once the dashboard dependencies are installed, you can start the Hermes dashboard with:

```sh
hermes dashboard
```

By default, Hermes serves the dashboard at:

```text
http://127.0.0.1:9119
```

If you are running Hermes on a VPS, you can expose `localhost:9119` through Tailscale to access the dashboard from your laptop while keeping it available only inside your tailnet.

For the Tailscale setup, see [Tailscale](../tailscale/README.md).

## Security Notes

These production basics fit this VPS setup well:

- keep Hermes running as the dedicated `hermes` user with no `sudo` by default
- keep API keys in `~/.hermes/.env` and make sure that file is only readable by `hermes`
- keep Telegram restricted to your bot token and your approved Telegram user IDs, instead of leaving the bot open to anyone who can find it
- keep the terminal backend set to Docker if you want stronger isolation

Security reference:

- [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security)

## Shared Workspace Convention

For a simple way to organize the persistent shared Docker workspace under `~/hermes-workspace` and `/workspace`, see [Personal Workspace Setup](./personal-workspace-setup.md).

## Final Step

Run the [sanity check](./sanity-check.md) to verify the SSH alias, user separation, Hermes install, and any optional services are working correctly.

### That's it

Start an interactive session when setup is complete.

```sh
hermes
```
