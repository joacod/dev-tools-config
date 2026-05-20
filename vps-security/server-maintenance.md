# Server Maintenance

General Ubuntu VPS maintenance guidance focused on stability, hygiene, and avoiding breakage.

| Item | Value |
| --- | --- |
| OS | Ubuntu |
| Run from | VPS |
| Prerequisites | Supported Ubuntu release and `sudo` access |
| Outcome | A practical maintenance routine that keeps the server healthy without unnecessary risk |

## Scope

This file is for ongoing maintenance after the [`baseline VPS setup`](./README.md) is already done.

## Routine

Run this every 2 to 4 weeks, or monthly if the server is stable and lightly changing.

```sh
sudo apt update
```

```sh
sudo apt upgrade
```

```sh
sudo apt autoremove
```

- installs non-security package updates
- applies bug fixes and regular package updates
- keeps the system from drifting too far behind

Keep it conservative:

- do not use `-y` unless you already reviewed what will change
- prefer `apt upgrade` for routine maintenance
- avoid `apt full-upgrade` or `dist-upgrade` unless you intentionally want more invasive dependency changes

## Reboots

Some updates, especially kernel or low-level library updates, may require a reboot.

Check whether a reboot is needed:

```sh
[ -f /var/run/reboot-required ] && echo "reboot required"
```

If needed, reboot manually:

```sh
sudo reboot
```

Safer practice:

- reboot manually during a maintenance window
- if the server hosts important apps, verify service health after reboot

## Quick Checks

Run these when you want a quick health check:

```sh
sudo ufw status verbose
sudo ss -tulnp
sudo systemctl --failed
df -h
free -h
```

What to look for:

- only expected ports are listening
- no important services are in a failed state
- disk and memory look healthy

If something looks off, review recent high-priority boot errors:

```sh
sudo journalctl -p 3 -xb
```

## Avoid

- unnecessary PPAs and third-party repositories unless they are truly needed and trustworthy
- installing packages from Ubuntu Backports unless you explicitly need a newer version
- routine `dist-upgrade`, `full-upgrade`, or release upgrades as part of normal maintenance
- running an unsupported Ubuntu release

## Summary

- run `apt update` and `apt upgrade` manually on a light schedule
- use `apt autoremove` occasionally
- reboot deliberately when required
- stay on a supported LTS release
- avoid risky repositories and major upgrade actions as part of normal upkeep
