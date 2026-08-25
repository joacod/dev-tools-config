# Herdr

[Herdr](https://herdr.dev/) is a persistent terminal workspace and runtime for coding agents. It keeps shells, agents, Git commands, tests, and development servers running in background sessions that can be reattached later.

## Install

Install Herdr on macOS or Linux:

```sh
curl -fsSL https://herdr.dev/install.sh | sh
```

Verify the installation:

```sh
herdr --version
```

Start or reattach to the default local session:

```sh
herdr
```

## Integrations

Herdr detects supported agents automatically. Integrations add native lifecycle state and session restore support.

### OpenCode

Install the OpenCode plugin:

```sh
herdr integration install opencode
```

Herdr writes the plugin to `~/.config/opencode/plugins/herdr-agent-state.js`. The OpenCode config directory must already exist. See the [OpenCode setup](../opencode/README.md) for the local configuration files.

### Pi

Install the Pi integration:

```sh
herdr integration install pi
```

Herdr writes the extension to `~/.pi/agent/extensions/herdr-agent-state.ts`. The Pi agent directory must already exist.

Check installed integration versions and status:

```sh
herdr integration status
```

## Agent skill

Install the Herdr skill globally for agents that support reusable skills:

```sh
npx skills add herdrdev/herdr --skill herdr -g
```

The skill teaches coding agents how to inspect and control Herdr from inside a Herdr-managed pane. It uses `HERDR_ENV=1` as the safety check before running Herdr control commands.

## Hermes on a VPS

The existing [`hermes` SSH alias](../hermes-agent/security/ssh-user-setup.md) connects to the dedicated Hermes user on the VPS, including the current SSH-over-Tailscale setup. With Herdr installed locally, attach to that VPS with:

```sh
herdr --remote hermes
```

This starts or attaches to the Herdr server on the VPS while using the local terminal as the interface. Everything opened or executed in that session runs on the VPS, including shells, coding agents, Git commands, tests, and development servers.

The session continues running on the VPS after the local terminal closes or disconnects. Run the same command later to reconnect to the existing workspace and processes without manually opening an SSH session first.

See the [hardened Hermes VPS setup](../hermes-agent/security/README.md) and [SSH over Tailscale guide](../tailscale/ssh-over-tailscale-for-vps.md) for the VPS prerequisites.

For a persistent remote Hermes dashboard with a local SSH tunnel, see [Hermes dashboard through Herdr](./hermes-dashboard.md).

## References

- [Herdr documentation](https://herdr.dev/docs/)
- [Integrations](https://herdr.dev/docs/integrations/)
- [Agent skill](https://herdr.dev/docs/agent-skill/)
- [Persistence and remote access](https://herdr.dev/docs/persistence-remote/)
