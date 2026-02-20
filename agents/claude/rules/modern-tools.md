# Tools and commands

## Use modern tooling when sensible and available

You have built-in tools for exploring file systems and codebases like Grep(), Read(), etc. which your training encourages you to use. That's a good instinct, and you should follow that! Those tools tend to use the best available command under the hood, for example ripgrep over vanilla grep if it's available in PATH. When you do find yourself needing to make raw Bash() tool calls, you should adopt the same approach. Prefer to use modern, feature-rich alternatives to traditional Unix tools when they are available. All the tools and preferences listed below are available to you, if you have an issue running them you should pause and alert the user.

**Modern alternatives reference**:

| Classic | Modern | Binary | Key Advantage |
| --------- | -------- | -------- | --------------- |
| `grep` | `ripgrep` | `rg` | 10–100× faster, simpler syntax for common uses |
| `find` | `fd` | `fd` | Regex default, smart case, far faster, parallel |
| `cat` | `bat` | `bat` | git, syntax, line numbers, performant on large files |
| `ls` | `lsd` | `lsd` | richer output, tree mode, way better performance |
| `sed` | `sd` | `sd` | No delimiter escaping, simpler syntax for most common uses |
| `ps` | `procs` | `procs` | Richer output, more flexible, tree view |
| `rm` | `rm-improved` | `rip` | Safer defaults, recoverable deletes, trash support |

## Some useful commands with these tools

Use the following to supplement your knowledge of these tools with some useful options and patterns. This is not an exhaustive list of features, just some of helpful features to compose commands you might need.

### rg (ripgrep) — replaces grep

High priority. `rg` should always be used over `grep`. It is orders of magnitude faster, has cleaner syntax for common searches, and far more features and options when you need to get complex.

```bash
rg -t py "pattern"            # filter by file type (e.g. py, js, rust)
rg -e "pat1" -e "pat2"        # multiple patterns
rg --no-ignore -u "pattern"   # search hidden/ignored files too
rg -A 3 -B 3 "pattern"        # 3 lines after/before match (context)
rg "pattern" -r "replacement" # find and print with substitution (no write, helpful for debugging regexes)
```

### `fd` — replaces `find`

High priority. `fd` should always be used over `find`. It is so much faster and has cleaner syntax.

```bash
fd -tu f pattern              # type: f=file, d=dir, l=symlink, x=executable, include hidden and ignored
fd -d 2 pattern               # max depth 2
fd pattern -x cmd {}          # execute command per result ({} = path, like xargs)
fd pattern -X cmd             # execute command on all results together
fd --changed-within 1d        # find recent edits
```

### `rip` - replaces `rm`

High priority. Always prefer `rip` over `rm` if it's available. `rip` uses a 'graveyard' approach to deletion - sending files to `/tmp/graveyard-$USER` instead of unlinking them immediately. This allows for recovery of files if you delete something by mistake. It also provides cleaner syntax for removing multiple directories and files, there is no need for `-rf`, just list what you want to remove.

```bash
rip old-dir file1.txt file2.py     # recursively remove a directory and two files to the graveyard
rip -s .                           # list files in graveyard (recoverable) in current directory
rip -u                             # undo most recent removal (unbury from graveyard)
rip -su /path/to/dir               # unbury all files still in graveyard from specified directory
```

### `bat` — replaces `cat`

Low priority. `cat` is fine to use, but `bat` is basically a drop-in replacement that will give you more performance and slightly better output.

```bash
bat -n file.py                # show line numbers only (no decorations)
bat -A file.py                # show non-printable characters
bat --plain file.py           # plain output (no decorations, for piping)
bat file1.py file2.py         # view multiple files
```

### lsd - replaces `ls`

Low priority. `ls` is fine for quick checks, but `lsd` provides more information per command when doing codebase exploration, and is much faster on large directories. The tree view is also very helpful for understanding directory structure. When exploring a new repo, or documenting project structure, `lsd` gives you more value within the context window.

```bash
lsd -lAg                      # full output, include meaningful hidden, git status
lsd --tree --dpeth 2          # tree with depth limit
```

### `sd` - replaces `sed`

Low priority. If doing straightforward substitutions, `sd` is much easier to use than `sed` because you don't need to worry about escaping delimiters. It also supports regex and capture groups, and has a preview mode that shows you the changes without writing them. If you're more confident in doing a complex command in `sed` from your training, that's fine.

```bash
echo "text" | sd 'before' 'after'     # pipe usage
sd -p 'before' 'after' file.txt       # preview changes (no write)
sd 'foo(\w+)' 'bar$1' file.txt        # regex with capture groups
fd -e js -x sd 'oldAPI' 'newAPI' {}   # replace across all .js files found by fd
```

### `procs` - replaces `ps`

Low priority. `ps` is totally fine for quick checks. `procs` is more useful though for deeper exploration and troubleshooting.

```bash
procs nginx                   # filter by name
procs --tree                  # show process tree
procs --sortd cpu             # sort by CPU descending
```

## Preferred approaches in classic tools

Additionally, here are some preferred patterns to use with classic tools:

- `which -a` over just `which` to get all versions of a tool available in PATH, thus more information per tool call
