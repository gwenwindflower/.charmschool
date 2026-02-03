# Markdown Tables

Tables in "compact" style require spaces around inner pipe edges. This is required by standard markdownlint rules (MD030) and improves compatibility across renderers.

## Rule

Inner pipes need spaces on both sides. Outer pipes have no space on the outside edge.

## Example: Claude Code Default Output (Incorrect)

Claude Code tends to generate tables without inner spacing:

```markdown
|Name|Description|
|---|---|
|foo|A foo thing|
|bar|A bar thing|
```

This fails markdownlint and renders inconsistently.

## Corrected Format

Add spaces around inner pipe edges:

```markdown
| Name | Description |
| --- | --- |
| foo | A foo thing |
| bar | A bar thing |
```

## Pattern

```text
| cell | cell | cell |
  ^  ^  ^  ^  ^  ^
  spaces around inner content
```

The separator row follows the same rule:

- Wrong: `|---|---|`
- Correct: `| --- | --- |`

## Quick Fix

When you see a table without spacing, add a single space after each `|` and before each `|` (except the outer edges of the first and last pipes in a row).
