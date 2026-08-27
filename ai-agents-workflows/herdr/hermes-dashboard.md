# Hermes dashboard through Herdr

Use Herdr to keep the Hermes dashboard running on the VPS, then expose it locally through an SSH tunnel. This keeps the dashboard process inside a persistent Herdr session instead of tying it to an ordinary SSH terminal.

The Hermes dashboard itself is documented in the [Hermes dashboard guide](../hermes-agent/security/dashboard.md). This guide covers the Herdr workflow around it.

## Start the remote dashboard

From your local machine, attach to the VPS through the existing `hermes` SSH alias:

```sh
herdr --remote hermes
```

Inside the remote Herdr workspace, run the dashboard:

```sh
hermes dashboard
```

Hermes serves the dashboard on the VPS at `127.0.0.1:9119`. Leave this command running in its Herdr pane. You can use another pane for other work.

## Create the local tunnel

In a separate local terminal, start or reattach to a local Herdr session:

```sh
herdr
```

In a dedicated local Herdr pane, run:

```sh
ssh -N -L 9119:127.0.0.1:9119 hermes
```

This forwards local port `9119` through the existing SSH-over-Tailscale alias to the dashboard bound to localhost on the VPS. Keeping the tunnel in a local Herdr pane means it can continue running after the local terminal client disconnects.

## Open the dashboard

Open the following URL on your local machine:

```text
http://127.0.0.1:9119
```

## Reconnect and recovery

- Close or detach the local terminal clients normally. The remote dashboard and local tunnel remain in their Herdr sessions while the machines stay running.
- After a local machine reboot, start or reattach to local Herdr and recreate the SSH tunnel if it was not restored.
- After a VPS reboot, reconnect with `herdr --remote hermes` and verify that `hermes dashboard` is still running. Start it again if necessary.
- After updating Hermes or Herdr, verify the dashboard dependencies, port, remote process, and SSH tunnel again.

For the VPS and SSH prerequisites, see the [hardened Hermes VPS setup](../hermes-agent/security/README.md) and [SSH over Tailscale guide](../../server-infrastructure/tailscale/ssh-over-tailscale-for-vps.md).
