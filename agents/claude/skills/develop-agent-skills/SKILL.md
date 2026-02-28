---
name: develop-agent-skills
description: |
  Guide for creating and improving highly effective Agent Skills. This skill should be used when (1) user wants to create a new skill (2) audit and improve and existing skill
allowed-tools: Bash(skillutil *)
---

# Skill Creator

Guide for creating and improving Agent Skills: modular packages that extend Claude with specialized workflows, domain knowledge, and bundled resources.

## Core Principles

### Concise is Key

The context window is a public good. Skills share the context window with everything else Claude needs: system prompt, conversation history, other Skills' metadata, and the actual user request.

**Default assumption: Claude is already very smart.** Only add context Claude doesn't already have. Challenge each piece of information: "Does Claude really need this explanation?" and "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability:

- **High freedom** (guidance): Multiple valid approaches, context-dependent decisions
- **Medium freedom** (patterns): Preferred approach exists, some variation acceptable
- **Low freedom** (strict rules): Operations are fragile, consistency critical, specific sequence required

**When unsure, opt for lowest freedom.** Rules can be loosened later, but damage from under-specified guidance can't always be undone. Treat skills as a least-privilege system.

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```text
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (TypeScript/Bash/Python/Ruby/etc.)
    ├── references/       - Documentation intended to be loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

#### SKILL.md (required)

Every SKILL.md consists of:

- **Frontmatter** (YAML): Contains `name` and `description` fields. These are the only fields that Claude reads to determine when the skill gets used, thus it is very important to be clear and comprehensive in describing what the skill is, and when it should be used.
- **Body** (Markdown): Instructions and guidance for using the skill. Only loaded AFTER the skill triggers (if at all).

#### Bundled Resources (optional)

##### Scripts (`scripts/`)

Executable code (TypeScript/Bash/Python/Ruby/etc.) for tasks that require deterministic reliability or are repeatedly rewritten.

- **When to include**: When the same code is being rewritten repeatedly or deterministic reliability is needed
- **Example**: `scripts/rotate_pdf.py` for PDF rotation tasks
- **Benefits**: Token efficient, deterministic, may be executed without loading into context
- **Note**: Scripts may still need to be read by Claude for patching or environment-specific adjustments

##### References (`references/`)

Documentation and reference material intended to be loaded as needed into context to inform Claude's process and thinking.

- **When to include**: For documentation that Claude should reference while working
- **Examples**: `references/finance.md` for financial schemas, `references/mnda.md` for company NDA template, `references/policies.md` for company policies, `references/api_docs.md` for API specifications
- **Use cases**: Database schemas, API documentation, domain knowledge, company policies, detailed workflow guides
- **Benefits**: Keeps SKILL.md lean, loaded only when Claude determines it's needed
- **Best practice**: If files are large (>10k words), include grep search patterns in SKILL.md - but typically these should be tightly-scoped, small, focused files
- **Avoid duplication**: Information should live in either SKILL.md or references files, not both. Prefer references files for detailed information unless it's truly core to the skill—this keeps SKILL.md lean while making information discoverable without hogging the context window. Keep only essential procedural instructions and workflow guidance in SKILL.md; move detailed reference material, schemas, and examples to references files.
- **Link with relative paths**: Reference files should use Markdown links with relative paths from the Skill root (where `SKILL.md` lives). Use proper Markdown link syntax, which includes ensuring relative links are unambiguous and correctly formatted: `[API reference](./references/api_docs.md)` not `[API reference](references/api_docs.md)`, the latter is considered an ambiguous relative link by markdownlint

##### Assets (`assets/`)

Files not intended to be loaded into context, but rather used within the output Claude produces.

- **When to include**: When the skill needs files that will be used in the final output
- **Examples**: `assets/logo.png` for brand assets, `assets/slides.pptx` for PowerPoint templates, `assets/frontend-template/` for HTML/React boilerplate, `assets/font.ttf` for typography
- **Use cases**: Templates, images, icons, boilerplate code, fonts, sample documents that get copied or modified
- **Benefits**: Separates output resources from documentation, enables Claude to use files without loading them into context

#### What to Not Include in a Skill

A skill should only contain essential files that directly support its functionality. Do NOT create extraneous documentation or auxiliary files, including:

- README.md
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md
- etc.

The skill should only contain the information needed for an AI agent to do the job at hand. It should not contain auxilary context about the process that went into creating it, setup and testing procedures, user-facing documentation, etc. Creating additional documentation files just adds clutter and confusion.

### Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude (Unlimited because scripts can be executed without reading into context window)

#### Progressive Disclosure Patterns

Keep SKILL.md body to the essentials and under 500 lines to minimize context bloat. Split content into separate files when approaching this limit. When splitting out content into other files, it is very important to reference them from SKILL.md and describe clearly when to read them, to ensure the reader of the skill knows they exist and when to use them.

**Key principle:** When a skill supports multiple variations, frameworks, or options, keep only the core workflow and selection guidance in SKILL.md. Move variant-specific details (patterns, examples, configuration) into separate reference files.

##### Pattern 1: High-level guide with references

```markdown
# PDF Processing

