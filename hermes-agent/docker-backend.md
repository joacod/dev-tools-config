# Docker Backend

Configure Hermes to use a separate rootless Docker daemon instead of the host system Docker daemon.

This is the recommended path when Hermes shares a machine with something like Dokploy.

## Why Rootless Docker

- Dokploy uses the system Docker daemon
- adding `hermes` to the system `docker` group would give `hermes` root-equivalent control of that daemon
- a separate rootless Docker daemon keeps Hermes from controlling Dokploy containers through `/var/run/docker.sock`

## 1. Install Rootless Docker Prerequisites

**Run as:** your admin user on the VPS

If Docker is already installed for Dokploy, you do not need to reinstall the base engine. You only need the rootless extras package and the user namespace helpers.

```sh
sudo apt update
sudo apt install docker-ce-rootless-extras uidmap -y
```

## 2. Remove `hermes` From The System `docker` Group

**Run as:** your admin user on the VPS

```sh
sudo gpasswd -d hermes docker
id hermes
```

Expected result:

- `id hermes` no longer lists the `docker` group

## 3. Set Up Rootless Docker As `hermes`

**Run as:** `hermes` on the VPS

```sh
dockerd-rootless-setuptool.sh install
```

Then add the Docker socket path for the current `hermes` user and reload the shell.

```sh
echo 'export PATH=/usr/bin:$PATH' >> ~/.bashrc
echo "export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock" >> ~/.bashrc
source ~/.bashrc
```

If the rootless Docker service is not already running after setup, start it once in the current session.

```sh
systemctl --user start docker
```

This guide uses `DOCKER_HOST` as the one explicit way to tell Hermes which Docker daemon to use.

That matters because Hermes only knows it should use the `docker` backend. The actual Docker socket still comes from the `hermes` user environment.

This socket is used by the host-level Hermes gateway to create terminal sandboxes. It is not mounted into those sandboxes by default. Therefore, commands running inside a Hermes terminal container cannot themselves run Docker or Compose against the host daemon.

This distinction is intentional. Mounting the rootless socket into a sandbox would grant that sandbox full authority as the host `hermes` user, including the ability to create containers with mounts of Hermes-owned credentials, state, and workspace files. Use `ssh hermes` for supervised host-side Docker work instead of exposing the socket to the autonomous sandbox.

If `docker context ls` later warns that `DOCKER_HOST` overrides the active context, that is expected and safe to ignore in this setup.

## 4. Verify Rootless Docker As `hermes`

**Run as:** `hermes` on the VPS

```sh
docker context ls
docker info
docker run hello-world
```

Expected result:

- `docker info` shows `rootless` under `Security Options`
- `docker run hello-world` completes successfully
- the Docker client is no longer using `/var/run/docker.sock`
- `docker ps` does not show Dokploy containers from the system Docker daemon

## 5. If Hermes Still Uses The Old System Docker Socket

**Run as:** `hermes` on the VPS

```sh
echo "$DOCKER_HOST"
docker context ls
```

If you still see the system socket, log out completely and reconnect as `hermes`, then rerun the verification commands.

## 6. Make The Rootless Socket Available To Hermes Services Too

**Run as:** `hermes` on the VPS

If you run Hermes as a long-lived user service, make the same Docker socket available outside interactive shells too.

```sh
mkdir -p ~/.config/environment.d
nano ~/.config/environment.d/docker.conf
```

Add:

```ini
DOCKER_HOST=unix:///run/user/1002/docker.sock
PATH=/usr/bin
```

Save and exit with `CTRL + O`, `ENTER`, then `CTRL + X`.

If your `hermes` user has a different UID on another machine, replace `1002` with the value from `id -u`.

Reload the user environment:

```sh
systemctl --user daemon-reload
systemctl --user import-environment DOCKER_HOST PATH
systemctl --user show-environment | grep DOCKER_HOST
```

Expected result:

- `systemctl --user show-environment | grep DOCKER_HOST` shows the rootless Docker socket path

Docker reference:

- [Docker Rootless Mode](https://docs.docker.com/engine/security/rootless/)
