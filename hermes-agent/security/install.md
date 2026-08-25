# Install Hermes Agent on the hardened VPS

Complete [SSH user setup](./ssh-user-setup.md) before this guide. This follows the current official per-user installer while keeping the VPS run-as and filesystem boundaries explicit.

The normal installation path is in the [main Hermes README](../README.md). The steps here are for the optional security-hardened profile.

## Check the VPS prerequisites

> **Run as:** your existing admin user on the VPS

The official installer needs Git. On Linux it also needs `curl` and `xz-utils`. The base VPS setup may already provide them; install any missing packages from the admin account:

```sh
sudo apt update
sudo apt install git curl xz-utils -y
```

The installer manages Python, Node.js, `ripgrep`, `ffmpeg`, the Hermes checkout, and the virtual environment. Do not manually run the installer as `root` or add `sudo` to the Hermes install command.

## Install Hermes Agent

> **Run as:** `hermes` on the VPS

Run the current official installer:

```sh
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

The installer detects that `hermes` is an unprivileged user. It installs the agent under the user's Hermes home and uses `~/.local/bin/hermes` for the command. If browser system libraries need administrator access, the installer skips that privileged step and reports what the administrator should run separately; it does not require giving `hermes` `sudo`.

Reload the shell and verify the install:

```sh
source ~/.bashrc
hermes doctor
hermes version
```

If you use a different shell, source its profile instead of `~/.bashrc`.

## Browser dependencies for a non-sudo user

Playwright's browser binaries can live in the `hermes` user's cache, but Chromium's shared Linux libraries are system packages.

> **Run as:** your admin user on the VPS, when browser automation is needed

Use the current upstream command:

```sh
sudo npx playwright install-deps chromium
```

> **Run as:** `hermes` on the VPS

If the installer skipped browser installation or you need to repair it, install the browser under the Hermes user:

```sh
cd ~/.hermes/hermes-agent
npx playwright install chromium
```

If this VPS only needs headless agent work without browser automation, the official installer also supports `--skip-browser`.

## Fix PATH if Hermes is not found

> **Run as:** `hermes` on the VPS

The per-user launcher is normally `~/.local/bin/hermes`. If `hermes doctor` returns `command not found`, add that directory to `PATH` and reload the shell:

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then rerun:

```sh
hermes doctor
```

If the launcher symlink is missing but the virtual-environment binary exists, restore the per-user symlink:

```sh
ls -l ~/.hermes/hermes-agent/venv/bin/hermes
ln -sf ~/.hermes/hermes-agent/venv/bin/hermes ~/.local/bin/hermes
hermes version
```

Do not replace this with a system-wide symlink unless you deliberately want every user to invoke the same Hermes installation.

## Run Hermes setup

> **Run as:** `hermes` on the VPS

Once the CLI works, run the setup wizard:

```sh
hermes setup
```

For this VPS profile:

- choose or configure `Docker` as the terminal backend after completing [rootless Docker](./docker-backend.md)
- choose a persistent filesystem when the wizard offers that option
- if you use Nous Portal, `hermes setup --portal` is the current one-command Portal path
- configure Telegram here or later with [Telegram gateway](./telegram-gateway.md)

If rootless Docker is ready and you want to set the backend explicitly:

```sh
hermes config set terminal.backend docker
```

For provider and model choices that work on any Hermes host, see [Model providers](../guides/model-providers.md).

## Configure the persistent Docker workspace and SOUL mount

After `hermes setup`, configure Hermes to keep its Docker sandbox filesystem between sessions, use a predictable host-mounted workspace at `/workspace`, and mount the authoritative personality file into the default sandbox.

This section assumes you completed [Docker backend](./docker-backend.md) and selected the Docker terminal backend.

> **Run as:** `hermes` on the VPS

```sh
hermes config set terminal.container_persistent true
mkdir -p ~/hermes-workspace/{repos,wikis,outputs,inbox}
hermes config edit
```

Under the existing `terminal` section, store `docker_volumes` as a YAML list:

```yaml
terminal:
  docker_volumes:
    - /home/hermes/hermes-workspace:/workspace
    - /home/hermes/.hermes/SOUL.md:/root/.hermes/SOUL.md
```

Do not pass the JSON-looking list to `hermes config set terminal.docker_volumes`. The CLI stores that argument as a string instead of a YAML list, and the Docker backend may ignore malformed volume configuration.

Make sure the whole shared workspace tree is owned by `hermes`.

> **Run as:** your admin user on the VPS

```sh
sudo chown -R hermes:hermes /home/hermes/hermes-workspace
sudo find /home/hermes/hermes-workspace -type d -exec chmod 755 {} \;
sudo find /home/hermes/hermes-workspace -type f -exec chmod 644 {} \;
```

Then confirm `hermes` can write inside the mounted workspace.

> **Run as:** `hermes` on the VPS

```sh
touch ~/hermes-workspace/wikis/test-write.txt
rm ~/hermes-workspace/wikis/test-write.txt
```

What this does:

- `terminal.container_persistent true` tells Hermes to preserve the Docker sandbox filesystem across sessions
- `terminal.docker_volumes` bind-mounts `~/hermes-workspace` at `/workspace` and the authoritative personality file at `/root/.hermes/SOUL.md`
- files Hermes writes to `/workspace` inside the container appear in `/home/hermes/hermes-workspace` on the VPS
- edits to `/root/.hermes/SOUL.md` update `/home/hermes/.hermes/SOUL.md` directly, with no manual copy step
- the ownership fix prevents a common failure mode where `/workspace` is mounted correctly but Hermes cannot write to the underlying host folders

For the folder convention inside this mount, see [Personal workspace setup](./personal-workspace-setup.md).

If you want Hermes to update its persistent personality through the authoritative file mount, see the [SOUL workflow](../guides/soul-workflow.md).
