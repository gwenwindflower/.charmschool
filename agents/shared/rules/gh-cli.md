# GitHub CLI (gh)

Use `gh` for GitHub operations beyond standard git: repos, issues, PRs, and Actions.

## Safety Rules

- **Read before write.** Use `list`, `view`, `status`, `diff`, `checks` before any write op.
- **No destructive commands without explicit user instruction.** High-risk subcommands: `delete`, `close`, `merge`, `revert`, `archive`, `transfer`, `lock`, `release delete`.
- **Never print auth tokens.** Don't run `gh auth token` or log its output.

## Common Commands

```bash
# Auth
gh auth status

# Repos
gh repo view [-R OWNER/REPO]

# Issues
gh issue list [-R OWNER/REPO]
gh issue view <number>
gh issue develop <number>        # creates branch, easy path to PR
gh issue create

# PRs
gh pr list / view / diff / checks <number>
gh pr create [--title "..."] [--body "..."] [--fill-verbose]
gh pr comment <number> --body "..."
gh pr merge --squash             # prefer --squash; use --rebase for small clean histories

# Actions
gh workflow list / view / run <workflow>
gh run watch <run-id>
gh run rerun <run-id>
```

## For Everything Else

Run `gh <command> --help` for inline docs, or search the [gh manual](https://cli.github.com/manual/).
