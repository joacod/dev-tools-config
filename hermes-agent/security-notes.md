# Security notes

Security notes for this Hermes Agent VPS setup.

## Dedicated Hermes user

Keep Hermes running as the dedicated `hermes` user with no `sudo` by default.

This keeps the agent separate from your main admin account and limits what it can modify on the host without an explicit admin step.

## No sudo for Hermes

Do not add `hermes` to broad admin groups unless you have a specific reason.

The install flow intentionally runs system package installation from your admin user and keeps Hermes itself non-sudo.

## Rootless Docker vs system Docker

Use rootless Docker for Hermes when the VPS also runs Dokploy or other system Docker workloads.

Adding `hermes` to the system `docker` group would give it root-equivalent control over the system Docker daemon and anything attached to `/var/run/docker.sock`.

A separate rootless Docker daemon keeps Hermes from controlling Dokploy containers through the system socket.

## API key permissions

Keep API keys in `~/.hermes/.env` and make sure that file is only readable by `hermes`.

```sh
chmod 600 ~/.hermes/.env
```

Why this matters:

- `600` means only the file owner can read and write the file
- your API keys stay private to the `hermes` account instead of being readable by other users on the VPS
- this matters even more if you expose Hermes through Telegram

## Telegram allowed users

Keep Telegram restricted to your bot token and your approved Telegram user IDs.

Do not leave the bot open to anyone who can find or message it.

## Dashboard localhost tunnel

Keep the dashboard bound to localhost on the VPS and reach it through an SSH tunnel.

```sh
ssh -N -L 9119:127.0.0.1:9119 hermes
```

Then open:

```text
http://127.0.0.1:9119
```

This avoids exposing the dashboard on a public VPS port.

Security reference:

- [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security)