## Quick start

Extract text with pdfplumber:
[code example]

## Advanced features

- **Form filling**: See [FORMS.md](FORMS.md) for complete guide
- **API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
- **Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
```

Claude loads FORMS.md, REFERENCE.md, or EXAMPLES.md only when needed.

##### Pattern 2: Domain-specific organization

For Skills with multiple domains, organize content by domain to avoid loading irrelevant context:

```text
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

When a user asks about sales metrics, Claude only reads sales.md.

Similarly, for skills supporting multiple frameworks or variants, organize by variant:

```text
cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md (AWS deployment patterns)
    ├── gcp.md (GCP deployment patterns)
    └── azure.md (Azure deployment patterns)
```

When the user chooses AWS, Claude only reads aws.md.

##### Pattern 3: Conditional details

Show basic content, link to advanced content:

```markdown
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Claude reads REDLINING.md or OOXML.md only when the user needs those features.

##### Important guidelines

- **Avoid deeply nested references** - Keep references one level deep from SKILL.md. All reference files should link directly from SKILL.md.
- **Structure longer reference files** - For files longer than 100 lines, include a table of contents at the top so Claude can see the full scope when previewing.

## Skill Creation Process

Skill creation involves these steps:

1. Understand the skill with concrete examples
2. Plan reusable skill contents (scripts, references, assets)
3. Initialize the skill (run `skillutil init <skill-name>` or `skillutil init <skill-name> --path <output-directory>`)
4. Edit the skill (implement resources and write `SKILL.md`)
5. Validate structure (run `skillutil validate <skill-path>`)
6. Review against best practices
7. Iterate based on feedback

Follow these steps in order, skipping only if there is a clear reason why they are not applicable. If the user tells you to skip validation, it's fine to do so.

### Step 1: Understanding the Skill with Concrete Examples

Skip this step only when the skill's usage patterns are already clearly understood. It remains valuable even when working with an existing skill.

To create an effective skill, clearly understand concrete examples of how the skill will be used. This understanding can come from either direct user examples or generated examples that are validated with user feedback.

For example, when building an image-editor skill, relevant questions include:

- "What functionality should the image-editor skill support? Editing, rotating, anything else?"
- "Can you give some examples of how this skill would be used?"
- "I can imagine users asking for things like 'Remove the red-eye from this image' or 'Rotate this image'. Are there other ways you imagine this skill being used?"
- "What would a user say that should trigger this skill?"

To avoid overwhelming users, avoid asking too many questions in a single message. Start with the most important questions and follow up as needed for better effectiveness.

Conclude this step when there is a clear sense of the functionality the skill should support.

### Step 2: Planning the Reusable Skill Contents

To turn concrete examples into an effective skill, analyze each example by:

1. Considering how to execute on the example from scratch
2. Identifying what scripts, references, and assets would be helpful when executing these workflows repeatedly

Example: When building a `pdf-editor` skill to handle queries like "Help me rotate this PDF," the analysis shows:

1. Rotating a PDF requires re-writing the same code each time
2. A `scripts/rotate_pdf.py` script would be helpful to store in the skill

Example: When designing a `frontend-webapp-builder` skill for queries like "Build me a todo app" or "Build me a dashboard to track my steps," the analysis shows:

1. Writing a frontend webapp requires the same boilerplate HTML/React each time
2. An `assets/hello-world/` template containing the boilerplate HTML/React project files would be helpful to store in the skill

Example: When building a `big-query` skill to handle queries like "How many users have logged in today?" the analysis shows:

1. Querying BigQuery requires re-discovering the table schemas and relationships each time
2. A `references/schema.md` file documenting the table schemas would be helpful to store in the skill

To establish the skill's contents, analyze each concrete example to create a list of the reusable resources to include: scripts, references, and assets.

### Step 3: Initializing the Skill

At this point, it is time to actually create the skill.

Skip this step only if the skill being developed already exists, and only iteration is needed. In this case, continue to the next step.

When creating a new skill from scratch, it's easiest to run the `skillutil` script. The script conveniently generates a new template skill directory that automatically includes everything a skill requires, making the skill creation process much more efficient and reliable.

The script is an executable Deno/TypeScript file with a shebang that handles runtime and dependencies automatically. Templates are loaded from `~/.claude/skills/agent-skills/assets/`.

Usage:

```bash
skillutil init <skill-name> [--path <output-directory>]
```

If `--path` is not provided, the skill will be created in `~/.claude/skills/` as a user-level skill available to all projects and sessions. This is often desirable! If the skill reflects the user's git preferences, shell environment that applies everywhere, or even frontend skills that are applicable across any web project, you should consider making it a user-level skill.

Examples:

```bash
# Create in default location (~/.claude/skills/my-skill)
skillutil init my-skill

# Create in custom location
skillutil init my-skill --path ~/projects/skills

