# Hermes Agent

Install Hermes Agent on an already-configured Ubuntu VPS using a dedicated `hermes` user and a dedicated SSH key.

## What This Setup Does

This guide assumes you already completed the base server setup in [VPS Security](../vps-security).

- **Hermes runs as its own user:** keep the agent separate from your main admin account
- **A dedicated SSH key is used:** local access for Hermes does not reuse your other VPS keys
- **A local SSH alias keeps login simple:** `ssh hermes` connects with the right user and key
- **The official Hermes installer is used:** this guide points to upstream commands instead of replacing the docs

**Result:** Hermes is installed on the VPS with a smaller scope, simpler SSH access, and a cleaner path to follow the official documentation.

## Before You Start

This guide assumes all steps in [VPS Security](../vps-security/README.md) are already done.

You should already have:

- a hardened Ubuntu VPS
- a working non-root admin user with `sudo`
- SSH access working from your local machine

Use your existing admin user for the server-side setup steps below unless a section says otherwise.

## Add Hermes User

**Run as:** your existing admin user on the VPS

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

## Generate SSH Key For Hermes

**Run as:** your user on your `local machine`

Generate a dedicated SSH key for the `hermes` user on this VPS.

```sh
ssh-keygen -t ed25519 -C "hermes_vps"
```

When prompted for the file path, use `/Users/[username]/.ssh/hermes_vps`.

## Install The Public Key For Hermes

**Run as:** your existing admin user on the VPS

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

## Add Local SSH Config

**Run as:** your user on your `local machine`

Add a host alias so you can connect with `ssh hermes`.

**Important**: If `~/.ssh/config` already exists and has other hosts in it, do not replace the file contents. Add this as a new block alongside your existing SSH config.

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

## Login As Hermes

**Run as:** your user on your `local machine`

Verify the new key and host alias work.

```sh
ssh hermes
```

## Install Hermes Agent

Official install docs:

