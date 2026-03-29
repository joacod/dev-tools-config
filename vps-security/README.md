# VPS Security

Basic VPS configuration and security recommendations for Ubuntu servers.

## Before You Start

First connect to the VPS as `root` from your local machine terminal.

```sh
ssh root@YOUR_VPS_IP
```

Use the first server-side step while connected to the VPS as `root`. After that, use `youruser` unless a section says otherwise.

## Add User

**Run as:** `root` on the VPS after logging in from your local machine

Create a non-root user and give it sudo access.

```sh
adduser youruser
usermod -aG sudo youruser
id youruser
```

## Generate SSH Key

**Run as:** your user on your `local machine`

Generate a dedicated SSH key on your local machine.

```sh
ssh-keygen -t ed25519 -C "vps-server"
```

When prompted for the file path, use `/Users/[username]/.ssh/vps_server`.

## Copy Key To VPS

**Run as:** your user on your `local machine`

Copy the public key to your server.

```sh
ssh-copy-id -i /Users/[username]/.ssh/vps_server.pub youruser@YOUR_VPS_IP
```

## Add Local SSH Config

**Run as:** your user on your `local machine`

Add a **host alias** so your local machine uses the dedicated key for this VPS.

**Important**: If `~/.ssh/config` already exists and has other hosts in it, do not replace the file contents. Add this as a new block alongside your existing SSH config.

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

**Run as:** your user on your `local machine`

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

**Run as:** `youruser` on the VPS

Set a safe terminal value first, then create an SSH hardening config file.

```sh
export TERM=xterm
sudo nano /etc/ssh/sshd_config.d/99-hardening.conf
```

Paste the following config.

```sh
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

## Enable The Firewall

**Run as:** `youruser` on the VPS

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

## Update The System

**Run as:** `youruser` on the VPS

Upgrade installed packages.

```sh
sudo apt update && sudo apt upgrade -y
```

## Automatic Security Updates

**Run as:** `youruser` on the VPS

Enable unattended security updates.

```sh
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure unattended-upgrades
```

## Fail2ban

**Run as:** `youruser` on the VPS

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

```sh
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

## Final Step

Run the [sanity check](./sanity-check.md) to verify the VPS is configured correctly.
