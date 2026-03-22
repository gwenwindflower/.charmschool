# Yazi Plugin Development

Yazi is Rust-based command line file explorer with a built-in plugin system that allows users to extend its functionality using Lua. Yazi is extremely well-engineered, using a virtual file system, async processes wherever possible, and an event model that allows deeply flexible behavior through emitting and reacting to events.  This document provides an overview of how to develop custom Yazi plugins, and at the end of the document, the specific implementation details of all custom plugins developed as part of this dotfiles repo are available.

Yazi plugins are installed to `~/.config/yazi/plugins/<name>.yazi`. They can be added manually, but the preference is to use Yazi's `ya` command line tool (`ya pkg add <github_user/plugin_repo_name>`, other expected package manager subcommands are available as well: `ya pkg remove`, `ya pkg list`, etc.). This is how all third-party plugins are installed in this repo.

Custom plugins developed specifically for these dotfiles are stored at `tools/yazi/plugins/<name>.yazi/` and are symlinked to the target `~/.config/yazi/plugins/` directory individually via rotz.

## Plugin Structure

Each plugin is a directory named `<name>.yazi/` containing at minimum a `main.lua` entry point. The entry point exports a table:

```lua
return {
  entry = function(self, job)
    local mode = job.args[1] -- first arg after `--` in keymap
    -- ...
  end,
}
```

Keybindings invoke plugins via `plugin <name> -- <args>` in `keymap.toml`.

## Sync vs Async (Critical Concept)

Plugins run **asynchronously** by default. This means:

- You **cannot** access `cx` (application state) directly in async code
- You **must** use `ya.sync()` to read state like hovered items, selections, cwd
- `ya.sync()` calls must be declared at **top level** (not inside conditionals)

### The Sync/Async Boundary

Only "sendable" values can cross the boundary between sync and async contexts:

| Crosses boundary | Does not cross |
| --- | --- |
| `nil`, `boolean`, `number`, `string` | Userdata (except `Url`) |
| `Url` objects | Functions |
| Tables of the above | Complex nested objects |

**Practical consequence:** stringify `Url` objects with `tostring()` before returning from `ya.sync()` if you need them in async code. While `Url` technically crosses the boundary, converting to string is simpler and avoids ownership transfer issues.

### Pattern: Sync State Reader

```lua
local get_context = ya.sync(function()
  -- cx is available here
  local hovered = cx.active.current.hovered
  local cwd = tostring(cx.active.current.cwd)

  if not hovered then
    return nil, cwd, nil, "empty"
  end

  return tostring(hovered.url), cwd, hovered.cha.is_dir, nil
end)

-- async code calls the sync reader
local url, cwd, is_dir, err = get_context()
```

## Key Globals

### `cx` (sync only)

Application state. Key paths:

- `cx.active` — current tab (`tab::Tab`)
- `cx.active.current` — current folder (`tab::Folder`)
- `cx.active.current.hovered` — hovered file or `nil` (`fs::File?`)
- `cx.active.current.cwd` — current directory (`Url`)
- `cx.active.selected` — selected files (`tab::Selected`, supports `#` for count and `pairs()` for iteration)

### `ya` (async safe)

Utility functions:

- `ya.sync(fn)` — wrap a function to access `cx` from async context
- `ya.emit(cmd, args)` — send commands to Yazi (e.g., `ya.emit("shell", { cmd, block = true })`)
- `ya.notify({ title, content, level, timeout })` — show notification (`level`: `"info"`, `"warn"`, `"error"`)
- `ya.quote(str)` — shell-escape a string for safe command construction
- `ya.target_os()` — returns `"macos"`, `"linux"`, etc.

### `Command` (async)

Run external processes:

```lua
local output = Command("git")
  :arg { "rev-parse", "--show-toplevel" }
  :cwd(cwd_string)
  :output()

if output and output.status.success then
  local stdout = output.stdout:gsub("%s+$", "")
end
```

