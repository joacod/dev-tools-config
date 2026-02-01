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

Clone a repo:

```sh
gh repo clone OWNER/REPO
```

Create a pull request:

```sh
gh pr create
```

View a pull request:

```sh
gh pr view --web
```

List issues:

```sh
gh issue list
```

Create a release:

```sh
gh release create v1.0.0
```
