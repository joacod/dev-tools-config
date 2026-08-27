# Telegram gateway

Configure and run the optional Hermes Telegram gateway as the `hermes` user.

## Set up Telegram gateway

> **Run as:** `hermes` on the VPS for gateway setup, and your admin user on the VPS for the linger step

If you skipped Telegram during `hermes setup`, configure it now.

`hermes gateway setup` is the interactive configuration step. It does not keep the bot running in the background by itself.

```sh
hermes gateway setup
```

During Telegram setup, make sure you provide:

- your Telegram bot token from BotFather
- your own Telegram user ID in the allowed users list

## Install and start the service

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

## Later maintenance

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