- [Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation)
- [Quickstart](https://hermes-agent.nousresearch.com/docs/getting-started/quickstart)


**Run as:** `hermes` on the VPS

Download and run the official install script.

```sh
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

During the installer:

- if prompted to install optional `ripgrep` and `ffmpeg`, answer `n`
- if prompted to install optional build tools, answer `n`
- if Playwright tries to switch to root and asks for a `sudo` password, stop there with `CTRL + C`

Why:

- `ripgrep` improves Hermes file and code search
- `ffmpeg` is needed for voice and TTS-related features
- build tools are not required for the default setup
- Playwright browser system dependencies are only needed for browser automation
- those packages are optional and require `sudo`, but this guide keeps `hermes` as a non-sudo user
- the `PATH` warning is usually not fatal during install, but you should still fix it for future shell sessions

Reload your shell so the new `hermes` command is available in the current session.

```sh
source ~/.bashrc
```

Check whether the command is available.

```sh
hermes version
```

If that command works, your `PATH` is already correct and you can continue.

## Troubleshooting

If you get `hermes: command not found`, add `~/.local/bin` to your `PATH` and reload again.

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then test again.

```sh
hermes version
```

If `hermes` is still not found, the installer may have completed the core install but skipped creating the final command symlink.

First verify the Hermes binary exists inside the installation directory.

```sh
ls -l ~/.hermes/hermes-agent/venv/bin/hermes
```

If that file exists, create the missing symlink manually.

```sh
ln -sf ~/.hermes/hermes-agent/venv/bin/hermes ~/.local/bin/hermes
```

Then verify again.

```sh
hermes version
```

## Optional System Packages

**Run as:** your admin user on the VPS

If you want optional system packages like `ripgrep` and `ffmpeg`, install them separately from your admin account.

These packages are installed system-wide, so once your admin user installs them, the `hermes` user can use them too.

First refresh Ubuntu's package list.

```sh
sudo apt update
```

Then install the optional packages Hermes can use.

```sh
sudo apt install ripgrep ffmpeg -y
```

Then switch back to `hermes` and continue with the Hermes setup.

## Install Docker For The Docker Backend

**Run as:** your admin user on the VPS

If you want Hermes to execute commands inside Docker instead of directly on the host, install Docker from Docker's official Ubuntu repository.

This looks longer than a normal `apt install`, but it is the standard secure setup:

- Ubuntu's default packages may lag behind Docker's current release
- Docker's repository packages are signed, so `apt` can verify what it installs
- once Docker is installed, you still need to allow the `hermes` user to run it without `sudo`

### 1. Install Docker repository prerequisites

```sh
sudo apt update
sudo apt install ca-certificates curl -y
```

### 2. Add Docker's signing key and repository

```sh
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list'
```

### 3. Install Docker

```sh
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

### 4. Allow the `hermes` user to use Docker

```sh
sudo usermod -aG docker hermes
```

This change does not apply to existing `hermes` shell sessions. Log out completely, then log back in as `hermes` before testing Docker.

### 5. Log back in as `hermes` and verify Docker works

If you skip the logout/login step, Docker commands may fail with `permission denied while trying to connect to the docker API`.

After reconnecting as `hermes`, run:

```sh
docker --version
docker run hello-world
```

After Docker is working for `hermes`, continue to the Hermes setup step below.

Relevant docs:

- [Docker Install](https://docs.docker.com/engine/install/ubuntu/)
- [Hermes Security](https://hermes-agent.nousresearch.com/docs/user-guide/security)

## Run Hermes Setup

**Run as:** `hermes` on the VPS

After Docker is installed and working, run the setup wizard.

```sh
hermes setup
```

For this guide's VPS setup:

- choose `Docker` as the terminal backend
- choose whether you want a persistent filesystem
- if you want Telegram access, you can configure it during `hermes setup` or later with `hermes gateway setup`

## Configure A Model Provider

**Run as:** `hermes` on the VPS

Hermes needs a provider before it can chat normally.

Run the model selector and complete login or API key setup.

```sh
hermes model
```

## Set Up Telegram Gateway

**Run as:** `hermes` on the VPS for Telegram setup, and your admin user on the VPS for service installation

If you skipped Telegram during `hermes setup`, configure it now.

`hermes gateway setup` is the interactive configuration step. It does not keep the bot running in the background by itself.

```sh
hermes gateway setup
```

After that, install the gateway as a user service while logged in as `hermes`.

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

If you change gateway settings later, restart the gateway service as `hermes`.

```sh
hermes gateway restart
```

If you need to watch the gateway logs while logged in as `hermes`:

```sh
journalctl --user -u hermes-gateway -f
```

Official gateway docs:

- [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/)

If you only plan to use Hermes over SSH and the CLI, you can skip this section.

## Final Verification

**Run as:** `hermes` on the VPS unless a command includes `sudo`

Verify the final configuration.

```sh
hermes doctor
hermes status
```

If you installed the gateway service, also verify that systemd linger is enabled and the gateway is running.

```sh
hermes gateway status
```

```sh
loginctl show-user hermes
```

Start an interactive session when setup is complete.

```sh
hermes
```

## Security Notes

Hermes' official docs recommend a few production basics that fit this VPS setup well:

- run Hermes as a non-root user
- keep API keys in `~/.hermes/.env`
- lock down the file permissions on that file
- use explicit allowlists for messaging users
- consider a container backend for production use
- do not give the `hermes` user `sudo` unless you have a specific operational need

Useful commands:

```sh
chmod 600 ~/.hermes/.env
```

Relevant official docs:

- [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security)

## Recommended Production Notes

If you expose Hermes through the messaging gateway on a VPS:

- do not use `GATEWAY_ALLOW_ALL_USERS=true`
- prefer platform-specific allowlists or pairing
- keep Hermes running as `hermes`, not `root`
- keep `hermes` as a regular user with no `sudo` by default
- consider setting the terminal backend to Docker for stronger isolation

Example follow-up command:

```sh
hermes config set terminal.backend docker
```

See the official security and messaging docs before enabling public-facing access.

## Final Step

Run the [sanity check](./sanity-check.md) to verify the SSH alias, user separation, and Hermes install are working correctly.
