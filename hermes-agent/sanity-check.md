# Hermes Agent sanity check

Use this checklist after finishing the main [Hermes agent setup](./README.md).

Final verification steps for the Hermes Agent VPS setup.

## Check SSH alias works

> **Run as:** your user on your `local machine`

Verify the local SSH alias connects to the right host with the right key.

```sh
ssh hermes
```

Expected result:

- you connect without typing `hermes@YOUR_VPS_IP`
- the dedicated Hermes key is used

## Check current user

> **Run as:** `hermes` on the VPS

Verify you are logged in as the dedicated user.

```sh
whoami
id
```

Expected output:

- `whoami` returns `hermes`
- `id` does not need to include `sudo`

## Check Hermes command is installed

> **Run as:** `hermes` on the VPS

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

## Check rootless Docker backend

> **Run as:** `hermes` on the VPS

Only run this section if you chose Docker as the Hermes terminal backend.

```sh
echo "$DOCKER_HOST"
docker info
docker ps
```

Expected result:

- `DOCKER_HOST` points to `unix:///run/user/<your-hermes-uid>/docker.sock`
- `docker info` shows `rootless` under `Security Options`
- `docker ps` does not show Dokploy containers from the system Docker daemon

Optional extra check:

```sh
docker run hello-world
```

Expected result:

- `hello-world` runs successfully

## Check provider configuration

> **Run as:** `hermes` on the VPS

Verify Hermes has a usable model provider configured.

```sh
hermes status
```

Expected result:

- at least one provider is configured with working authentication or an API key
- the selected model is usable for normal chat sessions

## Check Hermes home permissions

> **Run as:** `hermes` on the VPS

Verify the Hermes secrets file has restrictive permissions.

```sh
ls -l ~/.hermes/.env
```

Expected output:

- `~/.hermes/.env` shows `-rw-------` (`600`)

## Check authoritative SOUL mount

> **Run as:** `hermes` on the VPS

After Hermes has used its default terminal at least once, identify the default sandbox and verify the active host personality file is mounted read-write.

```sh
container_id="$(docker ps -q \
  --filter label=hermes-task-id=default \
  --filter label=hermes-profile=default)"
```

If this returns an empty value, use the Hermes terminal once so the default sandbox is created, then rerun the command.

```sh
docker inspect "$container_id" \
  --format '{{range .Mounts}}{{if eq .Destination "/root/.hermes/SOUL.md"}}{{.Source}} -> {{.Destination}} RW={{.RW}}{{end}}{{end}}'
```

Expected output:

```text
/home/hermes/.hermes/SOUL.md -> /root/.hermes/SOUL.md RW=true
```

This verifies that Hermes edits the authoritative host file rather than a task-specific sandbox copy.

## Check gateway service

> **Run as:** `hermes` on the VPS for gateway status, and your admin user on the VPS for the linger check

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

## What this verifies

If all checks pass, you have verified:

- the local `ssh hermes` alias works
- Hermes is isolated under its own Ubuntu user
- the Hermes CLI is installed and available
- Hermes uses its own rootless Docker daemon if you chose the Docker backend
- Hermes does not share Dokploy's system Docker daemon
- a model provider is configured for normal Hermes use
- the main secrets file has restrictive permissions
- the default terminal uses the authoritative persistent `SOUL.md`
- the gateway service is running correctly if enabled

## Final verdict

If all checks pass, Hermes is installed on the VPS with a dedicated user, dedicated SSH access, and a cleaner separation from your main admin account.
