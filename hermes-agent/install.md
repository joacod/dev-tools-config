# Install Hermes Agent

Install the Hermes CLI under the dedicated `hermes` user, add extra system packages, run setup, and configure the persistent Docker workspace.

Complete [SSH User Setup](./ssh-user-setup.md) before this guide.

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

When that is done, continue to Hermes setup.

## Run Hermes Setup

**Run as:** `hermes` on the VPS

Once the CLI is working, run the setup wizard.

```sh
hermes setup
```

For this guide's VPS setup:

- choose `Docker` as the terminal backend if you configured [Docker Backend](./docker-backend.md)
- choose a persistent filesystem
- if you want Telegram access, you can configure it during `hermes setup` or later with `hermes gateway setup`

### Telegram Settings

During Telegram setup, make sure you provide:

- your Telegram bot token from BotFather
- your own Telegram user ID in the allowed users list

## Configure Persistent Docker Workspace

After `hermes setup`, configure Hermes to keep its Docker sandbox filesystem between sessions and to use a predictable host-mounted workspace at `/workspace`.

This keeps Docker as the isolation boundary while giving Hermes a simple persistent folder for inputs and outputs.

**Run as:** `hermes` on the VPS

```sh
hermes config set terminal.container_persistent true
mkdir -p ~/hermes-workspace
hermes config set terminal.docker_volumes '["/home/hermes/hermes-workspace:/workspace"]'
```

Make sure the whole shared workspace tree is owned by `hermes`.

**Run as:** your admin user on the VPS

```sh
sudo chown -R hermes:hermes /home/hermes/hermes-workspace
sudo find /home/hermes/hermes-workspace -type d -exec chmod 755 {} \;
sudo find /home/hermes/hermes-workspace -type f -exec chmod 644 {} \;
```

Then confirm `hermes` can write inside the mounted workspace.

**Run as:** `hermes` on the VPS

```sh
touch ~/hermes-workspace/wikis/test-write.txt
rm ~/hermes-workspace/wikis/test-write.txt
```

What this does:

- `terminal.container_persistent true` tells Hermes to preserve the Docker sandbox filesystem across sessions
- `terminal.docker_volumes` bind-mounts `~/hermes-workspace` from the VPS into the container as `/workspace`
- files Hermes writes to `/workspace` inside the container will appear in `/home/hermes/hermes-workspace` on the VPS
- the ownership fix prevents a common failure mode where `/workspace` is mounted correctly but Hermes cannot write to the underlying host folders

For the recommended folder layout inside this mount, see [Personal Workspace Setup](./personal-workspace-setup.md).

If you want to use that shared workspace to generate a new Hermes personality file and then copy it into `~/.hermes/SOUL.md`, see [SOUL Workflow](./soul-workflow.md).
