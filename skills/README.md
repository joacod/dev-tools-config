# Agent Skills

[Agent skills](https://agentskills.io/) are reusable capabilities for AI coding agents. Use the [skills.sh](https://www.skills.sh/) directory and the `npx skills` CLI to discover, install, and update them consistently across supported agents such as OpenCode and Claude Code.

## Installation

Install a skill from its repository with:

```sh
npx skills add <repository> --skill <skill-name>
```

Run the command from a project directory for a project-level skill. Add `-g` to make the skill available globally:

```sh
npx skills add <repository> --skill <skill-name> -g
```

Update installed skills with:

```sh
npx skills update -g  # update global skills
npx skills update -p  # update project skills
```

Keep skills global when they describe a general workflow. Install technology-specific skills at project level so they only apply where that stack is used.

## Global Skills

These skills are installed globally and available across projects.

| Skill | Use it for | Link | Install |
| --- | --- | --- | --- |
| `find-skills` | Discovering and installing skills for a particular task or domain. | [skills.sh](https://www.skills.sh/vercel-labs/skills/find-skills) | `npx skills add https://github.com/vercel-labs/skills --skill find-skills -g` |
| `grill-me` | Stress-testing plans and designs through systematic questioning. | [skills.sh](https://www.skills.sh/mattpocock/skills/grill-me) | `npx skills add https://github.com/mattpocock/skills --skill grill-me -g` |
| `skill-creator` | Creating, testing, and iterating on agent skills. | [skills.sh](https://www.skills.sh/anthropics/skills/skill-creator) | `npx skills add https://github.com/anthropics/skills --skill skill-creator -g` |

## Personal Skills

My own skills, including experiments and reusable workflows, live in [`joacod/skills`](https://github.com/joacod/skills).

Install a selected skill at project level:

```sh
npx skills add https://github.com/joacod/skills --skill <skill-name>
```

Add `-g` when a personal skill should be available globally instead.

## Project-Level Examples

Install technology-specific skills only in projects where they are relevant. Run these commands from the project root.

### React and Next.js

[`vercel-react-best-practices`](https://www.skills.sh/vercel-labs/agent-skills/vercel-react-best-practices) provides Vercel's React and Next.js performance guidance.

```sh
npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices
```

Add other framework- or tool-specific skills to this section as they become part of the project setup.
