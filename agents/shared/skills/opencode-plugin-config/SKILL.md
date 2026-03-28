---
name: opencode-plugin-config
description: Use when asked to automate an action for OpenCode, for example run a formatter after edits, or running a script right before git commits, those are hooks and you should use this skill to implement them.
---

# OpenCode Plugin Configuration

1. Fetch the latest docs: <https://opencode.ai/docs/plugins>
2. Refine the type of plugin you need to create: a hook that runs a script, a custom tool, a logger that prints structured output to the client interface, etc.
3. Determine scope: is this a user-level plugin (in `~/.opencode/plugins`) that would accelerate every project, or a project-level plugin with highly specific details (in `<project root>/.opencode/plugins`)?
4. Build the plugin in TypeScript with bun as the target runtime. Use bun for quick iteration and testing if necessary, before moving on to testing the integration with OpenCode.
