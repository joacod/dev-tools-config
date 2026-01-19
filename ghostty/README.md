# Ghostty

Configuration and notes on [Ghostty](https://ghostty.org/) terminal.

## General Configuration

Paste the content of `config` on this folder into Ghostty settings.

## Font

Install **JetBrains Mono Nerd Font**

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

## Auto-Suggestions

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

## Shell Prompt

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
