# CLAUDE.md Refactoring Checklist

Detailed guidance for restructuring bloated CLAUDE.md files.

## Phase 1: Analyze

Before making changes, understand current state:

- [ ] Count total lines (target: root under 50 lines)
- [ ] Identify contradictory instructions
- [ ] Condense duplicate content (also in README, docs, etc.)
- [ ] Mark vague/unactionable items for removal
- [ ] List topics that could be separate rules at project or user level

## Phase 2: Identify Root-Only Content

These belong in the root CLAUDE.md:

- Project identity (1-2 sentences)
- Critical build/test/lint commands
- Hard overrides ("always X", "never Y")
- Safety warnings
- Links to modular rule files

## Phase 3: Categorize Remaining Content

Common categories for `.claude/rules/`:

| Category | Examples |
| --- | --- |
| `code-style.md` | Formatting, naming conventions |
| `testing.md` | Test patterns, coverage requirements |
| `typescript.md` | TS-specific conventions |
| `api.md` | Endpoint design, error handling |
| `git.md` | Commit style, branch naming, PR process |
| `architecture.md` | Module boundaries, dependencies |
| `security.md` | Auth patterns, data handling |
| `frontend/*.md` | React, styles, components |
| `backend/*.md` | Database, services, middleware |

## Phase 4: Create Modular Structure

```text
.claude/
├── CLAUDE.md              # Minimal: identity + commands + critical overrides
└── rules/
    ├── code-style.md
    ├── testing.md
    └── [topic].md
```

Each rule file should:

- Cover one focused topic
- Be self-contained (reader shouldn't need other files)
- Use path-scoping if only relevant to certain files
- Start with a brief purpose statement

## Phase 5: Prune

Remove these patterns:

**Vague directives:**

- "Write clean code"
- "Follow best practices"
- "Keep it simple"
- "Make it readable"

**Claude's existing knowledge:**

- Generic language idioms
- Standard library usage
- Common framework patterns
- Basic git operations

**Outdated references:**

- Deprecated APIs/tools
- Removed features
- Old team members' preferences

**Redundant with codebase:**

- Patterns obvious from existing code
- Conventions inferable from linter configs
- Structure visible in file organization

## Verification

After restructuring:

- [ ] Root CLAUDE.md under 50 lines
- [ ] All rule file links resolve
- [ ] No contradictions between files
- [ ] Each instruction is specific and actionable
- [ ] No orphaned references to moved content
- [ ] Test with `/memory` command to verify loading

## Example: Before/After

### Before (bloated root)

```markdown
# My Project

This is a TypeScript project using React and Node.

## Commands
- Build: npm run build
- Test: npm test

## Code Style
Use 2 spaces. Use camelCase. Don't use var.
Always add JSDoc comments. Keep functions small.
Write clean code. Follow best practices.

## Testing
Use Jest. Write unit tests. Test edge cases.
Mock external services. Use test-driven development.

## API Design
Use REST conventions. Validate inputs.
Return proper status codes. Handle errors gracefully.

## Git
Use conventional commits. Keep commits atomic.
Write good commit messages.

[... 150 more lines ...]
```

### After (modular)

**Root CLAUDE.md:**

```markdown
# My Project

TypeScript monorepo: React frontend + Node API.

## Commands
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

## Critical
- Never commit to main directly
- All PRs require passing CI
```

**.claude/rules/typescript.md:**

```markdown
# TypeScript Conventions

- 2-space indentation (enforced by Prettier)
- Prefer `const` over `let`, never `var`
- Use explicit return types on exported functions
- Avoid `any`; use `unknown` and narrow
```

**.claude/rules/testing.md:**

```markdown
---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
---

# Testing Patterns

- One assertion concept per test
- Mock external services with MSW
- Use factories for test data (see `tests/factories/`)
- Minimum 80% coverage on new code
```
