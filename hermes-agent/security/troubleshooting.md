# Troubleshooting

Common Hermes setup failures and the fastest checks for this hardened VPS layout.

## `hermes`: command not found

> **Run as:** `hermes` on the VPS

Add `~/.local/bin` to your `PATH` and reload your shell:

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then rerun:

```sh
hermes doctor
```

## Missing Hermes symlink

If Hermes is still not found, the installer may have completed the core install but the per-user launcher symlink is missing.

Verify that the virtual-environment binary exists and restore the per-user symlink:

```sh
ls -l ~/.hermes/hermes-agent/venv/bin/hermes
ln -sf ~/.hermes/hermes-agent/venv/bin/hermes ~/.local/bin/hermes
hermes version
```

If `hermes doctor` reports `ModuleNotFoundError: No module named 'dotenv'`, you may be invoking the repository source launcher with system Python instead of the virtual-environment launcher. Check `command -v hermes` and make sure it resolves to `~/.local/bin/hermes`.

## Playwright browser dependencies

The current installer detects that `hermes` has no `sudo`, installs user-owned browser binaries, and reports the administrator command for missing system libraries. It should not require a `sudo` password from the Hermes session.

> **Run as:** your admin user on the VPS

```sh
sudo npx playwright install-deps chromium
```

> **Run as:** `hermes` on the VPS

If the browser binary itself is missing, install it in the Hermes user's cache:

```sh
cd ~/.hermes/hermes-agent
npx playwright install chromium
```

For a headless setup that does not use browser automation, reinstall with the official `--skip-browser` option instead of adding privileges to the `hermes` user.

## Docker still uses the old system socket

> **Run as:** `hermes` on the VPS

```sh
echo "$DOCKER_HOST"
docker context ls
docker info
```

Expected result:

- `DOCKER_HOST` points to `unix:///run/user/<your-hermes-uid>/docker.sock`
- `docker info` shows `rootless` under `Security Options`
- the Docker client is no longer using `/var/run/docker.sock`

If you still see the system socket, log out completely and reconnect as `hermes`, then rerun the verification commands.

If `docker context ls` warns that `DOCKER_HOST` overrides the active context, that is expected and safe to ignore in this setup.

## Gateway logs

> **Run as:** `hermes` on the VPS

Use this when the Telegram gateway service is installed but not responding:

```sh
journalctl --user -u hermes-gateway -f
```

Check service status with:

```sh
hermes gateway status
```

## Gateway stops after logout or reboot

> **Run as:** your admin user on the VPS

Enable systemd linger for the `hermes` user:

```sh
sudo loginctl enable-linger hermes
loginctl show-user hermes
```

Expected result:

- `loginctl show-user hermes` includes `Linger=yes`

## Shared workspace is mounted but not writable

> **Run as:** your admin user on the VPS

Make sure the host workspace tree is owned by `hermes`:

```sh
sudo chown -R hermes:hermes /home/hermes/hermes-workspace
sudo find /home/hermes/hermes-workspace -type d -exec chmod 755 {} \;
sudo find /home/hermes/hermes-workspace -type f -exec chmod 644 {} \;
```

Then confirm `hermes` can write inside the mounted workspace:

> **Run as:** `hermes` on the VPS

```sh
touch ~/hermes-workspace/wikis/test-write.txt
rm ~/hermes-workspace/wikis/test-write.txt
```
