# Skill Refactoring Checklist

Detailed guidance for improving and restructuring bloated or ineffective skills.

## Phase 1: Analyze

Before making changes, understand current state:

- [ ] Count SKILL.md lines (target: under 500 lines)
- [ ] Identify contradictory or unclear instructions
- [ ] Find duplicate content between SKILL.md and references
- [ ] Mark vague/unactionable items for removal
- [ ] List content that should move to references files
- [ ] Check if description is comprehensive yet concise

## Phase 2: Identify SKILL.md-Only Content

These belong in SKILL.md body:

- Skill purpose (1-2 sentences)
- Core workflow steps
- Hard constraints ("always X", "never Y")
- Safety warnings
- Links to bundled resources with clear "when to read" guidance

## Phase 3: Categorize Remaining Content

Common categories for `references/`:

| Category | Examples |
| --- | --- |
| `workflows.md` | Multi-step procedures, conditional flows |
| `output-patterns.md` | Templates, format specifications |
| `api-reference.md` | API docs, method signatures |
| `schemas.md` | Data structures, database schemas |
| `examples.md` | Code samples, usage patterns |
| `troubleshooting.md` | Common errors, debugging steps |
| `{variant}.md` | Framework/platform-specific details |

## Phase 4: Create Modular Structure

```text
skill-name/
├── SKILL.md              # Core workflow + navigation to resources
├── scripts/              # Executable code (if needed)
├── references/           # Documentation loaded as needed
│   ├── workflows.md
│   └── [topic].md
└── assets/               # Output files (if needed)
```

Each reference file should:

- Cover one focused topic
- Be self-contained (reader shouldn't need other files)
- Start with a brief purpose statement
- Include a TOC if over 100 lines

## Phase 5: Prune

Remove these patterns:

**Vague directives:**

- "Be thorough"
- "Use best practices"
- "Keep it clean"
- "Handle errors appropriately"

**Claude's existing knowledge:**

- Generic programming patterns
- Standard library usage
- Common tool conventions
- Basic file operations

**Redundant with description:**

- "When to use this skill" sections in the body (description handles triggering)
- Repeated trigger scenarios already in frontmatter

**Unnecessary documentation:**

- README.md, CHANGELOG.md, INSTALLATION_GUIDE.md
- Process documentation about skill creation
- User-facing setup instructions

## Phase 6: Improve Frontmatter

Review and tighten the description:

- [ ] Includes what the skill does
- [ ] Includes specific triggers/contexts
- [ ] No duplicate trigger scenarios (editing/modifying/updating = same)
- [ ] Comprehensive without being bloated
- [ ] Under ~100 words

## Verification

After restructuring:

- [ ] SKILL.md under 500 lines
- [ ] All reference file links resolve
- [ ] No contradictions between files
- [ ] Each instruction is specific and actionable
- [ ] No orphaned references to moved content
- [ ] Run `validate` script to check structure
- [ ] Test skill with representative examples

## Example: Before/After

### Before (bloated SKILL.md)

```markdown
---
name: pdf-editor
description: Edit PDF files
---

# PDF Editor

This skill helps you edit PDF files.

## When to Use

Use this skill when:
- Editing PDFs
- Modifying PDFs
- Updating PDFs
- Changing PDFs
- Working with PDF documents

## Core Concepts

PDFs are Portable Document Format files...
[200 lines of PDF background]

## Workflows

### Rotating Pages
[50 lines of rotation instructions]

### Extracting Text
[50 lines of extraction instructions]

### Merging Files
[50 lines of merge instructions]

## API Reference
[100 lines of library documentation]

## Troubleshooting
[100 lines of error handling]
```

### After (modular)

**SKILL.md:**

```markdown
---
name: pdf-editor
description: Edit PDF files including rotation, text extraction, merging, and page manipulation. Use when working with .pdf files for any modification or content extraction task.
---

# PDF Editor

Edit PDFs using PyMuPDF (fitz). For installation issues, ensure `pymupdf` is installed.

## Quick Reference

| Task | Script |
| --- | --- |
| Rotate pages | `scripts/rotate.py <file> <degrees>` |
| Extract text | `scripts/extract.py <file>` |
| Merge files | `scripts/merge.py <output> <files...>` |

## Workflows

For multi-step procedures, see [references/workflows.md](references/workflows.md).

## Troubleshooting

For common errors and debugging, see [references/troubleshooting.md](references/troubleshooting.md).
```

**references/workflows.md:**

```markdown
# PDF Workflows

## Rotate and Extract

1. Rotate pages: `scripts/rotate.py input.pdf 90`
2. Extract text: `scripts/extract.py input_rotated.pdf`

## Batch Processing

For multiple files, iterate with shell:
[code example]
```
