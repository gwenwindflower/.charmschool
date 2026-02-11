# Fish User Configuration for AI Agents

Most files are well-commented, with effort made to name and lay things out to be self-explanatory, but some unique features of this fish config are covered here.

## Modular Structure

Rather than one big `config.fish` file, this repo breaks configuration into purpose-scoped files with numerical prefixes.

- 0n 'namespace' is the core, basic environment - things that should always be defined for the shell to function properly. For example, instantiating the PATH variable and setting core env vars like EDITOR, PAGER, TERM, SHELL, etc. It's also where we set up global package managers (right now, that's just Homebrew), git, container integrations, and AI agent configs (as they can be run as headless processing nodes).
- 1n 'namespace' is language-specific configuration - each language gets its own file, for example 13-python.fish is where we configure uv. Both 0n and 1n are always loaded via conditional for loops in config.fish.
- 2n 'namespace' is interactive tooling configs - split up by tool or function (e.g., 21-prompt and 26-mux are functional groupings, whereas 24-zoxide and 25-fzf define major tools with important configs). The conditional for loop that loads the 2n files is run inside a `status is-interactive` block, so these are only loaded for interactive shells.

The only code in the config.fish file itself is the conditional for loops loading their respective namespaces. This systems makes it extremely easy to pull up the right configs for editing and review, as well as control what gets loaded when.

## Paging and Printing

The core pager is `moor` (formerly 'moar'), a more feature-rich and modern alternative to `less`. We also replace `cat` with its much more powerful alternative `bat`, which has great built-in syntax highlighting.

Mostly these just work, but it's important to understand bat's 'auto-paging', which is actually very simple. `bat` actually _always_ sends to pager (if `--paging=auto`, which is the default, or `--paging=always`), the only difference is that the default 'auto' behavior, if it detects `PAGER` is set to `less` (most people), it also sends `less`'s `quit-if-one-screen` option (and some other related configs) so that it _appears_ to intelligently output to pure `bat` for shorter content, and only pipe it's syntax-highlighted output to the pager for larger output (when in fact it is always piping it to the pager). Because our `PAGER` is set to `moor`, we have to manually set the `quit-if-one-screen` flag to get the default 'auto' behavior. This does mean though that `bat`'s ``--paging=[auto|always]` essentially does nothing, as we've set the downstream flag it usually pivots on.

This is fine, as this is almost always the desired behavior, but if we need to change it for a certain use case, we can remove the `quit-if-one-screen` flag from `moor`'s default config (this is equivalent to `bat`'s 'always', any content length will be paged), or set `bat` to `--paging=never` to have bat pipe directly to stdout no matter the content length. The rest of moor's default configs are just to make the UI as minimal as possible, as line numbers and the menu bar can be easily toggled on with a single keypress if they're needed (which they're usually not).

## conf.d

Any settings that need to be established as early as possible, before the config.fish user conf kicks in, need to be placed in the conf.d directory. This is often things like setting a boolean env var to disable a default behavior that we want to override later in the user config.

At present, this is just disabling Homebrew's auto-activation of mise for fish shell.
