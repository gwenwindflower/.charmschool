# Context7 CLI

Semantic search for documentation context covering most major tools, continually updated.

**IMPORTANT**: Context7 also manages Agent Skills — DO NOT use it for this. We have our own tools for that. It will install them in an inaccessible location that is incompatible with our tools. Only use Context7 for searching documentation.

## Basic Commands

```text
library [options] <name> [query]    Resolve a library name to a Context7 id (SvelteKit, shadcn/ui, etc.)
docs [options] <libraryId> <query>  Query the documentation for a specific library
whoami                              Show current login status
```

If the OAuth token is not available and whoami is not showing logged in, alert user to fix it.

## Examples

```bash
bunx ctx7 library react "how to use hooks"
bunx ctx7 docs /facebook/react "useEffect examples"
```
