# GitHub CLI

[GitHub CLI](https://cli.github.com/) brings GitHub workflows to your terminal.

## Install

```sh
brew install gh
```

## Authentication

```sh
gh auth login
gh auth status
```

## Common Commands

| Task | Command |
| --- | --- |
| Clone a repo | `gh repo clone OWNER/REPO` |
| Create a pull request | `gh pr create` |
| View a pull request | `gh pr view --web` |
| List issues | `gh issue list` |
| Create a release | `gh release create v1.0.0` |
