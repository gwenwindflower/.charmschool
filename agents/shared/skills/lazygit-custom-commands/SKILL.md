---
name: lazygit-custom-commands
description: Build and troubleshoot lazygit customCommands in config.yml. Use for prompt-driven commands, context-specific keybindings, commandMenus, template-based construction, and conventional-commit style workflows.
---

# Lazygit Custom Commands

## Fields

`context` and `command` are required (except `commandMenu` entries — see below).

| Field | Notes |
| --- | --- |
| `key` | Hotkey — omit to expose via `?` menu only |
| `context` | Required. Comma-separated for multi: `'commits, subCommits'` |
| `command` | Required. Go template string |
| `description` | Shown in UI and `?` menu |
| `loadingText` | Progress label while running |
| `output` | `none` \| `terminal` \| `log` \| `logWithPty` \| `popup` |
| `outputTitle` | Title for `popup` output |
| `after` | `checkForConflicts` |
| `prompts` | List of prompt configs (see below) |

Keys: single letters or special forms like `<c-t>`, `<f5>`, `<esc>`.

## Contexts

`status`, `files`, `worktrees`, `localBranches`, `remotes`, `remoteBranches`, `tags`, `commits`, `reflogCommits`, `subCommits`, `commitFiles`, `stash`, `global`

## Prompts

All prompts share: `type`, `title`, `key`. Answers referenced as `{{.Form.<Key>}}`.

### input

```yaml
- type: 'input'
  key: 'Scope'
  title: 'Scope (optional):'
  initialValue: ''
  suggestions:
    preset: 'branches'  # authors|branches|files|refs|remotes|remoteBranches|tags
    # OR: command: 'my-cmd'  (mutually exclusive with preset)
```

### confirm

```yaml
- type: 'confirm'
  key: 'Confirm'
  title: 'Force-push to remote?'
  body: 'This will rewrite history on the remote branch.'
```

### menu

Options: `value` required, `name` (display label — shows `value` if omitted), `description`, `key` (direct-select).

```yaml
- type: 'menu'
  key: 'Type'
  title: 'Commit type:'
  options:
    - value: 'feat'
      name: 'Feature'
      description: 'New functionality'
      key: 'f'
    - value: 'fix'
      key: 'x'
    - value: 'chore'
```

### menuFromCommand

```yaml
- type: 'menuFromCommand'
  key: 'Branch'
  title: 'Remote branch:'
  command: 'git branch -r --list {{.SelectedRemote.Name}}/*'
  filter: '.*{{.SelectedRemote.Name}}/(?P<branch>.*)'  # named groups: ?P<name>, unnamed: group_1, group_2...
  valueFormat: '{{.branch}}'
  labelFormat: '{{.branch | green}}'
```

Without `filter`/`valueFormat`/`labelFormat`, each output line is both value and label.

## Template data

Objects available in `command` and prompts:

`SelectedFile` (files) · `SelectedLocalBranch` (localBranches) · `SelectedRemote` (remotes) · `SelectedRemoteBranch` (remoteBranches) · `SelectedTag` (tags) · `SelectedCommit` (commits) · `SelectedCommitRange` (commits) · `SelectedStashEntry` (stash) · `SelectedCommitFile` (commitFiles) · `SelectedWorktree` (worktrees) · `SelectedPath` · `CheckedOutBranch` (global)

Notable fields: `SelectedFile.Name`, `SelectedFile.HasUnstagedChanges`, `SelectedRemote.Name`, `SelectedCommitRange.From`/`.To`.

Helpers: `quote` (safe shell quoting), `runCommand` (interpolate single-line command output).

Template example with a conditional:

```yaml
command: "git {{if .SelectedFile.HasUnstagedChanges}}add{{else}}reset{{end}} {{.SelectedFile.Name | quote}}"
```

Prefer Go template conditionals (`if`, `else if`, `eq`) over shell parsing complexity.

## commandMenu

Groups commands under one top-level key. Only `key` and `description` allowed at the top level — full fields go on entries:

```yaml
customCommands:
  - key: 'X'
    description: 'Patch workflows'
    commandMenu:
      - key: 'c'
        context: 'commits, subCommits'
        description: 'Copy range to clipboard'
        command: 'git format-patch --stdout {{.SelectedCommitRange.From}}^..{{.SelectedCommitRange.To}} | pbcopy'
      - key: 'v'
        context: 'commits'
        description: 'Apply from clipboard'
        command: 'pbpaste | git am'
```

## Keybinding rules

- Custom key collides with built-in in the same context → custom wins
- Custom key is `global`, built-in exists for the active specific context → built-in wins

## Debug

Set `output: popup` and wrap `command` in `echo` to preview template resolution without executing.

## Output conventions

Return paste-ready YAML with correct indentation and explicit `context`. Verify keybinding collisions and `.Form.<Key>` references before finalizing.

## External resources

> Only fetch these if something specific isn't covered above — the spec is long and will waste a ton of context window tokens if you pull it in wholesale unnecessarily.

- [Custom Command Keybindings spec](https://raw.githubusercontent.com/jesseduffield/lazygit/master/docs/Custom_Command_Keybindings.md) — authoritative field reference
- [Custom Commands Compendium](https://github.com/jesseduffield/lazygit/wiki/Custom-Commands-Compendium) — real-world examples (conventional commits, tig, remote checkout, pull/fetch helpers)
