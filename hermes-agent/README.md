# Hermes Agent

[Hermes Agent](https://hermes-agent.nousresearch.com/) is an open-source autonomous AI agent from Nous Research. Use it through the CLI, Hermes Desktop, or messaging integrations.

## Install

### Hermes Desktop

[Download Hermes Desktop](https://hermes-agent.nousresearch.com/desktop) for the easiest setup where supported. Desktop uses the same Hermes Agent core, configuration, sessions, skills, memory, and credentials as the CLI; it is not a separate product. See the [Desktop documentation](https://hermes-agent.nousresearch.com/docs/user-guide/desktop) for current details.

### CLI

For Linux, macOS, WSL2, or Android/Termux, use the official installer:

```sh
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

On native Windows, run the installer in PowerShell:

```powershell
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

On macOS, Linux, WSL2, or Termux, reload your shell and start Hermes:

```sh
source ~/.bashrc  # or: source ~/.zshrc
hermes
```

On Windows, open a new PowerShell session and run `hermes`. Use `hermes model` to choose or change a provider and model. If you use Nous Portal, `hermes setup --portal` configures the provider and Tool Gateway in one step.

For platform details and the complete first-run flow, use the official [installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation) and [quickstart](https://hermes-agent.nousresearch.com/docs/getting-started/quickstart) guides.

## Additional notes and configurations

The normal Hermes path is this README plus the [official Hermes documentation](https://hermes-agent.nousresearch.com/docs). The notes below are optional repository-specific material:

- [Model providers](./guides/model-providers.md) — reusable provider, OpenRouter, routing, and fallback notes
- [SOUL workflow](./guides/soul-workflow.md) — an optional workflow for the mounted Docker setup
- [SOUL template](./templates/SOUL-template.md)
- [Security-hardened Hermes VPS setup](./security/README.md)

The security-hardened setup is an optional, opinionated higher-isolation profile. For a more restrictive VPS deployment using a dedicated Linux user, rootless Docker, restricted gateways, SSH access, and private dashboard tunneling, see the [security-hardened setup](./security/README.md). It trades convenience and some integration capability for stronger isolation; it is not required for a normal Hermes installation.

## Official links

- [Hermes Agent](https://hermes-agent.nousresearch.com/)
- [Hermes documentation](https://hermes-agent.nousresearch.com/docs)
- [Hermes Desktop](https://hermes-agent.nousresearch.com/desktop)
