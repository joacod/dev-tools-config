# Troubleshooting

Common Hermes setup failures and the fastest checks for this VPS layout.

## `hermes`: Command Not Found

**Run as:** `hermes` on the VPS

Add `~/.local/bin` to your `PATH` and reload your shell.

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then rerun:

```sh
hermes version
```

## Missing Hermes Symlink

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

## Playwright Tries To Use Root Or Sudo

During the Hermes installer, if Playwright tries to switch to root and asks for a `sudo` password, stop there with `CTRL + C`.

Install the system dependencies from your admin user instead.

If your admin user installed Node.js with `nvm`, `sudo` will usually not see `node` or `npx` automatically. Run these commands from the admin user:

```sh
NODE_BIN_DIR="$(dirname "$(command -v node)")"
```

```sh
sudo env "PATH=$NODE_BIN_DIR:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" bash -lc 'cd /home/hermes/.hermes/hermes-agent && npx playwright install-deps'
```

Then switch back to `hermes` and install the Playwright browser binaries under the `hermes` user.

```sh
npx playwright install
```

## Docker Still Uses The Old System Socket

**Run as:** `hermes` on the VPS

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

## Gateway Logs

**Run as:** `hermes` on the VPS

Use this when the Telegram gateway service is installed but not responding.

```sh
journalctl --user -u hermes-gateway -f
```

Check service status with:

```sh
hermes gateway status
```

## Gateway Stops After Logout Or Reboot

**Run as:** your admin user on the VPS

Enable systemd linger for the `hermes` user.

```sh
sudo loginctl enable-linger hermes
loginctl show-user hermes
```

Expected result:

- `loginctl show-user hermes` includes `Linger=yes`

## Shared Workspace Is Mounted But Not Writable

**Run as:** your admin user on the VPS

Make sure the host workspace tree is owned by `hermes`.

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
