# Git Commits

Conventional commit style with scope preferences.

## Format

```text
type(scope): brief description in imperative mood

Optional body with rationale and context. Feel free to be detailed here.

[Co-author tag for Claude Code commits]
```

## Types

- `feat` - New functionality
- `fix` - Bug fixes
- `chore` - Maintenance, config changes
- `docs` - Documentation only
- `refactor` - Code restructuring without behavior change

### Type details

- `feat`: Wholly new functionality (new tool, new function, new feature)
- `chore`: Updates to existing configs, non-functional changes
- `fix`: Bug fixes, corrections to broken behavior

## Style

- **Imperative mood:** "add feature" not "added feature"
- **No period** at end of subject line
- **Max 72 chars** for subject
- **Body optional** but encouraged for non-trivial changes
- **Always include** co-author tag when Claude Code makes the commit
