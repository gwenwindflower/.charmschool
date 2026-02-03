# Markdown Code Blocks

Code blocks must always specify a language identifier. This is required by standard markdownlint rules (MD040).

## Rule

Always use a language after the opening triple backticks:

````markdown
```typescript
const x = 1;
```
````

Never leave code blocks without a language:

````markdown
```
const x = 1;
```
````

## Use `text` for Non-Code Content

For content that isn't code but needs monospace formatting (file trees, diagrams, ASCII art, generic output), use `text`:

````markdown
```text
project/
├── src/
│   ├── index.ts
│   └── utils/
├── tests/
└── package.json
```
````

This satisfies markdownlint while clearly indicating the block isn't executable code.
