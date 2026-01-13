# Claude Code Config Notes

```yaml
last_updated: 2026-01-12
```

This document clarifies some potentially confusing aspects of configuring Claude Code (when I say Claude moving forward, I mean Claude Code). It is a _rapidly_ evolving tools, so standards change quickly, and some ideas get abandoned leaving duplicate or obsolete configuration options. Thus, this is here as a living document to help clarify the current state of the tool for me and anybody else who stumbles upon it.

The frontmatter above indicates how fresh this document is.

## LSPs

- Claude requires LSPs to be wrapped in 'plugins' for now.
  - Many common ones are available through Anthropic's official plugin 'marketplace', but if you want to hook up other LSPs, you have to create your own local marketplace and then put plugin(s) in it.
  - Alternatively, you can add a 3rd party marketplace URL in the Claude settings, and then install plugins from there.
  - LSP plugins are really simple JSON files that describe how to call the LSP, so the security risk of adding random commands from a 3rd party GitHub repo doesn't make a lot of sense to me.
  - I just created a local marketplace called 'winnie-plugs' that contains a single plugin called 'custom-lsps', which then describes all the servers not covered by the official marketplace (Fish, Deno, Docker Compose, etc - there are a lot).

## Skills

- Skills are the primary construct Claude uses at present to extend functionality.
- They combine some of what people were using MCP servers for, some of the 'slash command'-like functionality, and some of what subagents do (MCP and subagents can be bundled into skills)
- They are essentially dynamically accessible context and tools bundled into one (cleaner) construct.
- For example, a skill might be called "Val Town Deno Development" - this would contain a SKILL.md that describes when to use it, how to write good idiomatic Deno scripts (including user preferences and Val Town platform specific), how to call `deno` and `vt` CLI commands, and include the Val Town MCP server and some basics of how to use that as well.
- A user could then say something like:

```markdown
Use the /val-town-deno-development skill to create a Deno script on Val Town that emails me a roundup of Hacker News articles I might be interested in every morning at 8am.
```

- This a highly specific task with very specific syntax, special APIs specific to Val Town, and specific user preferences (email address, topics of interest, etc) that the main Claude model would struggle with. At the same time, it's unlikely that a user would be doing this kind of thing enough to create a full-fledged subagent for it, and the Val Town MCP server is better than a more customized set of tools that a user might construct on their own.
- A Skill is a better construct here, temporarily making a model better a specific task within a larger workflow.
- Some other example skills to illustrate the idea:
  - Git Rebasing - coding models are very good at this, but users often have preferences or project requirements around how to rebase, and a skill could encapsulate those preferences and project requirements. Making a subagent just for rebases would be overkill.
  - Fish Function Development - Fish is popular, but nowhere near as ubiquitous as Bash or Zsh. A skill that encapsulates Fish syntax, best practices, where to fetch docs, common commands, and user preferences around how to write Fish functions would be very useful for users who want to leverage Fish without having to teach the model Fish from scratch every time.
