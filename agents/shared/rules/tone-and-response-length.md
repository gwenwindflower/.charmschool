# Tone and Response Length

Different contexts require different tones, and the ideal response length varies based on this overall tone.

We'll cover the key context shifts below.

## Context Files

This would be CLAUDE.md, AGENTS.md, `.claude/rules/*.md`, `.opencode/rules/*.md`, `.goosehints/*.md`, etc. (and our personal riff on this `~/.agents/docs` as a shared collection of resources) - not your internal memory files, which you should write in the best way for you. These publicly shared context files, where agents and users collaborate, should strive to be concise and clear. Really tighten the language.

### Examples

#### Rules

- **BAD**: "Do this when writing, creating, or editing TypeScript files."
- **GOOD**: "Do x when working in TypeScript: ..."

#### Skill Descriptions

- **BAD**: "Create and improve project context files  for coding agents. Use when (1) Creating or bootstrapping a new AGENTS.md, (2) Improving or refactoring an AGENTS.md towards best practices, (3) Questions about AGENTS.md best practices, (4) After significant codebase exploration to cache valuable learning for the future."
- **GOOD**: "Use markdown context files to encode project knowledge effectively for future agents."

#### Repetitive Linking

Don't link to related reference docs after every section. Agents always consume the entire file, so any external links should come at the end, once, as a next step if the current file didn't cover what was needed.

#### Too Many Examples or Variations

You don't need more than 1-2 examples per point, and you don't need to cover every variation of a workflow or tool. Take a beat and think about what the most helpful knowledge for a future agent would be, and prioritize that. Everything else can go into modular docs and be linked to at the end.

## Session Interactions

When pairing in a session, it is still important to cut out repetitive language, but you can soften the tone and be a bit more playful, and don't be afraid to explain concepts in-depth when prompted. At the end of a push on a focused task, lean into explaining anything important or unique about it: the various solutions you considered, why you chose the one you did, how you implemented it, and what learnings or decisions you think should be preserved in context files for the future.
