---
name: obsidian-frontmatter-sync
description: Manage Obsidian vault frontmatter with rematter — validate schemas, sync to external destinations (Astro, etc.) with media options, rename fields, manage filenames. Load whenever performing bulk operations in Obsidian vaults (or other collections of markdown with frontmatter).
---

# Obsidian Frontmatter Sync with rematter

CLI tool for transforming and syncing Obsidian vault frontmatter.

## Quick Start

```bash
# Install
uv tool install rematter

# Update
uv tool upgrade rematter

# Update for new Python version or to clear issues
uv tool install rematter --reinstall

# Validate frontmatter against .rematter schema
rematter validate ~/vault/sky

# Sync to an external destination (e.g. Astro content collection)
rematter sync ~/vault/sky --dest ~/site/src/content/sky

# Dry-run any command to preview changes
rematter sync ~/vault/sky -n
```

## Config File (`.rematter.yaml`)

Lives in the vault subdirectory being operated on. Combines sync config and frontmatter schema in one file.

```yaml
# Sync config
link_path_prefix: /sky
dest: ~/dev/my-site/src/content/sky/
ignore:
  - draft-*
  - private/*
media:
  source: _media
  dest: src/assets
  link_prefix: /assets

# Frontmatter schema
properties:
  status:
    type: string
    required: false
    enum: [not_started, in_progress, on_hold, done, cancelled]
    default: not_started
  creators:
    type: list
    required: false
  own:
    type: bool
    required: false
    default: false
    sync: false          # validated but stripped from dest
  hero:
    type: string
    required: false
    requires: [heroAlt]  # co-dependency: both or neither
  heroAlt:
    type: string
    required: false
    requires: [hero]
  created:
    type: timestamp
    required: true
    default: "%Y-%m-%d %H:%M"   # strftime format → stamps current time on --fix
    sync: false
  modified:
    type: timestamp
    required: true
    default: "%Y-%m-%d %H:%M"
  synced:
    type: timestamp
    required: true
    default: null                # adds key with null value, never stamps a fake time
  publish:
    type: bool
    required: true
    default: false
    sync: false
```

### Property Spec Fields

| Field | Purpose |
| --- | --- |
| `type` | `timestamp`, `bool`, `string`, `list`, `int`, `float` |
| `required` | Key must exist (null is valid — e.g. `synced: null` before first sync) |
| `default` | Value set by `--fix` when missing. strftime string for timestamps, literal for others, `null` for explicit null |
| `enum` | Allowed values (string fields) |
| `requires` | Companion fields that must also have values (co-dependency) |
| `sync` | `true` (default) or `false` — when false, field is recognized but stripped from dest output |

## Commands

### `validate` — Check frontmatter against schema

```bash
rematter validate <directory> [--schema PATH] [--fix] [--recursive] [--dry-run]
```

- Report-only by default, exits 1 on failures
- `--fix` sets defaults for missing properties and reorders keys to match schema order
- `--fix` + `--dry-run` previews what would change
- All properties must be declared in schema — unrecognized keys always error

### `sync` — Sync vault markdown to an external destination

```bash
rematter sync <source> [--dest PATH] [--link-path-prefix PREFIX] [--dry-run]
```

Pipeline per file:

1. Skip files where `publish` is not `true`
2. Slugify filename for dest (`Publishable Book.md` → `publishable-book.md`)
3. Skip if dest has same `modified` value (no changes)
4. Extract type from capitalized Obsidian tags (`#Book` → `type: book`)
5. Validate against schema
6. Resolve creator wikilinks to `{name, slug}` objects
7. Resolve body wikilinks to markdown links (broken links → plain text)
8. Resolve media references (wikilink and markdown image syntax)
9. Rewrite hero image path if media config present
10. Stamp `synced` timestamp, set `title` from source filename
11. Strip `sync: false` fields from dest
12. Write dest file, copy referenced media, stamp `synced` back on source

Config keys (`dest`, `link_path_prefix`) can come from `.rematter.yaml` or CLI flags. CLI always wins. Config is required for sync.

### `filename` — Prepend date to filenames

```bash
rematter filename <directory> [--field DATE_FIELD] [--recursive] [--dry-run]
```

Reads a date field (default: `Date`), prepends `YYYY-MM-DD -` to the filename, and removes the field from frontmatter. Already-prefixed files are skipped.

### `transform` — Rename a frontmatter field

```bash
rematter transform <directory> --field OLD --to NEW [--recursive] [--dry-run]
```

Renames a field across all markdown files. Key order preserved. Skips files where the target name already exists.

## Key Behaviors

- **Wikilink resolution**: `[[Target]]` and `[[Target|Label]]` resolve to markdown links for known files (source + dest corpus). Broken links become plain text. Image refs (`![[img.png]]`) are handled separately and never mangled.
- **Media sync**: When `media` config is present, `![[img.png]]` and `![alt](_media/img.png)` refs are rewritten with the dest link prefix. Only referenced files are copied, not the entire media directory.
- **Ignore patterns**: `ignore` list in config uses glob patterns matched against both filename and relative path.
- **Timestamp format**: Always `YYYY-MM-DD HH:MM` (space separator, no seconds) to match Obsidian's native format.
- **Type tags**: Capitalized Obsidian tags (`#Book`, `#Film`) are extracted as the `type` field. Multiple capitalized tags → skip with warning. Lowercase tags are content, not types.
