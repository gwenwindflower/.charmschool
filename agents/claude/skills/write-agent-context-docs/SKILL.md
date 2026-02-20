---
name: agent-context-docs
description: |
  Write, create, and improve AGENTS.md project memory files for coding agents. Use when: (1) Creating or bootstrapping a new AGENTS.md, (2) Improving or refactoring an AGENTS.md towards best practices, (3) Questions about AGENTS.md best practices, (4) After significant codebase exploration to cache valuable learning for the future.
---

# AGENTS.md Authoring

Write effective project memory files that give coding agents the context it needs without wasting tokens.

> [!IMPORTANT]
> Some notes on naming. Claude Code uses proprietary file and directory names, and many agents default to having their configs stored in a `.<tool>/` directory which contains both tracked configs and expansions, as well as private local overrides. For the sake of uniformity, we use the names `AGENTS.md` and `.agents/` to refer to automatically loaded context files and agent config directories, respectively. So, Claude Code, for example, you should assume everywhere that mentions `AGENTS.md` also applies to `CLAUDE.md` (or `GEMINI.md`, etc.), and guidance on anything in `.agents/` would also apply to `.claude/` (or `.codex/`, `.opencode/`, etc.) and so on. If something is not working as expected, check the agent's documentation to be sure, as these tools are evolving rapidly. If anything in this Agent Skill falls out of date, recommend updating it.

## Core Principles

**Be specific and actionable.** "Use 2-space indentation in TypeScript" beats "format code properly."

