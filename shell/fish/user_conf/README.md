# Fish User Configuration

Most files are well-commented, with effort made to name and lay things out to be self-explanatory, but some unique features of this fish config are covered here.

## Modular Structure

> [!IMPORTANT]
> After some recent profiling, I discovered these file loops were slowing down shell startup, as fish has to stat every file before loading. I've condensed all of them into a single config.fish, and it did noticeably improve startup time. So, a potential to support this modular structure is a function that 'compiles' all the fragments into a single file after changes, so we can maintain the clear modular approach, but get the performance of the single file flat config. That draft function is currently called confcomp.fish. For now, I'm testing if it's annoying maintaining the big file, and thus worth going down that road, or if it will be easier to just stick with a single file.

Rather than one big `config.fish` file, this repo breaks configuration into purpose-scoped files with numerical prefixes.

- 0n 'namespace' is the core, basic environment - things that should always be defined for the shell to function properly. For example, instantiating the PATH variable and setting core env vars like EDITOR, PAGER, TERM, SHELL, etc. It's also where we set up global package managers (right now, that's just Homebrew), git, container integrations, and AI agent configs (as they can be run as headless processing nodes).
- 1n 'namespace' is language-specific configuration - each language gets its own file, for example 13-python.fish is where we configure uv. Both 0n and 1n are always loaded via conditional for loops in config.fish.
- 2n 'namespace' is interactive tooling configs - split up by tool or function (e.g., 21-prompt and 26-mux are functional groupings, whereas 24-zoxide and 25-fzf define major tools with important configs). The conditional for loop that loads the 2n files is run inside a `status is-interactive` block, so these are only loaded for interactive shells.

The only code in the config.fish file itself is the conditional for loops loading their respective namespaces. This systems makes it extremely easy to pull up the right configs for editing and review, as well as control what gets loaded when.

## conf.d

Any settings that need to be established as early as possible, before the config.fish user conf kicks in, need to be placed in the conf.d directory. This is often things like setting a boolean env var to disable a default behavior that we want to override later in the user config.

At present, this is just disabling Homebrew's auto-activation of mise for fish shell.
