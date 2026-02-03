---
name: gitignore
description: Generate advanced and comprehensive .gitignore files based on project type, using stringent syntax for selecting and excluding files and directories.
---
# .gitignore Creation and Management

## Templates and Initial Scaffolding

The GitHub CLI (`gh`) has a `gh repo gitignore` command that can be used to fetch templates from GitHub's collection. `gh repo gitignore list` will output the list of templates in GitHub's collection to stdout. When you have the name of the one you want, use `gh repo gitignore view [TEMPLATE]` to have the content output to stdout, which you can redirect to a `.gitignore` file or wherever you need it. This is the easiest way to spike out the boilerplate for a given project type.

The rest of the Skill covers manually adding entries in gitignore syntax for the specific project you're working in.

## `/path` vs `path/` vs `path`

| Pattern | Meaning |
| --------- | --------- |
| `path/` | Matches a **directory** named `path` (and its contents) |
| `path` | Matches both **files AND directories** named `path` |
| `/path` | Matches `path` **relative to the .gitignore file's location** (anchored path) |

**Examples:**

- `build/` ignores the `build` directory and all its contents
- `build` ignores any file or directory named `build` anywhere in the tree
- `/build` ignores only the `build` directory in the same folder as the .gitignore

## Wildcard/Globbing Patterns

Git uses fnmatch-style patterns:

| Pattern | Matches |
| --------- | --------- |
| `*` | Any sequence of characters (except `/`) |
| `**` | Any sequence of directories (including zero) |
| `?` | Any single character |
| `[abc]` | Any one character in the set |
| `[a-z]` | Any one character in the range |

**Examples:**

- `*.log` ignores all `.log` files
- `**/node_modules` ignores `node_modules` at any depth
- `src/*.js` ignores `.js` files directly in `src/`
- `file?.txt` matches `file1.txt`, `file2.txt`, etc.
- `a/**/b` matches `a/b`, `a/x/b`, `a/x/y/b`
- `/**/b` matches `b` anywhere in the tree

## Negation and Special Patterns

| Pattern | Purpose |
| --------- | --------- |
| `!pattern` | **Negates** — re-includes previously ignored files |
| `#` | Comment line |
| `\` | Escape character for literal patterns |

**Example:**

```gitignore
# Ignore all .log files
*.log

# But not this specific one
!important.log
```
