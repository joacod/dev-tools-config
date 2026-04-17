# SSH Over Tailscale For VPS

Optional add-on guide to move VPS SSH access from the public internet to your Tailscale network while keeping normal OpenSSH users, keys, and permissions.

| Item | Value |
| --- | --- |
| Run from | Local machine and VPS |
| Prerequisites | Completed [`VPS Security`](../vps-security/README.md) setup and Tailscale installed on both machines |
| Outcome | SSH works only over Tailscale while your existing OpenSSH users and keys stay the same |

## What This Setup Does

This guide is for standard OpenSSH over the Tailscale network.

It does not use Tailscale SSH.

Use this path if you want to:

- Keep separate Linux users such as `personal` and `hermes`
- Keep separate SSH private keys for each user
- Keep your normal `sudo` and `non-sudo` user permissions
- Remove public SSH exposure from port `22`

## Before You Start

This guide assumes:

- the base hardening steps in [`VPS Security`](../vps-security/README.md) are already done
- Tailscale is installed and connected on the VPS
- Tailscale is installed and connected on your local machine
- your current SSH access still works before you change the firewall rules

If you still need the basic Tailscale setup, start with [README.md](./README.md).

## Update Local SSH Aliases

**Run as:** your user on your `local machine`

Replace `HostName YOUR_VPS_IP` in your local SSH aliases with the VPS Tailscale IP or, if MagicDNS is enabled, the machine hostname.

Example with Tailscale IP:

```sshconfig
Host vps-personal
  HostName 100.x.y.z
  User personal
  IdentityFile ~/.ssh/personal_vps
  IdentitiesOnly yes

Host vps-hermes
  HostName 100.x.y.z
  User hermes
  IdentityFile ~/.ssh/hermes_vps
  IdentitiesOnly yes
```

Example with MagicDNS hostname:

```sshconfig
Host vps-personal
  HostName my-vps
  User personal
  IdentityFile ~/.ssh/personal_vps
  IdentitiesOnly yes

Host vps-hermes
  HostName my-vps
  User hermes
  IdentityFile ~/.ssh/hermes_vps
  IdentitiesOnly yes
```

Only the `HostName` value changes for this migration. Your users and private keys stay the same.

## Check The Current VPS State

**Run as:** your admin user on the VPS

Verify SSH, Tailscale, and the current firewall rules before changing anything.

```sh
sudo systemctl status ssh
tailscale status
tailscale ip -4
sudo ufw status verbose
```

## Test SSH Over Tailscale First

**Run as:** your user on your `local machine`

Do not continue until both SSH aliases work over Tailscale.

```sh
ssh vps-personal
ssh vps-hermes
```

## Allow SSH From Tailscale

**Run as:** your admin user on the VPS

Allow incoming traffic on the Tailscale interface.

```sh
sudo ufw allow in on tailscale0
```

Keep only the public ports you actually want to expose.

```sh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

Only keep `80/tcp` and `443/tcp` if you really need public web traffic.

## Remove Public SSH Exposure

**Run as:** your admin user on the VPS

Your base VPS guide opens public SSH with `OpenSSH`. This step removes those public SSH rules after you already verified the Tailscale path works.

First list the current numbered rules:

```sh
sudo ufw status numbered
```

Delete the `OpenSSH` rules you see there.

```sh
sudo ufw delete <RULE_NUMBER>
sudo ufw delete <RULE_NUMBER>
```

Then reload the firewall and restart SSH.

```sh
sudo ufw reload
sudo systemctl restart ssh
sudo ufw status verbose
```

## Final Verification

**Run as:** your user on your `local machine`

Verify the Tailscale path works and the public IP path no longer works.

```sh
ssh vps-personal
ssh vps-hermes
ssh personal@YOUR_PUBLIC_IP
```

Expected result:

- `ssh vps-personal` works
- `ssh vps-hermes` works
- `ssh personal@YOUR_PUBLIC_IP` fails

## Rollback

**Run as:** your admin user on the VPS while you still have an open SSH session

If something goes wrong, re-open public SSH access temporarily.

```sh
sudo ufw allow OpenSSH
sudo ufw limit OpenSSH
sudo ufw reload
```

## Notes

- If MagicDNS is enabled, using the hostname is usually easier than using the raw Tailscale IP
- Your SSH login model does not change: OpenSSH still decides which Linux user you become and what permissions that user has
- Fail2ban is still fine to keep installed, but it matters much less for SSH once public port `22` is no longer exposed

## Official References

- [Protect your SSH servers using Tailscale](https://tailscale.com/docs/reference/ssh-over-tailscale)
- [Set up MagicDNS](https://tailscale.com/docs/features/magicdns)
