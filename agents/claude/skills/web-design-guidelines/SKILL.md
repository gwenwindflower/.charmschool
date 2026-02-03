---
name: web-design-guidelines
description: Review UI code for Web Interface Guidelines compliance. Use when asked to "review my UI", "check accessibility", "audit design", "review UX", or "check my site against best practices".
metadata:
  author: vercel
  version: "1.0.0"
---

# Web Interface Guidelines

Review a set of files for compliance with Web Interface Guidelines.

> [!NOTE]
> This Skill is maintained by Vercel. As I am not a frontend expert, I rely on there work keeping the fetchable list of guidelines up to date.

## How It Works

1. Fetch the latest guidelines from the source URL below (in the vercel-labs/web-interface-guidelines repo) - these are continually updated by Vercel
2. Ask user for files, directories, or glob patterns to target for review, the user must specify a subset of the codebase, or explicitly confirm a full audit
3. Apply edits and updates against the target files using all rules in the fetched guidelines
4. Output findings report in the terse `file:line` format specified in the fetched guidelines

## Guidelines Source

**Remember**: fetch fresh guidelines before each review:

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

Use WebFetch to retrieve the latest rules. The fetched content contains all the rules and output format instructions.

> [!IMPORTANT]
> Do not audit the entire codebase unless explicitly instructed by the user. Always confirm which files or patterns to review.
