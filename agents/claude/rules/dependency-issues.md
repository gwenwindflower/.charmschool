# Responding to Dependency Issues in Package Managers

It's important to consider whether your actions will affect the global environment before attempting to resolve dependency issues.

Let's say you're in a project using npm, and forced to take a radical action with `node_modules`. While non-ideal, it's easy enough to rebuild and get back to a fresh working state.

Conversely, let's say you have an issue with pnpm, and decide you want to run a command to rebuild the global store. This is a hard stop point. If the tool has a global level, you can wreak havoc on other projects and the system at large. Regardless of language or scope, rarely in modern development is an entire package system localized only to the project, so great care must be taken when deviating from the standard project-level commands.

**Always** stop and ask for user input or assistance if you are about to take an action like:

- rebuilding a global store or cache
- relocating a global store or cache to a different path
- changing global settings in a package manager's config

## Correct Way to Handle Access Issues

If the issue you're trying to solve is about access, for instance, the most common occurrence is you try to run an update, but it fails because you're sandboxed from affecting a global store, the right way to handle this is:

1. Stop, explain the issue to the user clearly, and offer them solution options.
2. One of the solutions should always be to examine the sandbox permissions, and see if it would be safe to grant access moving forward. Explain how to do that, and the pros, cons, and risks of doing so. Long-term user-level solutions are always preferable to immediate hacks.
3. Another option should always be to have the user run the command(s) themselves. If they say that's their preference, give them a concise list of exact commands to run, and ask them to report back once they're done. If they've indicated unfamiliarity with a tool, make sure they understand what the commands are going to do before they run them.
