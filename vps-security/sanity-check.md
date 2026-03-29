# VPS Sanity Check

Final verification steps for the Ubuntu VPS setup.

## Check SSH Config Is Active

**Run as:** `youruser` on the VPS

Verify the active SSH settings.

```sh
sudo sshd -T | grep -E "permitrootlogin|passwordauthentication|kbdinteractiveauthentication"
```

Expected output:

- `permitrootlogin no`
- `passwordauthentication no`
- `kbdinteractiveauthentication no`

## Check SSH Is Running

**Run as:** `youruser` on the VPS

Verify the SSH service is running.

```sh
sudo systemctl status ssh
```

Expected result:

- `active (running)`

## Check Firewall Status

**Run as:** `youruser` on the VPS

Verify `ufw` is active and using the expected defaults.

```sh
sudo ufw status verbose
```

Expected output:

- `Status: active`
- Default incoming policy set to deny
- Default outgoing policy set to allow
- Rules include `OpenSSH`
- Rules include `80/tcp` and `443/tcp` if you enabled HTTP and HTTPS

## Check Open Ports

**Run as:** `youruser` on the VPS

Review listening ports.

```sh
sudo ss -tulnp
```

What to check:

- Port `22` for SSH
- Ports `80` and `443` only if you enabled them
- No unexpected listening ports

## Check Unattended Upgrades

**Run as:** `youruser` on the VPS

Verify unattended upgrades are running.

```sh
sudo systemctl status unattended-upgrades
```

Expected result:

- `active (running)`

## Check Your User Permissions

**Run as:** `youruser` on the VPS

Verify the current user is in the `sudo` group.

```sh
id
```

Expected output:

- Includes `sudo`

## Check .ssh Permissions

**Run as:** `youruser` on the VPS

Verify the `.ssh` directory and `authorized_keys` file permissions.

```sh
ls -ld ~/.ssh
ls -l ~/.ssh
```

Expected output:

- `.ssh` shows `drwx------` (`700`)
- `authorized_keys` shows `-rw-------` (`600`)

## Check Root Login Is Blocked

**Run as:** your user on your `local machine`

Verify direct SSH login as `root` is blocked.

```sh
ssh root@YOUR_VPS_IP
```

Expected result:

- `Permission denied (publickey)`

## Check Password Login Is Blocked

**Run as:** your user on your `local machine`

Verify password authentication is blocked.

```sh
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no youruser@YOUR_VPS_IP
```

Expected result:

- `Permission denied`

## What This Verifies

If all checks pass, you have verified:

- SSH hardening is active
- Root login is disabled
- Password login is disabled
- The firewall is active
- Automatic security updates are enabled
- `youruser` has the expected permissions
- Only expected ports are open

## Final Verdict

If all checks pass, you are already way more secure than most VPS setups.
