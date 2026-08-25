# MCPs for omp

[omp](https://omp.sh/) supports external Model Context Protocol (MCP) servers
using omp's native MCP configuration and discovery rules.

## Configuration scopes

Use an omp-managed file for configuration owned by omp:

| Scope | File | Use it for |
| --- | --- | --- |
| Project | `.omp/mcp.json` | Servers shared by everyone working in a repository. |
| User | `~/.omp/agent/mcp.json` | Personal servers in the default profile. |
| Named profile | `~/.omp/profiles/<name>/agent/mcp.json` | Servers isolated to `omp --profile <name>`. |

For a personal setup, use the user file:

```text
~/.omp/agent/mcp.json
```

Project discovery is enabled by default. `mcp.json` and `.mcp.json` at the
project root are portable, lower-priority fallbacks for sharing a definition
with other MCP clients. Omp also imports supported definitions from other
clients; use `/mcp list` to see each server's source file. Duplicate server
names are not merged: the first definition found wins.

## Current integrations

| Integration | Omp transport | Use it for |
| --- | --- | --- |
| [Context7](https://github.com/upstash/context7) | Streamable HTTP | Current, version-specific library documentation. |
| [GitHub MCP Server](https://github.com/github/github-mcp-server) | Remote HTTP | Read-only repository, issue, and pull-request lookups. |
| [Playwright MCP](https://github.com/microsoft/playwright-mcp) | Local stdio | Browser automation and inspection. |

## Combined user configuration

Add the following to `~/.omp/agent/mcp.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json",
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "X-MCP-Toolsets": "repos,issues,pull_requests",
        "X-MCP-Readonly": "true"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

If the file already contains other servers, merge these entries into its
existing `mcpServers` object. Keep unrelated settings and server definitions.

### Context7 authentication

The hosted Context7 server works without a key at its anonymous rate limit. For
higher limits, add the `headers` object below to the `context7` entry and set
`CONTEXT7_API_KEY` before starting omp:

```json
{
  "type": "http",
  "url": "https://mcp.context7.com/mcp",
  "headers": {
    "Authorization": "Bearer ${CONTEXT7_API_KEY}"
  }
}
```

Context7 also supports OAuth. Change the URL to
`https://mcp.context7.com/mcp/oauth`, then run `/mcp reauth context7` inside
omp. Never put a literal API key in an omp configuration file.

### GitHub authentication and permissions

The remote GitHub server uses OAuth. Run `/mcp reauth github` inside omp when
it needs authorization. The configuration enables only the `repos`, `issues`,
and `pull_requests` toolsets and sets the remote server's read-only mode. The
read-only header limits the server's tools; it is not an authentication or
sandbox boundary.

### Playwright

The Playwright entry uses omp's default stdio transport. `npx` downloads the
official `@playwright/mcp` package when the server is first connected. Review
the package and remember that it runs with the permissions of the user who
starts omp.

## Apply and verify

After creating or editing an omp-managed MCP file, reload discovery and inspect
the result:

```text
/mcp reload
/mcp list
```

Test each server explicitly:

```text
/mcp test context7
/mcp test github
/mcp test playwright
```

For a remote server that uses OAuth, run `/mcp reauth <name>` before testing it.
`/tools` shows the MCP tools currently visible to omp; their names use the
`mcp__<server>_<tool>` form after normalization.

## Safety

- Treat every MCP definition as executable, trusted configuration. A local
  stdio server runs its command with your user permissions.
- Review project MCP files before opening an unfamiliar repository.
- Keep API keys and client secrets in environment variables or use managed
  OAuth; do not commit them to project configuration.
- Grant the smallest useful toolsets, filesystem roots, OAuth scopes, and API
  permissions.
- A remote server receives the arguments and data needed for each requested
  operation. Use only endpoints and packages you trust.

## References

- [omp MCP documentation](https://github.com/can1357/oh-my-pi/blob/main/docs/mcp-config.md)
- [Context7 MCP clients](https://context7.com/docs/resources/all-clients)
- [GitHub remote MCP server](https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp)
