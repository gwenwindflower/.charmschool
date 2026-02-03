---
name: claude-memory-files
description: |
  Write, create, and improve CLAUDE.md project memory files for Claude Code. Use when: (1) Creating or bootstrapping a new CLAUDE.md, (2) Improving, refactoring, or splitting a bloated CLAUDE.md, (3) Questions about CLAUDE.md structure, imports, or modular rules, (4) After significant codebase exploration—cache discoveries to avoid re-crawling.
---

# CLAUDE.md Authoring

Write effective project memory files that give Claude Code the context it needs without wasting tokens.

## Core Principles

**Be specific and actionable.** "Use 2-space indentation in TypeScript" beats "format code properly."

**Progressive disclosure.** Keep root CLAUDE.md minimal. Split detailed guidance into `.claude/rules/` files or use `@imports`.

**Challenge every line.** Claude is already smart—only add context it doesn't have. Ask: "Does this justify its token cost?"

**Avoid redundancy.** Don't repeat what's in README, package.json, or inferable from code.

**Living document.** After significant exploration, update with discoveries to prevent re-crawling.

## Degrees of Freedom

Match instruction specificity to the task's fragility:

- **High freedom** (guidance): Multiple valid approaches, context-dependent decisions
- **Medium freedom** (patterns): Preferred approach exists, some variation acceptable
- **Low freedom** (strict rules): Operations are fragile, consistency critical, specific sequence required

**When unsure, opt for lowest freedom.** Rules can be loosened later, but damage from under-specified guidance can't always be undone. Treat CLAUDE.md as a least-privilege system.

## File Locations

| Location | Purpose | Shared With |
| --- | --- | --- |
| `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team project instructions | Team (via git) |
| `./.claude/rules/*.md` | Modular topic rules | Team (via git) |
| `./CLAUDE.local.md` | Personal project prefs | Just you |
| `~/.claude/CLAUDE.md` | Personal global prefs | Just you (all projects) |
| `~/.claude/rules/*.md` | Personal global rules | Just you (all projects) |

## Creating a New CLAUDE.md

### Quick Start

Run `/init` in Claude Code to bootstrap, then refine.

### Essential Sections

A good CLAUDE.md typically includes:

```markdown
# Project Name

Brief context (1-2 sentences): what this is, primary language/framework.

## Before Starting Work

Before exploring the codebase via file reads or bash commands, ask the user for:
- Existing architecture diagrams or documentation
- File tree documentation or codebase maps
- Relevant context from previous sessions
- Links to design docs, ADRs, or wikis

This avoids redundant exploration. After any significant discovery, update this CLAUDE.md.

## Project Structure

[Key directories and their purposes - avoids repeated `find` and `ls` commands]

- `src/api/` - REST endpoints, organized by resource
- `src/services/` - Business logic, one service per domain
- `src/models/` - Database models (Prisma)
- `tests/` - Mirrors src/ structure

## Commands

- Build: `pnpm run build`
- Test: `pnpm run test`
- Lint: `pnpm run lint`

## Architecture

[Non-obvious patterns, key abstractions, data flow]

## Conventions

- [Specific, actionable rules]
- [Things Claude wouldn't know from reading code]
```

### What to Include

- **Before Starting Work section** - instruct agent to ask for existing context before exploring
- **Project structure map** - key directories and purposes (avoids repeated file tree crawling)
- **Frequent commands** - build, test, lint, deploy (avoid repeated discovery)
- **Architecture overview** - key patterns, data flow, module boundaries
- **Non-obvious conventions** - naming patterns, file organization choices, commit style
- **Critical warnings** - "never modify X directly", "requires Y before Z"

### What to Exclude

- **Claude's existing knowledge**: Generic language idioms, standard library usage, common patterns
- **Redundant content**: Already in README.md, package.json, or inferable from code
- **Vague directives**: "Write clean code", "follow best practices", "be thorough"

## The Living Document Workflow

**Ideal workflow after significant work:**

1. Request comes in
2. Read files, explore codebase, do the work
3. Before ending session: update CLAUDE.md with what was learned or changed

**What to capture after exploration:**

- Directory structures discovered (so future sessions don't re-crawl)
- Key files and their purposes
- Patterns identified in the codebase
- Gotchas or non-obvious behaviors
- New conventions established during the work

**Example update after exploration:**

```markdown
## Project Structure (updated 2024-01)

After exploring the codebase:

- `src/handlers/` - Lambda handlers, one per API route
- `src/lib/` - Shared utilities
  - `src/lib/db.ts` - Database connection singleton
  - `src/lib/auth.ts` - JWT validation middleware
- `infrastructure/` - CDK stacks (not Terraform as README suggests)
```

**Trigger phrases for updating CLAUDE.md:**

- "Let me update CLAUDE.md with what we learned"
- "I should document this discovery"
- "Future sessions will benefit from knowing..."

## Using Imports

Import files with `@path/to/file` syntax:

```markdown
See @README.md for project overview.
Standard commands in @package.json.

## Team Conventions
- Git workflow: @docs/git-workflow.md
- API patterns: @docs/api-standards.md

## Individual Setup
@~/.claude/personal-prefs.md
```

Imports work recursively (max depth 5). Not evaluated inside code blocks.

## Modular Rules with .claude/rules/

For larger projects, split instructions by topic:

```text
.claude/
├── CLAUDE.md              # Minimal root
└── rules/
    ├── typescript.md      # Language conventions
    ├── testing.md         # Test patterns
    ├── api.md             # API design rules
    └── frontend/
        ├── react.md
        └── styles.md
```

### Path-Scoped Rules

Use YAML frontmatter to scope rules to specific files:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/services/**/*.ts"
---

# API Layer Rules

- All endpoints require input validation
- Use standard error response format from @docs/errors.md
```

Glob patterns: `**/*.ts`, `src/**/*`, `*.{ts,tsx}`, `{src,lib}/**/*.ts`

## Refactoring a Bloated CLAUDE.md

If CLAUDE.md exceeds ~50 lines, consider restructuring:

1. **Analyze**: Identify conflicting or redundant instructions
2. **Extract**: Keep only universal content in root (description, critical commands, overrides)
3. **Categorize**: Group remaining content by topic
4. **Split**: Move to `.claude/rules/` or imported files
5. **Prune**: Remove vague directives, defaults Claude already knows, outdated refs

See [refactoring checklist](./references/refactoring-checklist.md) for detailed guidance.

## Markdown Formatting

CLAUDE.md files should follow standard markdownlint rules. Detailed guidance is available in user-level rules (`~/.claude/rules/`):

- **Code blocks**: Always specify a language. Use `text` for file trees and non-code content.
- **Tables**: Use spaces around inner pipe edges (`| cell | cell |` not `|cell|cell|`).

## Quality Checklist

Before committing CLAUDE.md changes:

- [ ] Every instruction is specific and actionable
- [ ] No duplication with README or other docs
- [ ] Root file under 50 lines (for larger projects)
- [ ] No generic advice Claude already knows
- [ ] Commands are accurate and tested
- [ ] Path-scoped rules use correct glob patterns
- [ ] Imports resolve to existing files
- [ ] Recent explorations/discoveries have been captured
