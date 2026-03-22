---
name: develop-agent-skills
description: Guide for creating and improving highly effective Agent Skills. Use when user wants to create a new skill, or when auditing and improving existing skills
allowed-tools:
  - Bash(skillutil *)
---

# Skill Creator

Guide for creating and improving Agent Skills: modular packages that extend Claude with specialized workflows, domain knowledge, and bundled resources. The primary guidance for this skill in the [overview](overview.md) file fetched from the Anthropic docs via `skillutil refresh-docs`. You do not need to run this command to start, this file already exist. You should always read this, any other reference docs are optional based on need.

> [!NOTE]
> `skillutil` is available on PATH, in `~/.local/bin/skillutil`, there's no need to access the script directly.

## Creating a New Skill

1. Read overview file
2. Ask the user any clarifying questions about skill goals, preferences, or examples
3. Plan contents (do you need additional files? Are scripts and assets appropriate?)
4. Initialize the skill (run `skillutil init <skill-name>` or `skillutil init <skill-name> --path <output-directory>`)
5. Edit the skill (write `SKILL.md`, add scripts, modular docs, and assets as needed)
6. Validate structure and frontmatter schema (run `skillutil validate <skill-path>`)

Follow these steps in order, skipping only if there is a clear reason why they are not applicable. If the user tells you to skip validation, it's fine to do so.

## Editing an Existing Skill

When editing an existing skill, first ask the user what they want to improve or add. Then follow steps 2-6 from the "Creating a New Skill" process above, skipping step 4 since the skill already exists.

## `skillutil` Tool

There is a custom CLI tool available for skill management, written in Deno and installed locally. Use it to create, validate, or fork third-party skills from GitHub.

### Creation

```bash
skillutil init <skill-name> [--path <output-directory>]
```

If `--path` is not provided, the skill will be created in the shared skills directory (`agents/shared/skills/`), symlinked to `~/.agents/skills/` + any agent-specific locations (e.g. `~/.claude/skills/`). This makes it available to all agents, projects, and sessions. This is often desirable! If the skill reflects the user's git preferences, shell environment that applies everywhere, or even frontend skills that are applicable across any web project, you should consider making it a shared skill.

Examples:

```bash
# Create a shared skill (default, agents/shared/skills/my-skill)
skillutil init my-skill

# Create a project-scoped skill
skillutil init my-skill --path path/to/project

# Fork a GitHub repo as your skill base (must contain SKILL.md in root)
skillutil init --fork <GitHub repo url>
```

The script (unless forking):

- Creates the skill directory at the specified path
- Generates a SKILL.md template with proper frontmatter and TODO placeholders
- Creates example resource directories: `scripts/`, `references/`, and `assets/`
- Adds example files in each directory that can be customized or deleted

After initialization, customize or remove the generated template files as needed.

If forking, you will get the same structure as the external skill to start from, in the default or specified path.

### Validation

```bash
skillutil validate <skill-path>
```

### Adding Third-Party Skills

It's usually better to use `skillutil` add for external skills. It works for single skills or a directory of skill files, and safely skips any duplicate skills that already exist with the same name in the user's skill library at the given level/path.

```bash
skillutil add <GitHub repo url>
```

### Refresh Local Documentation

The key reference docs from Anthropic are available in this skill's root directory, with `overview.md` as the main entry point.

If these files were last modified more than a month ago, run `skillutil refresh-docs` to fetch updated documentation before relying on them for skill development.

### Listing and Managing Skills

Skills can be deactivated without deleting, using the `skillutil deactivate <skill-name>` command. Deactivated skills will not be loaded in sessions but remain available for future use or editing. To reactivate, use `skillutil activate <skill-name>`. To see the list of active skills, run `skillutil list`, or include deactivated skills with `skillutil list --all`.

## Skill Loading

Understanding how skills load helps you write effective ones:

1. **Startup**: Only name + description loaded (aim for <100 tokens each — this is what determines whether a skill gets triggered)
2. **Triggered**: Full SKILL.md loaded into context — keep this tight, use markdown links to references/assets/scripts for deeper dives
3. **Modules**: References, assets, and scripts loaded on demand, protecting context window space — by keeping SKILL.md concise and using many small modular files, you follow the correct progressive disclosure pattern

## Full Schema Details

If you need frontmatter or content properties beyond basic fields and structure, fetch the latest version of the full spec here: <https://agentskills.io/specification>
