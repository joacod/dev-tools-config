# Ghostty

Configuration and notes on [Ghostty](https://ghostty.org/) terminal.

## General configuration

Paste the content of `config` into Ghostty settings.

## Font

Install **JetBrains Mono Nerd Font**

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

## Auto-suggestions

**ZSH Auto-suggestions**. This plugin remembers your history and suggests commands as you type. [Documentation](https://github.com/zsh-users/zsh-autosuggestions)

```sh
brew install zsh-autosuggestions
```

Add this line to your `~/.zshrc` file:

```sh
# ZSH Auto-suggestions. This plugin remembers your history and suggests commands as you type
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

Restart your terminal or run `exec zsh`

## Shell prompt

**Starship**. A minimal, blazing-fast, and infinitely customizable prompt for any shell. [Documentation](https://starship.rs)

```sh
brew install starship
```

Add this line to your `~/.zshrc` file:

```sh
# Starship. Terminal Shell Prompt
eval "$(starship init zsh)"
```

Restart your terminal or run `exec zsh`

### Preset

Configure **Tokyo Night** preset

```sh
starship preset tokyo-night -o ~/.config/starship.toml
```

## Keybindings

Default Ghostty keybindings on macOS.

### Splits

| Action | Keybinding |
| --- | --- |
| Split vertically, creating a new pane to the right | `Cmd + D` |
| Split horizontally, creating a new pane below | `Cmd + Shift + D` |
| Close the current split or pane | `Cmd + W` |

### Move between split panes

| Action | Keybinding |
| --- | --- |
| Previous split pane | `Cmd + [` |
| Next split pane | `Cmd + ]` |
| Split pane above | `Cmd + Option + Up` |
| Split pane below | `Cmd + Option + Down` |
| Split pane left | `Cmd + Option + Left` |
| Split pane right | `Cmd + Option + Right` |

### Tabs

| Action | Keybinding |
| --- | --- |
| New tab | `Cmd + T` |
| Previous tab | `Cmd + Shift + [` |
| Next tab | `Cmd + Shift + ]` |
| Previous tab also works with | `Ctrl + Shift + Tab` |
| Next tab also works with | `Ctrl + Tab` |
| Go to tab `1` through `8` | `Cmd + 1` to `Cmd + 8` |
| Go to the last tab | `Cmd + 9` |