# Create in current directory
skillutil init my-skill --path .
```

The script:

- Creates the skill directory at the specified path
- Generates a SKILL.md template with proper frontmatter and TODO placeholders
- Creates example resource directories: `scripts/`, `references/`, and `assets/`
- Adds example files in each directory that can be customized or deleted

After initialization, customize or remove the generated template files as needed.

### Step 4: Edit the Skill

When editing the (newly-generated or existing) skill, remember that the skill is being created for another instance of Claude to use. Include information that would be beneficial and non-obvious to Claude. Consider what procedural knowledge, domain-specific details, or reusable assets would help another Claude instance execute these tasks more effectively.

#### Learn Proven Design Patterns

Consult these helpful guides based on your skill's needs:

- **Multi-step processes**: See references/workflows.md for sequential workflows and conditional logic
- **Specific output formats or quality standards**: See references/output-patterns.md for template and example patterns
- **Improving existing skills**: See references/refactoring-checklist.md for restructuring bloated or ineffective skills

These files contain established best practices for effective skill design.

#### Start with Reusable Skill Contents

To begin implementation, start with the reusable resources identified above: `scripts/`, `references/`, and `assets/` files. Note that this step may require user input. For example, when implementing a `brand-guidelines` skill, the user may need to provide brand assets or templates to store in `assets/`, or documentation to store in `references/`.

Added scripts must be tested by actually running them to ensure there are no bugs and that the output matches what is expected. If there are many similar scripts, only a representative sample needs to be tested to ensure confidence that they all work while balancing time to completion.

Any example files and directories not needed for the skill should be deleted. The initialization script creates example files in `scripts/`, `references/`, and `assets/` to demonstrate structure, but most skills won't need all of them.

#### Update SKILL.md

**Writing Guidelines:** Always use imperative/infinitive form.

##### Frontmatter

Write the YAML frontmatter with `name` and `description`:

- `name`: The skill name (lowercase, hyphens, max 64 chars)
- `description`: The primary triggering mechanism. Claude uses this to decide when to activate the skill from potentially 100+ installed skills.

**Description writing process:**

1. **Draft**: Lead with what the skill does (third person), then trigger context. Include "when to use" info here, not in the body (body loads only after triggering).

2. **Evaluate with these lenses** (iterate until no improvements found):
   - **Purpose**: Does it capture what the skill IS, or just echo user phrasing?
   - **Name + description pair**: Does description add signal beyond the name?
   - **False positives**: Could common words trigger on unrelated tasks?
   - **False negatives**: Would someone needing this skill use words not present?
   - **Overfocus**: Does a specific example make the skill seem narrower than it is?
   - **Human scan**: In a list of 50 skills, can you instantly tell what it does?
   - **Word efficiency**: For each word, does removing it make the description worse? If not, remove it.

3. **Consolidate triggers**: Condense to 3 or fewer scenarios. "Editing", "modifying", "updating" are all the same thing.

**Example - BAD (bloated):**
> "Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. Use when Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying or editing content, (3) Working with tracked changes, (4) Adding comments, or any other document tasks (5) Verifying contents (6) Formatting text in docx files"

**Example - GOOD (concise):**
> "Document creation, editing, and analysis with tracked changes support. Use for .docx files: (1) Creating documents, (2) Modifying contents or metadata, (3) Working with change history"

Do not include other fields like `allowed-tools` unless requested by the user and given a clear list of tools for the allow list.

##### Body

Extremely concise, tightly-scoped, modular instructions for using the skill and its resources.

### Step 5: Validation

Once development of the skill is complete, you can run the `skillutil validate` command to check for common issues with formatting, naming, and structure.

Usage:

```bash
skillutil validate <skill-path>
```

Example:

```bash
skillutil validate ~/.claude/skills/my-skill
```

The validator checks:

- YAML frontmatter format and required fields
- Skill naming conventions (hyphen-case, valid characters, length limits)
- Description completeness and constraints (no angle brackets, max 1024 chars)
- Unexpected frontmatter properties

### Step 6: Review Against Best Practices

Before considering the skill complete, explicitly review it against best practices. This step catches issues that validation scripts miss.

1. **Re-read** the Anthropic best practices in `./references/anthropic-docs/best-practices.md` (run `skillutil refresh-docs` if not present)
2. **Compare** your skill against each guideline:
   - Does the description include clear trigger words?
   - Is the body concise? Remove anything Claude already knows.
   - Are references one level deep from SKILL.md?
   - Any anti-patterns present (verbose explanations, deeply nested files, redundant content)?
3. **Fix** any issues found before proceeding

### Step 7: Iterate

After testing the skill, users may request improvements. Often this happens right after using the skill, with fresh context of how the skill performed.

**Iteration workflow:**

1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Identify how SKILL.md or bundled resources should be updated
4. Implement changes and get feedback until complete

Run `skillutil validate <skill-path>` after making changes to the frontmatter, or at the end of the Skill creation session to make sure everything is ready to use.

## External Resources

### Local Anthropic Documentation

Run `skillutil refresh-docs` to fetch/update official Anthropic skill documentation into `./references/anthropic-docs/`. These files contain authoritative best practices:

- `overview.md` - Core concepts and architecture
- `skills.md` - Implementation patterns and usage
- `best-practices.md` - Authoring guidelines and pitfalls

### Online Resources

- Full Agent Skills documentation: <https://agentskills.io/home>
  - Helpful for checking the full spec beyond basic fields and structure
