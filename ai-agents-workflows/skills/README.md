# Agent skills

Agent skills are reusable capabilities for AI coding agents. Use the [skills.sh](https://www.skills.sh/) directory and the `npx skills` CLI to discover, install, and update them consistently across supported agents such as OpenCode and Claude Code.

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

## Global skills

These skills are installed globally and available across projects.

| Skill | Use it for | Install |
| --- | --- | --- |
| [`find-skills`](https://www.skills.sh/vercel-labs/skills/find-skills) | Discovering and installing skills for a particular task or domain. | `npx skills add https://github.com/vercel-labs/skills --skill find-skills -g` |
| [`grill-me`](https://www.skills.sh/mattpocock/skills/grill-me) | Stress-testing plans and designs through systematic questioning. | `npx skills add https://github.com/mattpocock/skills --skill grill-me -g` |
| [`skill-creator`](https://www.skills.sh/anthropics/skills/skill-creator) | Creating, testing, and iterating on agent skills. | `npx skills add https://github.com/anthropics/skills --skill skill-creator -g` |

## Project-level skills

Install technology-specific skills only in projects where they are relevant. Run these commands from the project root.

| Skill | Use it for | Install |
| --- | --- | --- |
| [`vercel-react-best-practices`](https://www.skills.sh/vercel-labs/agent-skills/vercel-react-best-practices) | React and Next.js performance guidance from Vercel. | `npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices` |

## Personal skills

My own skills, including experiments and reusable workflows, live in [`joacod/skills`](https://github.com/joacod/skills) and are indexed on [skills.sh](https://www.skills.sh/joacod/skills).

Install a selected skill at project level:

```sh
npx skills add https://github.com/joacod/skills --skill <skill-name>
```

Add `-g` when a personal skill should be available globally instead.
