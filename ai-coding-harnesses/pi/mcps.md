# MCPs for Pi

This page tracks the MCP integrations and Pi packages we like to use. Pi does
not include MCP support in its core; [`pi-mcp-adapter`](https://github.com/nicobailon/pi-mcp-adapter)
provides the MCP server integration. Context7 is installed here as a Pi
package, while GitHub and Playwright are MCP servers.

The paths below use Pi's default global directory. If `PI_CODING_AGENT_DIR` is
set, use that directory instead of `~/.pi/agent`.

## Current integrations

| Integration | Type | Global configuration | Use it for |
| --- | --- | --- | --- |
| [Context7](https://github.com/upstash/context7) | Pi package | `~/.pi/agent/settings.json` | Current, version-specific library documentation. |
| [GitHub MCP Server](https://github.com/github/github-mcp-server) | Remote MCP server | `~/.pi/agent/mcp.json` | Read-only repository, issue, and pull-request lookups. |
| [Playwright MCP](https://github.com/microsoft/playwright-mcp) | Stdio MCP server | `~/.pi/agent/mcp.json` | Browser automation and inspection. See the [setup guide](./mcp-playwright.md). |

## Context7

Install the official Pi package globally:

```bash
pi install npm:@upstash/context7-pi@0.1.2
```

It adds:

- `resolve-library-id` — find the Context7 library ID for a package or product.
- `query-docs` — retrieve current documentation and examples.
- `context7-docs` — a skill that recommends Context7 for documentation questions.
- `/c7-docs <library> <question>` — run a manual lookup from Pi.

The package works at IP-based rate limits without configuration. Set
`CONTEXT7_API_KEY` in the shell environment for higher quotas; never put the
key in a repository or MCP configuration file.

## GitHub

The current global setup uses GitHub's remote MCP endpoint with the repository,
issue, and pull-request toolsets enabled in read-only mode:

```json
{
  "mcpServers": {
    "github": {
      "url": "https://api.githubcopilot.com/mcp/",
      "protocolVersion": "auto",
      "headers": {
        "X-MCP-Toolsets": "repos,issues,pull_requests",
        "X-MCP-Readonly": "true"
      }
    }
  }
}
```

The real configuration may also contain authentication details. Keep those
private and follow the [official remote-server documentation](https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md)
for authentication and available toolsets. Keep read-only mode enabled unless
write access is intentionally required.

## Managing the global setup

- Use `pi list` to review globally installed Pi packages.
- Use `/mcp` to inspect configured MCP servers and `/mcp reconnect <server>`
  after changing one.
- Restart Pi after installing a package or changing integrations that load at
  startup.
- Keep project-specific servers in a project `.mcp.json` instead of exposing
  them globally when possible.
- Never commit `~/.pi/agent/settings.json` or `~/.pi/agent/mcp.json`; they may
  contain credentials or machine-specific configuration.

When adding a favorite, record its source, type, scope, purpose, authentication
requirements, and permission/toolset restrictions here. Put detailed setup or
troubleshooting instructions in a separate linked guide when the entry grows
beyond a short reference.
