# SSH user setup

Create an isolated `hermes` VPS user, give it a dedicated SSH key, and add a local `ssh hermes` alias.

This phase should be done after completing [VPS security](../../../server-infrastructure/vps-security/README.md).

## Add Hermes user

> **Run as:** your existing admin user on the VPS

Create a dedicated Ubuntu user for Hermes without setting a local password or filling in profile fields.

```sh
sudo adduser --disabled-password --gecos "" hermes
id hermes
```

Why this user exists:

- Hermes should not run as `root`
- keeping Hermes on its own account limits what it can touch by default
- your own admin account stays separate from the agent account
- avoiding `sudo` for Hermes reduces what the agent can modify on the system

## Generate SSH key for Hermes

> **Run as:** your user on your `local machine`

Generate a dedicated SSH key for the `hermes` user on this VPS.

```sh
ssh-keygen -t ed25519 -C "hermes_vps"
```

When prompted for the file path, use `/Users/[username]/.ssh/hermes_vps`.

## Install the public key for Hermes

> **Run as:** your existing admin user on the VPS

Because password login is already disabled from the base VPS setup, `ssh-copy-id` will usually fail for a brand new `hermes` user.

Instead, install the public key from the server side while logged in with your existing admin user.

First, print the public key on your local machine.

```sh
cat ~/.ssh/hermes_vps.pub
```

Copy the full output, then on the VPS create the SSH directory and paste the key into `authorized_keys`.

```sh
sudo mkdir -p /home/hermes/.ssh
sudo nano /home/hermes/.ssh/authorized_keys
```

Paste the public key on its own line, then save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

Set the correct ownership and permissions.

```sh
sudo chown -R hermes:hermes /home/hermes/.ssh
sudo chmod 700 /home/hermes/.ssh
sudo chmod 600 /home/hermes/.ssh/authorized_keys
```

What these commands do:

- `sudo chown -R hermes:hermes /home/hermes/.ssh` makes sure the `.ssh` folder and everything inside it belongs to the `hermes` user
- `sudo chmod 700 /home/hermes/.ssh` makes the `.ssh` folder private so only `hermes` can access it
- `sudo chmod 600 /home/hermes/.ssh/authorized_keys` makes the `authorized_keys` file private so only `hermes` can read or edit it

This matters because SSH is strict about file ownership and permissions. If these are too open, SSH may ignore the key and refuse login.

## Add local SSH config

> **Run as:** your user on your `local machine`

Add a host alias so you can connect with `ssh hermes`.

> **Important:** If `~/.ssh/config` already exists and has other hosts in it, do not replace the file contents. Add this as a new block alongside your existing SSH config.

```sh
nano ~/.ssh/config
```

Add the following config.

```sshconfig
Host hermes
  HostName YOUR_VPS_IP
  User hermes
  IdentityFile ~/.ssh/hermes_vps
  IdentitiesOnly yes
```

Save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

If the VPS later uses [SSH over Tailscale for VPS](../../../server-infrastructure/tailscale/ssh-over-tailscale-for-vps.md), replace `HostName YOUR_VPS_IP` with the VPS Tailscale IP or MagicDNS hostname. The `User` and `IdentityFile` lines stay the same.

## Login as Hermes

> **Run as:** your user on your `local machine`

Verify the new key and host alias work.

```sh
ssh hermes
```
