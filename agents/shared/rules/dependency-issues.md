# Responding to Dependency Issues in Package Managers

It's important to consider whether your actions will affect the global environment or ignore safety checks before independently bashing through dependency issues.

Let's say you're in a project using npm, and forced to remove and rebuild `node_modules`. While non-ideal, it's easy enough to rebuild and get back to a fresh working state.

Conversely, let's say you have an issue with pnpm, and decide you want to run a command to rebuild the global store. This is a hard stop point. If the tool has a global level, you can wreak havoc on other projects and the system at large.

Similarly, modern package managers have built-in security measures, like checksum verification, to protect users from malicious packages. Bypassing these checks just to avoid a user prompt is a huge risk, you could contaminate a user's system in a way that could destroy their machine, get them fired if they're on a company laptop, or cause all sorts of other harm. This is not worth avoiding a user prompt or trying to "independently problem solve" your way out of a dependency issue.

**Always** stop and ask for user input or assistance if you are about to take an action like:

- rebuilding a global store or cache
- relocating a global store or cache to a different path
- changing global settings in a package manager's config
- bypassing a package manager built-in checksum verification or internal security measures

## Correct Way to Handle Access Issues

If you're sandboxed from access to a directory or network domain that you need for built-in caching or security, you should:

1. Stop, explain the issue to the user clearly, and offer them solution options.
2. One of the solutions should always be to examine the sandbox permissions, and see if it would be safe to grant access moving forward. Explain how to do that, and the pros, cons, and risks of doing so. Long-term user-level solutions are always preferable to immediate hacks.
3. The other solution that is always available is to have the user run the command(s) themselves. If they say that's their preference, give them a concise list of exact commands to run, and ask them to report back once they're done. If they've indicated unfamiliarity with a tool, make sure they understand what the commands are going to do before they run them.
    - If the need is adding new dependencies to the project, try to think ahead of all the dependencies you're going to need, so they can add them in one go, rather than running into the issue again shortly after. Concisely explain why non-obvious packages are needed as well (e.g., if they've asked you to use shadcn/ui for components and Zod for types, you don't need to explain those, but if there are ancillary libraries needed to integrate those with the project, you should explain the need for those).
