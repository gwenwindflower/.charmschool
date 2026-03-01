# gh CLI Reference Guide

Non-exhaustive reference of common commands. Use [the manual](https://cli.github.com/manual/) for anything not listed here.

## Global Flags

- `--help` — Help for any command
- `--version` — Print version
- `-R, --repo OWNER/REPO` — Target a repo explicitly (useful if unsure of context)

## auth

Verify identity and permissions.

- `status` — Check auth state
- `login` — Establish auth (interactive/device flow)

## repo

Discover and set up repositories.

- `view` — View repo metadata
- `clone` — Clone repo to workspace
- `fork` — Fork repo

## issue

Triage and manage issues.

- `list` — Find issues
- `view` — Read issue details
- `create` — Create issue
- `develop` — Create branch linked to issue
- `comment` — Add comment
- `close` — Close issue when resolved

## pr

PR lifecycle: inspect, create, review, merge.

- `list` — Find PRs
- `view` — Read PR details (checks, files, timeline)
- `diff` — Inspect patch
- `checks` — Inspect CI status
- `create` — Open PR
- `review` — Approve / request changes / comment
- `merge` — Merge PR (use with caution)
- `comment` — Non-review comment
- `status` — Quick PR summary for current context

## workflow

Inspect and trigger GitHub Actions workflows.

- `list` — List workflows
- `view` — View workflow definition/metadata
- `run` — Trigger workflow_dispatch (parameterized runs)

## run

Monitor and manage workflow runs.

- `list` — List recent runs
- `view` — View run details/logs
- `watch` — Stream run status to completion
- `rerun` — Rerun failed jobs/workflow

## search

Find resources across GitHub.

- `repos` — Find repos
- `issues` — Find issues
- `prs` — Find PRs
