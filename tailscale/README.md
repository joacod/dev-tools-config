# Tailscale

[Tailscale](https://tailscale.com/) is a secure, identity-based networking tool built on WireGuard that makes it easy to connect devices, servers, and private services across networks.

## What It Does

- Connects your devices into a private network
- Makes remote access to servers and services simpler
- Helps avoid exposing internal services directly to the public internet

## First Setup

- Create a Tailscale account
- Log in with your identity provider
- Follow the setup flow to add the devices you want to connect
- Repeat the process on each machine you want in the same tailnet

## Personal Plan

For personal use, the free Personal plan is usually more than enough.

- Free forever
- Up to 6 users
- Unlimited user devices
- Access to nearly all core features

## Good For

- Accessing a VPS or homelab remotely
- Reaching private services from your laptop
- Connecting machines across different networks with less VPN setup overhead

## Linux VPS Commands

On the VPS, run:

```sh
sudo tailscale up
```

Check the current connection status:

```sh
tailscale status
```

Check that you can reach another machine on your tailnet:

```sh
tailscale ping your-other-machine
```

If you want to use the regular system ping instead, use the machine name or Tailscale IP:

```sh
ping -c 4 your-other-machine
```

## Serve a Local URL

To expose a local service only inside your tailnet, run this on the machine hosting the service:

```sh
sudo tailscale serve --bg --https=9119 localhost:9119
```

This runs in the background, and Tailscale Serve stays configured even after a reboot.

Check the current Serve status:

```sh
tailscale serve status
```

You should see something similar to:

```text
Serve is enabled
Proxy: http://127.0.0.1:9119
Available within your tailnet at:
https://your-machine.your-tailnet.ts.net:9119
```

From your Mac, open the URL in a browser:

```sh
open https://your-machine.your-tailnet.ts.net:9119
```

To disable all Serve configuration on that machine, reset it:

```sh
tailscale serve reset
```

If you want to disable only that one Serve mapping, use:

```sh
tailscale serve --https=9119 off
```

If you are using multiple Serve mappings or non-default flags, use the matching `off` form for the specific mapping you want to remove.

## Notes

- Use the machine name or Tailscale IP when testing connectivity
- If MagicDNS is enabled, machine names are usually the easiest option
- `tailscale serve` shares the service only inside your tailnet, not publicly on the internet
- `tailscale serve reset` clears all Serve configuration on that machine, while matching `tailscale serve ... off` commands are better when you want to remove only one specific mapping

## VPS Guides

For a VPS that already uses the base hardening guide, see [SSH Over Tailscale For VPS](./ssh-over-tailscale-for-vps.md) to keep normal OpenSSH users and keys while removing public SSH exposure

## Official References

- [Tailscale Quickstart](https://tailscale.com/docs/how-to/quickstart)
- [tailscale up](https://tailscale.com/docs/reference/tailscale-cli/up)
- [tailscale serve](https://tailscale.com/docs/reference/tailscale-cli/serve)
- [Protect your SSH servers using Tailscale](https://tailscale.com/docs/reference/ssh-over-tailscale)
