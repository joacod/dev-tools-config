# Server Maintenance

General Ubuntu VPS maintenance guidance focused on stability, hygiene, and avoiding breakage.

| Item | Value |
| --- | --- |
| OS | Ubuntu |
| Run from | VPS |
| Prerequisites | Supported Ubuntu release and `sudo` access |
| Outcome | A practical maintenance routine that keeps the server healthy without unnecessary risk |

## Core Principle

Treat maintenance in layers:

1. Baseline security setup and automated security patching
2. Small manual maintenance for general package hygiene
3. Careful handling of reboots, repositories, and major upgrades

## Scope

This file is for ongoing maintenance after the [`baseline VPS setup`](./README.md) is already done.

This guide covers the extra general maintenance around that setup.

## Recommended Manual Routine

Run this every 2 to 4 weeks, or monthly if the server is stable and lightly changing.

```sh
sudo apt update
sudo apt upgrade
```

This is mainly maintenance and hygiene.

Why this helps:

- installs non-security package updates
- pulls in bug fixes and minor improvements
- keeps the system from drifting too far behind

This is separate from automated security updates, which are already handled in the main VPS setup guide.

For safer manual maintenance:

- do not use `-y` unless you already reviewed what will change
- prefer `apt upgrade` for routine maintenance
- avoid `apt full-upgrade` or `dist-upgrade` unless you intentionally want more invasive dependency changes

## Useful Cleanup

Occasionally review and run:

```sh
sudo apt autoremove
```

Why:

- removes packages no longer needed
- reduces clutter
- can slightly reduce attack surface

Use it as a review step, not blindly every day.

## Reboots

Some updates, especially kernel or low-level library updates, may require a reboot.

Check whether a reboot is needed:

```sh
[ -f /var/run/reboot-required ] && echo "reboot required"
```

Safer practice:

- do not enable automatic reboot unless you fully understand the impact
- reboot manually during a maintenance window
- if the server hosts important apps, verify service health after reboot

## What To Check During Maintenance

### 1. Review Firewall Status

```sh
sudo ufw status verbose
```

### 2. Review Listening Ports

```sh
sudo ss -tulnp
```

Check that only expected ports are exposed.

### 3. Check Failed Services

```sh
sudo systemctl --failed
```

### 4. Check Disk Usage

```sh
df -h
```

### 5. Check Memory Pressure

```sh
free -h
```

### 6. Review Logs If Something Looks Off

```sh
sudo journalctl -p 3 -xb
```

Use this when a service failed, a reboot behaved unexpectedly, or the server feels unhealthy.

## When To Run Manual Maintenance Immediately

Do a manual update sooner if:

- you just installed new software
- you are about to deploy an important change
- the server has not been updated in a long time
- you changed repositories or package sources
- Ubuntu has published relevant update notices

## What To Avoid For A Stable VPS

### Avoid Unnecessary PPAs And Third-Party Repositories

Ubuntu community docs warn that non-Ubuntu repositories and PPAs can introduce inconsistencies and may complicate upgrades or even force reinstall work.

Only add them if:

- the software is truly required
- the source is trustworthy
- you understand how it affects future updates

### Avoid Relying On Backports For Normal Server Stability

Ubuntu Backports are community-tested, but they do not carry the normal Ubuntu Security Team support guarantee.

Default-safe approach:

- do not auto-prefer Backports
- only install from Backports deliberately and selectively if truly needed

### Avoid Routine Maintenance With Release Upgrades Or Dist-Upgrades

For normal upkeep, keep it conservative.

Use release upgrades only as planned projects, with backups and downtime expectations.

## Release Policy

For servers where stability matters, use Ubuntu LTS and keep the release supported.

Why:

- longer support window
- fewer disruptive platform changes
- better fit for production or personal VPS setups that should stay predictable

## Safe Maintenance Routine Summary

### Every Week Or Two

- verify the server is healthy
- review ports and firewall if needed

### Every 2 To 4 Weeks

```sh
sudo apt update
sudo apt upgrade
sudo apt autoremove
```

Then:

- check if a reboot is required
- reboot manually only when appropriate

### Before Larger Changes

- take a VPS snapshot or backup
- review package changes carefully
- avoid adding risky repositories unless necessary

## Sources Behind These Recommendations

These recommendations are based on Ubuntu community and Ubuntu documentation guidance around repositories, Backports, firewalls, upgrades, and release support policy.

- `Repositories/Ubuntu`: security updates are low risk, while PPAs and extra repositories are riskier
- `UbuntuBackports`: Backports do not have the normal Ubuntu Security Team security support guarantee
- `UpgradeNotes` and `EOLUpgrades`: stay on supported releases and treat major upgrades carefully
- `UFW`: keep inbound exposure minimal and verify the firewall state regularly

## Bottom Line

The safest practical Ubuntu VPS maintenance approach is:

- run `apt update` and `apt upgrade` manually on a light schedule
- use `apt autoremove` occasionally
- reboot deliberately when required
- stay on a supported LTS release
- avoid unnecessary PPAs, Backports, and major upgrade actions on a casual schedule
