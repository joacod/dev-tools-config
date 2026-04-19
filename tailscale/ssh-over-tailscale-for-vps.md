# SSH Over Tailscale For VPS

Recommended follow-up guide to move VPS SSH access from the public internet to your Tailscale network while keeping normal OpenSSH users, keys, and permissions.

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

For this repo's Dokploy and Hermes VPS flow, this is the intended SSH setup after the base hardening guide.

## Before You Start

This guide assumes:

- the base hardening steps in [`VPS Security`](../vps-security/README.md) are already done
- Tailscale is installed and connected on the VPS
- Tailscale is installed and connected on your local machine
- your current SSH access still works before you change the firewall rules

If you still need the basic Tailscale setup, start with [README.md](./README.md).

## Update Local SSH Aliases

**Run as:** your user on your `local machine`

Replace `HostName YOUR_VPS_IP` in your local SSH aliases with the VPS `MagicDNS hostname`.

Example:

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

If you do not use MagicDNS, use the VPS Tailscale IP instead.

## Check The Current VPS State

**Run as:** your admin user on the VPS

Verify SSH, Tailscale, and the current firewall rules before changing anything.

```sh
sudo systemctl status ssh
tailscale status
tailscale ip -4
sudo ufw status verbose
```

What to confirm before continuing:

- `sudo systemctl status ssh`: the service shows `active (running)`
- `tailscale status`: the VPS appears connected to your tailnet and does not show a disconnected state
- `tailscale ip -4`: you get a Tailscale IPv4 address you can use to sanity-check the machine identity if needed
- `sudo ufw status verbose`: `ufw` is active and you can see the current `OpenSSH` rule that will be removed later

If any of these checks look wrong, stop there and fix that problem before changing the firewall rules.

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

## Remove Public SSH Exposure

**Run as:** your admin user on the VPS

Your base VPS guide opens public SSH with `OpenSSH`. This step removes those public SSH rules after you already verified the Tailscale path works.

First list the current numbered rules:

```sh
sudo ufw status numbered
```

What to look for:

- one or more rules for `OpenSSH`
- the rule numbers attached to those `OpenSSH` entries

You will use those rule numbers in the next step.

**IMPORTANT**: after you delete the first rule, the remaining rule numbers can change. Run `sudo ufw status numbered` again before deleting the next `OpenSSH` rule so you do not remove the wrong entry.

Delete the `OpenSSH` rules you see there.

```sh
sudo ufw delete <RULE_NUMBER>
```

What to do here:

- replace `<RULE_NUMBER>` with the actual numbers shown by `sudo ufw status numbered`
- if you have both IPv4 and IPv6 `OpenSSH` rules, delete both

Then verify the firewall state.

```sh
sudo ufw status verbose
```

What to confirm before moving on:

- `sudo ufw status verbose` no longer shows public `OpenSSH` rules
- `sudo ufw status verbose` shows the `tailscale0` allow rule

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

The public-IP failure will often look like `Operation timed out` because `ufw` is dropping the incoming connection.

What this verifies:

- both local aliases now work over Tailscale with their existing users and keys
- SSH is no longer reachable from the public internet on the VPS public IP

## Rollback

**Run as:** your admin user on the VPS while you still have an open SSH session

If something goes wrong, re-open public SSH access temporarily.

```sh
sudo ufw allow OpenSSH
sudo ufw limit OpenSSH
sudo ufw reload
```

What to confirm after rollback:

- `sudo ufw reload` completes without errors
- `sudo ufw status verbose` shows the `OpenSSH` rules again
- you can reconnect using the old public SSH path if needed

## Notes

- Your SSH login model does not change: OpenSSH still decides which Linux user you become and what permissions that user has
- Fail2ban is still fine to keep installed, but it matters much less for SSH once public port `22` is no longer exposed

## Official References

- [Protect your SSH servers using Tailscale](https://tailscale.com/docs/reference/ssh-over-tailscale)
- [Set up MagicDNS](https://tailscale.com/docs/features/magicdns)
