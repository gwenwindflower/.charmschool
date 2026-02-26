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
- **Body optional** but encouraged for the following:
  - explaining reasoning for making a change (e.g., 'we want to be able to do X, and this change is necessary to enable that')
  - explaining why a specific solution was chosen when there are multiple valid approaches (e.g., 'we tried X and Y, both worked, but X is far more readable and we decided to prioritize long-term maintainability over short-term performance')
  - justifying a non-standard pattern or hack (e.g. 'the blessed way of doing X is A, but we can't do this for Y reason, so we are doing B instead')
  - surprising findings from implementation (e.g. 'we though X would work better, but Y, while being much simpler, is also more effective')
  - specific and unusual learnings from research and experimentation (e.g., 'we could not figure out why X was happening, but eventually tracked it down to GH user/repo/issues/72, which revealed the root cause was Y, so the solution was Z')
  - documenting a goal for (e.g., we expect feature X to increase user signups by 10%)
