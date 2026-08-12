# NVM and Node.js

Install [nvm](https://github.com/nvm-sh/nvm) and use it to manage a Node.js LTS version.

## What This Setup Does

This guide installs `nvm`, loads it in your shell, and uses it to install the latest Node.js LTS release.

- **`nvm` manages Node.js versions:** switch versions without installing Node.js globally
- **Shell startup loads `nvm`:** the `nvm` command is available in new terminal sessions
- **Node.js LTS is installed through `nvm`:** use the current long-term support release
- **Verification is included:** confirm `nvm`, `node`, and `npm` all work

**Result:** you get a simple Node.js setup that follows the recommended `nvm` install flow.

## Install NVM

Download and run the official installer.

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
```

## Load NVM In Your Shell

After the installer finishes, follow the recommended step shown in the terminal so your shell can load `nvm`.

Add the following lines to your shell config file if the installer tells you to do so.

For `zsh`, that is usually `~/.zshrc`.

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

If your shell config already exists, add these lines to the file instead of replacing the file contents.

Reload your shell.

```sh
exec zsh
```

If you use `bash` instead, reload with:

```sh
exec bash
```

## Verify NVM

Check that `nvm` is available.

```sh
nvm --version
```

If that command prints a version, `nvm` is installed correctly and your shell is loading it.

## Install Node.js LTS

Install the latest Node.js LTS version.

```sh
nvm install --lts
```

To migrate and reinstall the global packages from an existing Node.js version, include that version in the install command:

```sh
nvm install --lts --reinstall-packages-from=<current-version>
```

For example:

```sh
nvm install --lts --reinstall-packages-from=v22.18.0
```

This migrates and reinstalls all global packages from the previous version so they keep working as expected.

## Activate The Default Node.js Version

Finally, activate the default Node.js version:

```sh
nvm use default
```

This updates only the current terminal. Run it once in each already-open terminal or Herdr pane. New terminals and new Herdr panes automatically use the configured default Node.js version.

## Verify Node.js And npm

Check that both commands work.

```sh
node --version
npm --version
```

If both commands print versions, the setup is ready.
