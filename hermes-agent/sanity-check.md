# Hermes Agent Sanity Check

Final verification steps for the Hermes Agent VPS setup.

## Check SSH Alias Works

**Run as:** your user on your `local machine`

Verify the local SSH alias connects to the right host with the right key.

```sh
ssh hermes
```

Expected result:

- you connect without typing `hermes@YOUR_VPS_IP`
- the dedicated Hermes key is used

## Check Current User

**Run as:** `hermes` on the VPS

Verify you are logged in as the dedicated user.

```sh
whoami
id
```

Expected output:

- `whoami` returns `hermes`
- `id` does not need to include `sudo`

## Check Hermes Command Is Installed

**Run as:** `hermes` on the VPS

Verify the Hermes CLI is installed and healthy.

```sh
hermes version
hermes doctor
hermes status
```

Expected result:

- the `hermes` command exists
- `hermes doctor` completes without blocking install issues
- `hermes status` shows your configured environment

## Check Docker Backend

**Run as:** `hermes` on the VPS

Only run this section if you chose Docker as the Hermes terminal backend.

```sh
docker --version
docker run hello-world
```

Expected result:

- Docker is installed and available to the `hermes` user
- `hello-world` runs successfully

## Check Provider Configuration

**Run as:** `hermes` on the VPS

Verify Hermes has a usable model provider configured.

```sh
hermes status
```

Expected result:

- at least one provider is configured with working authentication or an API key
- the selected model is usable for normal chat sessions

## Check Hermes Home Permissions

**Run as:** `hermes` on the VPS

Verify the Hermes secrets file has restrictive permissions.

```sh
ls -l ~/.hermes/.env
```

Expected output:

- `~/.hermes/.env` shows `-rw-------` (`600`)

## Check Gateway Service

**Run as:** `hermes` on the VPS for gateway status, and your admin user on the VPS for the linger check

Only run this section if you installed the messaging gateway.

```sh
hermes gateway status
```

```sh
loginctl show-user hermes
```

Expected result:

- the service shows as running
- `loginctl show-user hermes` includes `Linger=yes`

## What This Verifies

If all checks pass, you have verified:

- the local `ssh hermes` alias works
- Hermes is isolated under its own Ubuntu user
- the Hermes CLI is installed and available
- Docker is ready if you chose the Docker backend
- a model provider is configured for normal Hermes use
- the main secrets file has restrictive permissions
- the gateway service is running correctly if enabled

## Final Verdict

If all checks pass, Hermes is installed on the VPS with a dedicated user, dedicated SSH access, and a cleaner separation from your main admin account.