Args can be supplied with two different syntaxes: `Command("<cmd>"):arg("arg1"):arg("arg2")` or `Command("<cmd>"):arg { "arg1", "arg2" }` (Note that it's 'arg', *not* 'args', and the space before the brackets, also that the brackets are *not* wrapped in parentheses). The latter is more concise when supplying multiple args, but Lua formatters tend to 'correct' it by wrapping the brackets in parentheses and removing the space, which breaks the plugin completely. Given that, you should always chain the single arg parentheses syntax, even for multiple args, to avoid automatic formatting and linting issues.

Key methods: `:arg()`, `:cwd()`, `:env()`, `:stdout()`, `:output()` (capture all), `:status()` (exit code only).

## Launching UI Processes

Use `ya.emit("shell", ...)` with `block = true` to hand terminal control to a UI (e.g., Lazygit, Neovim, fzf, etc.). Yazi suspends its TUI, then resumes when the blocking process exits:

```lua
local cmd = string.format("$EDITOR %s", ya.quote(path))
ya.emit("shell", { cmd, block = true })
```

Non-blocking shell commands can also be used for processes that can happen in the background.

## LSP Warnings

LuaLS will flag `ya`, `cx`, `Command`, `Status`, `ui`, etc. as undefined globals — these are Yazi runtime globals injected into the plugin environment, not standard Lua. This is expected and safe to ignore.

## Adding a New Plugin

1. Create `tools/yazi/plugins/<name>.yazi/main.lua`
2. Add keybinding(s) in `tools/yazi/keymap.toml`
3. Add symlink in `tools/yazi/dot.yaml`: `plugins/<name>.yazi: ~/.config/yazi/plugins/<name>.yazi`
4. Run `dot -l tools/yazi` to create the symlink

## References

- Yazi plugin docs: <https://yazi-rs.github.io/docs/plugins/overview>
- Yazi plugin API (utils): <https://yazi-rs.github.io/docs/plugins/utils>
- Yazi plugin API (context): <https://yazi-rs.github.io/docs/plugins/context>

---

## Dotfiles Custom Plugins

### `editor.yazi`

Opens `$EDITOR` from Yazi with proper terminal blocking. Two modes dispatched via argument:

- **`edit`** (`e` key) — open hovered item in `$EDITOR`. Directories open as projects, files open directly.
- **`git-root`** (`E` key) — find git repo root via `git rev-parse --show-toplevel`, open `$EDITOR` there.

**Why this exists:** Yazi's 'opener' system is flexible for taking different actions based on filetype and URl - you can handle 'opening' a CSV differently in a project vs. `$XDG_CONFIG_HOME` for example, and opening a FLAC file could be completely different, causing it to start playing in cmus for example. All of this from the same 'open' keybinding. This is a different behavior altogether: we want to open *projects* in nvim (or the `$EDITOR` of choice), and projects are not a native construct in Yazi.

**Implementation notes:**

- A single `ya.sync()` function (`get_context`) extracts the hovered URL, cwd, and `is_dir` flag, since `cx` is only available in sync context. Returns 4 values: `url, cwd, is_dir, reason`.
- The `cwd` is needed for the `git-root` mode to run `git rev-parse` in the right directory
- **cwd alignment:** In `edit` mode, when the hovered item is a directory, the plugin emits `ya.emit("cd", { url })` before opening the editor. This moves Yazi into the project directory so the shell spawned for `$EDITOR` inherits the correct cwd. Without this, terminals opened inside the editor (e.g., via `:terminal` or a terminal plugin) would land in the parent directory instead of the project root. Yazi processes emitted events sequentially, so the `cd` completes before the `shell` command runs.
- The `git-root` mode doesn't need an explicit `cd` — it passes the git root path directly to `$EDITOR`, which sets its own cwd to that directory.
- Multi-select guard: if `#cx.active.selected > 0`, shows a warning instead of proceeding (avoids ambiguity about which item to open)
- Empty directory guard: if `cx.active.current.hovered` is `nil`, shows a warning
- Uses `ya.quote()` around paths to handle spaces and special characters
- `block = true` in `ya.emit("shell", ...)` is essential — without it, Yazi and the editor fight for terminal control
