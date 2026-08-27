# VPS security

Basic VPS configuration and security recommendations for Ubuntu servers.

| Item | Value |
| --- | --- |
| OS | Ubuntu |
| Run from | Local machine and VPS |
| Prerequisites | Root access to the VPS |
| Outcome | Hardened VPS with SSH, firewall, updates, and Fail2ban configured |

## What this setup does

This guide walks you through a simple baseline hardening setup for a public Ubuntu VPS.

- **SSH is locked down:** no root login, no password authentication, only your key
- **A dedicated non-root user is used:** admin tasks happen through `sudo` instead of logging in as `root`
- **The firewall limits exposure:** only the ports you actually need are left open
- **Fail2ban blocks abuse:** repeated failed SSH login attempts get banned automatically
- **Automatic updates are enabled:** security patches keep getting applied over time
- **Local SSH config keeps login simple:** `ssh myvps` uses the right key without conflicting with other SSH setups

**Result:** a safer default VPS setup with less unnecessary exposure and a simpler SSH workflow from your local machine.

## Tailscale

For this repo's normal VPS stack, the intended next step after this guide is [SSH over Tailscale for VPS](../tailscale/ssh-over-tailscale-for-vps.md).

That keeps SSH private inside your tailnet instead of leaving port `22` exposed on the public internet.

## Before you start

First connect to the VPS as `root` from your local machine terminal.

```sh
ssh root@YOUR_VPS_IP
```

Use the first server-side step while connected to the VPS as `root`. After that, use `youruser` unless a section says otherwise.

## Add user

> **Run as:** `root` on the VPS after logging in from your local machine

Create a non-root user and give it sudo access.

```sh
adduser youruser
usermod -aG sudo youruser
id youruser
```

## Generate SSH key

> **Run as:** your user on your `local machine`

Generate a dedicated SSH key on your local machine.

```sh
ssh-keygen -t ed25519 -C "vps-server"
```

When prompted for the file path, use `/Users/[username]/.ssh/vps_server`.

## Copy key to VPS

> **Run as:** your user on your `local machine`

Copy the public key to your server.

```sh
ssh-copy-id -i /Users/[username]/.ssh/vps_server.pub youruser@YOUR_VPS_IP
```

## Add local SSH config

> **Run as:** your user on your `local machine`

Add a **host alias** so your local machine uses the dedicated key for this VPS.

> **Important:** If `~/.ssh/config` already exists and has other hosts in it, do not replace the file contents. Add this as a new block alongside your existing SSH config.

```sh
nano ~/.ssh/config
```

Add the following config.

```sshconfig
Host myvps
  HostName YOUR_VPS_IP
  User youruser
  IdentityFile ~/.ssh/vps_server
  IdentitiesOnly yes
```

Save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

## Login

> **Run as:** your user on your `local machine`

Connect using the new key through the host alias, then verify normal login works.

```sh
ssh myvps
```

Then log out and verify it still works:

```sh
logout
ssh myvps
```

## Harden SSH

> **Run as:** `youruser` on the VPS

Set a safe terminal value first, then create an SSH hardening config file.

```sh
export TERM=xterm
sudo nano /etc/ssh/sshd_config.d/99-hardening.conf
```

Paste the following config.

```text
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
```

Save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

Validate the SSH config before continuing:

```sh
sudo sshd -t
```

**No output:** the config is valid.

**Any error output:** stop and fix it before continuing.

## Enable the firewall

> **Run as:** `youruser` on the VPS

Install and configure `ufw`.

```sh
sudo apt update
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw limit OpenSSH
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
sudo ufw status verbose
```

## Cloud firewall

If your VPS provider offers a network or cloud firewall, enable it there too.

Why this matters:

- `ufw` runs on the VPS itself
- Docker can publish ports using its own iptables rules, which can bypass normal `ufw` filtering on Linux
- a provider firewall filters traffic before it ever reaches the VPS

Recommended baseline:

- allow public `80/tcp` (source any)
- allow public `443/tcp` (source any)
- allow `22/tcp` (optional, only if you still use public SSH)
- deny everything else

Treat this as the first firewall layer and `ufw` as the second layer on the server.

Example: on Hostinger, create a VPS Firewall in hPanel and only allow the ports above. This keeps accidentally published Docker ports from being reachable from the public internet.

## Docker boundary

If you later install both Dokploy and Hermes on the same machine, do not let Hermes share the system Docker daemon that Dokploy uses.

For this repo's intended same-machine setup:

- Dokploy uses the system Docker daemon
- Hermes uses a separate rootless Docker daemon owned by the `hermes` user
- the `hermes` user should not be added to the system `docker` group

## Update the system

> **Run as:** `youruser` on the VPS

Upgrade installed packages.

```sh
sudo apt update && sudo apt upgrade -y
```

## Automatic security updates

> **Run as:** `youruser` on the VPS

Enable unattended security updates.

```sh
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure unattended-upgrades
```

## Fail2ban

> **Run as:** `youruser` on the VPS

Fail2ban is recommended basic protection for SSH.

What it does:

- Watches system logs
- Detects repeated failed login attempts
- Blocks attacker IPs through your firewall

If someone fails login too many times, they get blocked automatically.

Install the package.

```sh
sudo apt install fail2ban -y
```

Create a minimal jail configuration.

```sh
sudo nano /etc/fail2ban/jail.local
```

Paste the following config.

```ini
[sshd]
enabled = true
port = ssh
maxretry = 5
findtime = 10m
bantime = 1h
```

Save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

Restart the service and check its status:

```sh
sudo systemctl restart fail2ban
sudo systemctl status fail2ban --no-pager
```

Verify the SSH jail is loaded:

```sh
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

Expected checks:

- A jail list that includes `sshd`
- Current failed attempts
- Current banned IPs
- Your configured SSH jail active

## Final step

Run the [sanity check](./sanity-check.md) to verify that the VPS is configured correctly.

After the baseline setup is done, use the ongoing [server maintenance guide](./server-maintenance.md) for low-risk manual upkeep.
