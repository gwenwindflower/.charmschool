# Cliffy Patterns Reference

## Import and Setup

```typescript
// deno.json imports
{
  "imports": {
    "@cliffy/command": "jsr:@cliffy/command@^1.0.0-rc.7"
  }
}
```

```typescript
import { Command } from "@cliffy/command";
```

## Root Command

```typescript
const cli = new Command()
  .name("mytool")
  .version("0.1.0")
  .description("What the tool does");

await cli.parse(Deno.args);
```

## Subcommands

Chain with `.command()`. Each subcommand gets its own options, description, examples, and action.

```typescript
cli
  .command("build")
  .description("Build the project")
  .option("-o, --output <path:string>", "Output directory", {
    default: "./dist",
  })
  .option("-w, --watch [watch:boolean]", "Watch mode")
  .example("Basic", "mytool build")
  .example("Custom output", "mytool build --output ./out")
  .action(async ({ output, watch }) => {
    // output is string, watch is boolean | undefined
    await doBuild(output, watch);
  });
```

## Option Types

Cliffy infers TypeScript types from the type annotation in the option string:

```typescript
.option("-p, --port <port:number>", "Port number")        // number
.option("-n, --name <name:string>", "Name")                // string
.option("-v, --verbose [verbose:boolean]", "Verbose mode") // boolean | undefined
.option("-t, --tags <tags:string[]>", "Tags list")         // string[]
```

- `<required>` — must be provided
- `[optional]` — may be omitted
- Defaults via `{ default: value }`

## Typed Option Access

Options are destructured from the action parameter with correct types:

```typescript
.option("-r, --resume <path:string>", "Resume file", { default: "./resume.json" })
.option("-s, --schema <path:string>", "Schema file", { default: "./schema.json" })
.action(async ({ resume, schema }) => {
  // resume: string, schema: string — types inferred from <path:string> + default
});
```

## Lazy Imports for Heavy Dependencies

When a subcommand depends on a heavy module (e.g. Playwright), use dynamic import in the action to avoid loading it for other commands:

```typescript
cli
  .command("scrape")
  .description("Scrape data (requires Chrome)")
  .action(async ({ output }) => {
    const { scrape } = await import("./commands/scrape.ts");
    await scrape(output);
  });
```

This is critical when dependencies read env vars or spawn processes at import time (Playwright does both).

## deno.json Task Integration

Wire subcommands to `deno task` with appropriate permissions:

```json
{
  "tasks": {
    "cli": "deno run --allow-all cli.ts",
    "build": "deno run --allow-read=. --allow-write=. cli.ts build",
    "deploy": "deno run --allow-all cli.ts deploy"
  }
}
```

Use `--allow-all` only when the subcommand genuinely needs broad permissions (e.g. Playwright). Prefer granular permissions for everything else.

Pass additional flags through tasks with `--`:

```bash
deno task build -- --watch --output ./custom
```

## Shebang for Direct Execution

```typescript
#!/usr/bin/env -S deno run --allow-all
```

Then `chmod +x cli.ts` and run directly: `./cli.ts build`

## Command Groups and Nesting

Commands can be nested for complex CLIs:

```typescript
const db = new Command()
  .description("Database operations")
  .command("migrate", "Run migrations")
  .action(async () => { /* ... */ })
  .command("seed", "Seed data")
  .action(async () => { /* ... */ });

cli.command("db", db);
```

## Global Options

Options on the root command are available to all subcommands:

```typescript
const cli = new Command()
  .globalOption("-q, --quiet [quiet:boolean]", "Suppress output")
  .action(function () { this.showHelp(); });
```

## Error Handling Pattern

```typescript
.action(async (options) => {
  try {
    await doWork(options);
  } catch (err) {
    console.error(`❌ ${(err as Error).message}`);
    Deno.exit(1);
  }
});
```
