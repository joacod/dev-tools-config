# Socket Firewall

Install [Socket Firewall](https://github.com/SocketDev/sfw-free) and use it to protect dependency installs.

## What This Setup Does

This guide installs `sfw`, clears local package manager caches, and runs dependency installs through Socket Firewall.

- **`sfw` wraps package manager commands:** run installs through Socket Firewall
- **Malicious dependencies are blocked before install:** including known malicious transitive dependencies
- **pnpm is supported:** use it with existing `pnpm` projects
- **Bun is not guaranteed:** it may work, but it is not listed as officially supported in Socket Firewall Free

**Result:** you get a simple dependency install flow with an extra security layer.

## Install Socket Firewall

Install `sfw` globally.

```sh
npm i -g sfw
```

## Verify Socket Firewall

Check that sfw is available.

```sh
sfw --help
```

If that command prints the help output, Socket Firewall is installed correctly.

## Clear Package Manager Cache

Socket Firewall works by blocking package artifact network requests.

If dependencies are already cached locally, there may be no network request to block, so clear the cache before using it.

For npm:

```sh
npm cache clean --force
```

For pnpm:

```sh
pnpm store prune
```

## Use With npm

Run installs through sfw.

```sh
sfw npm install
```

For clean installs:

```sh
sfw npm ci
```

## Use With pnpm

Run installs through sfw.

```sh
sfw pnpm install
```

For CI or lockfile-based installs:

```sh
sfw pnpm install --frozen-lockfile
```

## Use With Bun

Bun is not listed as an officially supported package manager for Socket Firewall Free.

You can try:

```sh
sfw bun install
```

But do not rely on it as the only protection in CI until official support is confirmed.

## Add npm Scripts

For a JavaScript or TypeScript project, add scripts to package.json.

```json
{
  "scripts": {
    "safe:install": "sfw pnpm install",
    "safe:ci": "sfw pnpm install --frozen-lockfile"
  }
}
```

Run:

```sh
npm run safe:install
```
