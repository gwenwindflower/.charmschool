---
name: gh-cli-use
description: |
  Safely use the GitHub CLI (gh) working with GitHub repos beyond standard git operations: creating, forking, or cloning new remote repos, triggering and monitoring GitHub Actions, or working with Issues and Pull Requests.
---

# gh CLI Usage

## Safety Rules

- **Read before write.** Use `list`, `view`, `status`, `diff`, `checks` before any write operation.
- **Scope every command.** Use `-R OWNER/REPO` unless clearly inside the target project directory.
- **No destructive commands without explicit user instruction.** Destructive/high-risk subcommands: `delete`, `close`, `merge`, `revert`, `archive`, `unarchive`, `transfer`, `lock/unlock`, `release delete`, `cache delete`, `run delete`.
- **Protect secrets.** Never log tokens or print `gh auth token` output.

For commands not covered below, consult the [gh CLI reference map](./references/gh-cli-guide.md).

## Common Start-up Errors

**When:** switching repos, or on permission errors, check for common issues:

- Confirm repo:
  - Explicit (preferred): `gh repo view -R OWNER/REPO`
  - Implicit (CWD matches known repo and project path): `gh repo view`
- Verify auth: `gh auth status`

Note the active account and canonical `OWNER/REPO` before proceeding.

## GitHub Issues

**When:** asked to find, summarize, update, or work on an Issue.

1. List: `gh issue list -R OWNER/REPO`
2. Read: `gh issue view <number>`
3. Work on: `gh issue develop <number>` (creates branch + easy flow to PR when ready via `gh pr create [--title <title>] [--body <description>]` or `gh pr create --fill-verbose` to use the list of commit messages as description)

Creating a batch of issues from a task list or plan markdown file is a common workflow:

1. Read the file and extract tasks
2. `gh issue create` for each task
3. Ask user if you should start on the first issue
4. If yes, `gh issue develop <number of first created issue>`

If specifically asked, you can close issues, though usually this should be done by linking then to a PR that gets merged -- sometimes this is useful for cleaning up old issues though: `gh issue close <number>`

## Pull Requests

**When:** asked to review a PR, diagnose CI failures on a PR, move a draft to ready for review, or prepare a merge.

### Inspect (read-only)

- `gh pr list <number>`
- `gh pr view <number>`
- `gh pr diff <number>`
- `gh pr checks <number>`

### Provide Feedback

- Lightweight: `gh pr comment <number> --body "<notes>"`
- Formal review (when requested): `gh pr review <number> ...`

### Merge (high-risk)

Do **not** merge unless the user explicitly requests it and specifies the strategy. Typically, once reviews are approved and CI checks are passing, a merge with the preferred strategy will happen automatically, so manual merges should be rare and only done with clear user instructions.

- `gh pr merge --squash|--rebase`

**Always** preserve clear linear history, unless the user explicitly request a merge that will create a merge commit. Use `--squash` if the PR consists of many commits, if the PR is a couple of small, clear commits with good messages, a `--rebase` may be preferable. Most of the time though, `--squash` with a clear story is the safest choice.

## GitHub Actions

**When:** running CI, fetching run results, or triggering builds.

- List workflows: `gh workflow list`
- View a workflow: `gh workflow view <workflow>`
- Trigger a run: `gh workflow run <workflow>`
- Watch a run: `gh run watch <run-id>`
- Rerun failed jobs: `gh run rerun <run-id>`

## Other Needs

The `gh` CLI is very deep and well-designed, with great help text. If you need to do a less common operation, check the [reference guide](./references/gh-cli-guide.md) for the right command structure, and always follow the safety rules above. The reference guide may be out of date, so it's good to check the help text or, if necessary, the [latest docs from the manual](https://cli.github.com/manual/).
