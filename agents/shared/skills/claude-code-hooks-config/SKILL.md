---
name: claude-code-hooks-config
description: Use when asked to add or modify hooks for Claude Code specifically. Or, if the user is asking to automate an action, for example run a formatter after edits, or running a script right before git commits, those are hooks and you should use this skill to implement them.
---

# Adding or Modifying Hooks for Claude Code

Hooks allow specific behaviors or scripts to trigger automatically after highly configurable events.

1. Review the general hooks guide: <https://code.claude.com/docs/en/hooks-guide>
2. Review the in-depth hooks configuration docs: <https://code.claude.com/docs/en/hooks>
3. Edit the project-level `.claude/settings.json`, either adding, editing, or expanding the `hooks` property to achieve the goal. It's important to do this at the project level, unless the user specifically asks you to add a system-wide hook at the user level (`~/.claude/settings.json`), which is less common.
4. Work with the user to trigger the target event(s) and confirm it's working as expected.
