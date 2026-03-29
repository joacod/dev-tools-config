# VPS Security

Basic VPS configuration and security recommendations for Ubuntu servers.

Use the first server-side step while logged in as `root`. After that, use `youruser` unless a section says otherwise.

## Add User

Run on the VPS while logged in as `root`.

Create a non-root user and give it sudo access.

```sh
adduser youruser
usermod -aG sudo youruser
id youruser
```

## Generate SSH Key

Run on your `local machine`.

Generate a dedicated SSH key on your local machine.

```sh
ssh-keygen -t ed25519 -C "vps-server"
```

When prompted for the file path, use:

```sh
/Users/[username]/.ssh/vps_server
```

## Copy Key To VPS

Run on your `local machine`.

Copy the public key to your server.

```sh
ssh-copy-id -i /Users/[username]/.ssh/vps_server.pub youruser@YOUR_VPS_IP
```

## Login

Run on your `local machine`.

Connect using the new key, then verify normal login works.

```sh
ssh -i /Users/[username]/.ssh/vps_server youruser@YOUR_VPS_IP
logout
ssh youruser@YOUR_VPS_IP
```

## Harden SSH

Run on the VPS while logged in as `youruser`.

Set a safe terminal value first, then create an SSH hardening config file.

```sh
export TERM=xterm
sudo nano /etc/ssh/sshd_config.d/99-hardening.conf
```

Paste this:

```sh
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
```

Save and exit:

- `CTRL + O` to save
- `ENTER` to confirm
- `CTRL + X` to exit

Validate the SSH config before continuing:

```sh
sudo sshd -t
```

If you see no output, the config is valid.

If you see errors, stop and fix them before continuing.

## Enable The Firewall

Run on the VPS while logged in as `youruser`.

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

Run on the VPS while logged in as `youruser`.

Upgrade installed packages.

```sh
sudo apt update && sudo apt upgrade -y
```

## Automatic Security Updates

Run on the VPS while logged in as `youruser`.

Enable unattended security updates.

```sh
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure unattended-upgrades
```

## Fail2ban

Run on the VPS while logged in as `youruser`.

Fail2ban is recommended basic protection for SSH.

It:

- Watches system logs
- Detects repeated failed login attempts
- Blocks attacker IPs through your firewall

If someone fails login too many times, they get blocked automatically.

Install the package:

```sh
sudo apt install fail2ban -y
```

Create a minimal jail configuration:

```sh
sudo nano /etc/fail2ban/jail.local
```

Paste this:

```sh
[sshd]
enabled = true
port = ssh
maxretry = 5
findtime = 10m
bantime = 1h
```

Save and exit:

- `CTRL + O` to save
- `ENTER` to confirm
- `CTRL + X` to exit

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

You should see:

- A jail list that includes `sshd`
- Current failed attempts
- Current banned IPs
- Your configured SSH jail active