**Progressive disclosure.** Keep root AGENTS.md minimal. Split detailed guidance into subdirectory-scoped files (e.g., `src/nextjs/AGENTS.md` for context that loads when working on an app's frontend), or create a simple index list of context docs in a standard location (e.g., `docs/`) that can be loaded on demand. Pay attention to which patterns create modularity for the sake of maintainability vs. the more effective modularity of progressive disclosure.

**Challenge every line.** Agents are already smart! Only add context they don't have. Always ask: "Does this justify its token cost?"

**Avoid redundancy.** Don't repeat what's in README, package.json, or inferable from code.

**Living document.** After significant exploration, update with discoveries to prevent re-crawling.

## Creating a New AGENTS.md

A good AGENTS.md typically includes:

```markdown
# Project Name

Brief context (1-2 sentences): what this is, primary language/framework.

Goals and priorities: what does success look like?

> [!IMPORTANT]
> Callouts on critical context that apply to the rest of the document should be flagged early with emphasis

## Project Structure

[Key directories and their purposes - avoids repeated `find`, `tree`, and `ls` commands. This is crucial, always provide a thorough map of the structure, it's extremely high value per token.]

- `src/api/` - REST endpoints, organized by resource
- `src/services/` - Business logic, one service per domain
- `src/models/` - Database models (Prisma)
- `src/handlers/` - Lambda handlers, one per API route
- `src/lib/` - Shared utilities
  - `src/lib/db.ts` - Database connection singleton
  - `src/lib/auth.ts` - JWT validation middleware
- `infrastructure/` - CDK stacks (not Terraform as README suggests)
- `tests/` - Mirrors src/ structure

## Key Commands

- Build: `pnpm run build`
- Test: `pnpm run test`
- Lint: `pnpm run lint`

## Architecture

[Non-obvious patterns, key abstractions, data flow, infrastructure diagrams]

## Conventions

- [Specific, actionable rules]
- [Non-standard style or conventions (e.g., use lowercase SQL keywords)]
- [Things Claude wouldn't know from reading code]
```

### What to Exclude

- **Claude's existing knowledge**: Generic language idioms, standard library usage, common patterns
- **Redundant content**: Already in README.md, package.json, or inferable from code
- **Vague directives**: "Write clean code", "follow best practices", "be thorough"

## Index Pattern for Progressive Disclosure

> [!IMPORTANT]
> This pattern is the best practice for progressive disclosure. It maximizes context effectiveness and efficiency. Barring circumstances that suggest other ways of structuring context, this is the one you should follow.

This pattern is based around a standard directory for modular docs. You should establish if one already exists, if not use the common standard `.docs/`. Create modular context files within the `.docs/` directory with _descriptive names_ (not AGENTS.md, more like adding-new-shadcn-ui-components.md), and continuing adding and maintaining these as they come up. Particularly, if you've absorbed documentation on a tool during a session, and how it relates to the project, you should create some modular `.docs/` files to preserve this for future sessions.

The other piece of this pattern is the index list. This is a tight table of contents in AGENTS.md that lays out everything in the `.docs/` directory, if necessary with some added context on when to access them (this can be avoided with good descriptive file names). It's important here to **not** use the @reference import syntax you'll see later, which would break the progressive disclosure pattern. A simple path to the file with context allows the agent to choose when to load each file based on the task at hand, while keeping the AGENTS.md organized and concise.

Here's an example of an AGENTS.md using the index pattern for progressive disclosure:

```text
# Shopping App Agent Guidance

**IMPORTANT**: Prefer retrieval-led reasoning over pre-training-led reasoning

.docs/adding-new-shadcn-ui-components.md
.docs/using-drizzle-orm-with-supabase.md
.docs/adding-new-endpoints-to-v2-api.md
```

You are smart! It's better to give you a map of what's available and let you decide what to load.

This approach lets you decide when you need to load specific modules of context, based on the task at hand, preserving your context window and focus.

### Using the Index Pattern in Subdirectories

When there are obvious splits like frontend/backend or api/services/workers, etc., you should create subdirectory-scoped versions of this index structure. This will keep the indexes and available `.docs/` leaner and more relevant to each given area.

For example:

```text
src/frontend/AGENTS.md
src/frontend/.docs/adding-new-shadcn-ui-components.md
src/backend/AGENTS.md
src/backend/.docs/using-drizzle-orm-with-supabase.md
```

You will never need to know Drizzle details while working on the UX, or how to add a shadcn component while working on database models, which means you're more likely to load the right context at the right time, without the pre-loading forced by `rules/` directories or @reference file imports.

## The Living Document Workflow

**Ideal workflow after significant work:**

1. Request comes in
2. Read files, explore codebase, do the work
3. Before ending session: update AGENTS.md to reflect current state and understanding
    - Directory structures discovered, added, or modified (so future sessions don't need to re-crawl your work)
    - New patterns established or discovered
    - Key design decisions made
    - Unique implementation details
    - Decide where the additions should live:
      - Project-level and universally relevant (e.g., updated file tree, new Railway deploy commands)? Root AGENTS.md
      - Specific to one area of the project? Add modular file(s) to `.docs/` and corresponding new items in the matching index list -- this could be the project root or a subdirectory

## Patterns to Avoid

There are use cases for these patterns, but most of the time they are less effective than the index pattern for progressive disclosure. They are prevalent in a lot of legacy documentation, and there is a great deal of confusion around them, so we cover them here in case you encounter them. The major weakness through all of them is appearing modular without providing real progressive disclosure.

This leads developers and agents to dump tons of modular files into a pattern like the `rules/` directory, blowing up the context window at session start with irrelevant content, and defeating the purpose of modularity for maintainability and organization.

Similarly, developers will add a bunch of reference files with @reference import syntax, without realizing that this loads the entire file immediately. It is essentially equivalent to including the referenced file's content directly in AGENTS.md, just with more files to track and less clarity on what is loaded.

### Imports

Most agents at this point let you import or reference files with `@path/to/file` syntax. Different agents handle this differently, but most will load an @referenced file's contents directly upon encountering. As such, be judicious and assume @references are full loads, and any modularity they provide is for maintainability and organization only, as opposed to progressive disclosure.

Import (full loading) example:

```markdown
See @README.md for project overview.
Standard commands in @package.json.

## Team Conventions

- Git workflow: @docs/git-workflow.md
- API patterns: @docs/api-standards.md

## Individual Setup

@~/.agents/personal-prefs.md
```

In some agents (Claude Code for sure), imports work recursively (max depth=5). They are generally ignored inside code blocks. This creates even more risk of accidentally bloating context with large imports, as an imported file that itself contains imports will also be fully loaded, and so on.

Try to avoid them unless absolutely necessary, and be sure to follow the full chain of any recursive imports if you do add one, to make sure you're not blowing up the context window accidentally.

## Rules (varies by agent)

This presents similar to the `.docs/` concept, putting modular files in a specific directory. The difference is when using the agents' configured 'rules' directory, all the files will be loaded at session start. It's as if the entire index pattern's index list was @references importing files instead of a simple list of paths.

For very large projects, perhaps some big production monorepos, it could help split up a huge AGENTS.md that is genuinely necessary to cover all the critical context across the project, but this is uncommon.

Support and configuration for a 'rules'-style concept varies. For example, Claude Code supports rules at the user level (`~/.claude/rules/`), or project level (`.claude/rules/`) and will load all of these files hierarchically on session start.

Example 'rules' structure (**note:** the AGENTS.md does not contain an index list, the content of all the rules is automatically loaded):

```text
.claude/
├── AGENTS.md              # Minimal root
└── rules/
    ├── typescript.md      # Language conventions
    ├── testing.md         # Test patterns
    ├── api.md             # API design rules
    └── frontend/
        ├── react.md
        └── styles.md
```

You should only follow this pattern if the user requests it, or if it's already present and recommended in the codebase.

### Path-Scoped Rules

Path scoping rules, if supported, are what we might call a _conditional_ disclosure system. Rather than agent-driven decisions to load progressively more detail, they are automatically loaded when working in certain paths. For agents that support this (Claude Code, for one), you can use YAML frontmatter to set the path scopes:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/services/**/*.ts"
---
# API Layer Rules

- All endpoints require input validation
- Use standard error response format from @.claude/rules/errors.md
```

Glob patterns: `**/*.ts`, `src/**/*`, `*.{ts,tsx}`, `{src,lib}/**/*.ts`

This is an improvement over global project rules, but still not as effective as giving the agent a map of available context docs and letting them choose what they need dynamically.

## Refactoring Long or Badly Structured AGENTS.md

If the user requests improvement of an existing AGENTS.md, or you are editing an AGENTS.md that has stretched past ~60 lines, you should refactor with the following process:

1. **Analyze**: Ruthlessly eliminate conflicting or redundant instructions until you have a clear base of context and rules worth keeping
2. **Categorize**: Logically group remaining content by function, topic, path, and/or any other sensible divisions
3. **Split and Index**: Create descriptively-named, modular files in a `.docs/` directory (in the project root or a functional subdirectory) with an index list in the AGENTS.md at the same level pointing to each modular doc
4. **Distill**: Outside of the index, keep only content universally applicable to the corresponding domain (i.e. project root or functional subdirectory) in the AGENTS.md -- justify each line outside of the index with the question: "Does every agent who works in this directory or below need this context in every session?"

## File Locations for Reference

These are the locations of the most common context files, assuming project root as cwd:

| Location | Purpose | Shared With | Loaded When |
| --- | --- | --- |
| `AGENTS.md` or `.agents/AGENTS.md` | Team project instructions | Team (in repo, tracked) | Session start, always |
| `.agents/rules/*.md` | Modular topic rules | Team (in repo, tracked) | Session start, always |
| `./AGENTS.local.md` | Personal project overrides | User (in repo, not tracked) | Session start, always |
|| `~/.agents/AGENTS.md` | Primary user-level guidance | User (all projects) | Session start, always |
|| `~/.agents/*` | Varying modular user-level guidance (tool-dependent) | User (all projects) | Session start, always |

## Markdown Formatting

AGENTS.md files should follow standard markdownlint rules. Detailed guidance is available in user-level rules (`~/.claude/rules/`):

- **Code blocks**: Always specify a language. Use `text` for file trees and non-code content.
- **Tables**: Use spaces around inner pipe edges (`| cell | cell |` not `|cell|cell|`).

## MCP Tool references

If the Skill uses MCP (Model Context Protocol) tools, always use fully qualified tool names to avoid "tool not found" errors.

Correct format: `ServerName:tool_name`

**Example**:

```text
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.
```

**Where**:

- BigQuery and GitHub are installed and available MCP server names
- bigquery_schema and create_issue are, respectively, the tool names within those servers

Without the server prefix, Claude may fail to locate the tool, especially when many MCP servers are available.

## Quality Checklist

Before committing AGENTS.md changes:

- [ ] Every instruction is specific and actionable
- [ ] No duplication with README or other docs
- [ ] Root file is minimal outside of the index listing modular docs paths
- [ ] No generic advice Claude already knows
- [ ] Recent work (including exploration and fetching docs from the web) has been synthesized and captured
