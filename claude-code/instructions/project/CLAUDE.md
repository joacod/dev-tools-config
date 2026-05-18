# Project Claude Code Instructions

Template note: this file is a reusable template. It becomes active project guidance only after it is copied to a project root as `CLAUDE.md` and filled in.

Use this file at the root of a project that needs Claude Code to apply project-specific context and constraints.

## Project Context

Project: [project name]
Goal: [specific outcome]
Audience: [who uses this project]

What to avoid:

- [frameworks, patterns, services, or approaches to avoid]

## Stack

Language: [TypeScript / Go / Python / etc.]
Framework: [Next.js / React / Node / etc.]
Package manager: [pnpm / npm / yarn / bun]
Database: [PostgreSQL / MongoDB / SQLite / none]
Testing: [Vitest / Jest / Playwright / pytest / none]
Styling: [Tailwind CSS / CSS Modules / plain CSS / none]

Use this stack by default. Do not suggest alternatives unless asked. If the defined stack seems wrong for a task, flag the concern before proceeding.

## Permanent Project Facts

- [architectural decision or constraint]
- [integration requirement]
- [business or product constraint]

Apply these facts in every session. If a task conflicts with one of them, flag the conflict before proceeding.

## Project Behavior

- Ask before assuming missing requirements.
- Use the simplest solution that fits the existing architecture.
- Do not touch unrelated code.
- Flag uncertainty explicitly.
- Preserve project style and conventions.
