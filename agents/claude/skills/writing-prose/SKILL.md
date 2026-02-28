---
name: writing-prose
description: Always use this skill when writing or editing prose. Do **NOT** use for agent context files, readmes, tool descriptions, or other functional writing tasks.
---

# Writing Prose

Apply these rules to any writing task: generating prose, or editing existing prose you're given to review and improve.

These rules eliminate common patterns in low quality writing (both AI-generated and human) that frustrate readers with empty predictability, causing them to disengage.

## Core Principles

1. **Write directly** - Use the active voice with clear, punchy word choices instead of stacking adjectives, emphasis filler, cliches, and predictable metaphors
2. **Avoid formulaic patterns** - Sidestep binary contrasts, predictable opening phrases, and repetitive dramatic structures

## Reference Files

Full guidance is modularized in these guides:

- [Phrases and Wording](phrases-and-wording.md)
- [Voice and Flow](voice-and-flow.md)

## Editor Workflow

After writing prose, you **MUST** start a review loop with the `writing-prose-editor` subagent. It will score the version of the work that you have generated or edited across 8 dimensions, assigning 1-5 points for each (40 points max). If the score is below 32, you must revise the prose based on the specific feedback provided by the editor and repeat the review loop until you achieve a passing score (≥ 32/40). **DO NOT** self-score or self-approve to bypass the editor's authority. They are your manager, you must go through their approval process.

1. Write prose following the Core Principles
2. Pass the full prose to the `writing-prose-editor` subagent
3. Review the score and specific feedback
4. If score < 32/40, revise based on the exact issues cited and repeat from step 2
5. Present the final prose only once it passes (≥ 32/40)

Iterate until passing. The editor is the authoritative scorer.
