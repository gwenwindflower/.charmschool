---
name: deno-cliffy-cli
description: >
  Build CLI tools in Deno using the Cliffy command framework.
  Use when: (1) Creating a new CLI tool or adding subcommands in Deno,
  (2) Working with deno.json task definitions alongside a Cliffy CLI,
  (3) Structuring a Deno project with commands/ directory pattern.
---

# Deno Cliffy CLI

Build structured CLI tools in Deno with typed options, help text, and subcommands using `@cliffy/command` from JSR.

## Quick Start

Add to `deno.json`:

```json
{
  "imports": {
    "@cliffy/command": "jsr:@cliffy/command@^1.0.0-rc.7"
  }
}
```

Minimal CLI:

```typescript
#!/usr/bin/env -S deno run --allow-all
import { Command } from "@cliffy/command";

const cli = new Command()
  .name("mytool")
  .version("0.1.0")
  .description("What the tool does");

cli
  .command("greet")
  .description("Say hello")
  .option("-n, --name <name:string>", "Who to greet", { default: "world" })
  .action(({ name }) => {
    console.log(`Hello, ${name}!`);
  });

await cli.parse(Deno.args);
```

## Project Structure

For CLIs with multiple commands, use a `commands/` directory:

```text
project/
├── cli.ts           # Entry point, wires up commands
├── commands/
│   ├── build.ts     # export async function build(...)
│   ├── deploy.ts    # export async function deploy(...)
│   └── test.ts      # export async function runTests(...)
├── lib/             # Shared utilities
│   └── helpers.ts
└── deno.json        # Tasks + imports
```

Each command file exports a single async function. The CLI entry point imports and wires them.

## Key Patterns

### Lazy Imports for Heavy Dependencies

When a command depends on something heavy (Playwright, Puppeteer, large npm packages), use dynamic import in the action handler. This prevents loading the dependency for unrelated commands.

```typescript
cli
  .command("scrape")
  .action(async ({ output }) => {
    const { scrape } = await import("./commands/scrape.ts");
    await scrape(output);
  });
```

Critical when dependencies read env vars or spawn processes at import time.

### deno.json Task Integration

Wire subcommands to `deno task` with per-command permissions:

```json
{
  "tasks": {
    "cli": "deno run --allow-all cli.ts",
    "build": "deno run --allow-read=. --allow-write=. cli.ts build",
    "scrape": "deno run --allow-all cli.ts scrape"
  }
}
```

Use `--allow-all` only when genuinely needed. Pass extra flags with `--`: `deno task build -- --watch`.

### npm Packages in Deno

Import npm packages via `npm:` specifier or map them in `deno.json`:

```json
{
  "imports": {
    "handlebars": "npm:handlebars@^4.7.8"
  },
  "nodeModulesDir": "auto"
}
```

Set `"nodeModulesDir": "auto"` when npm packages need to read their own files from disk (templates, assets, partials). Without this, packages using `__dirname` or `fs.readFileSync` relative to their install path will fail.

## Reference

For detailed API patterns (option types, command nesting, global options, error handling), see the [Patterns Reference Guide](patterns.md).
