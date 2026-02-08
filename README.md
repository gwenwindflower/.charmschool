# Welcome to Charm School

Charm School is an opinionated macOS dotfiles repo for a terminal-forward, Neovim-first workflow (with a strong bias toward data/analytics work). It’s designed for people who want a setup that’s cohesive and documented, but don’t want dotfiles to become a second job.

This repo tries to be:

* **Easy to apply** (repeatable, mostly one-command installs)
* **Easy to understand** (configs live next to the tool they affect, with commentary)
* **Easy to edit** (rip out what you don’t like, keep what you do)

**Target platform:** macOS only (Intel + Apple Silicon).  
If you’re not on recent macOS, please don’t treat this as plug-and-play.

> There isn’t a polished “undo/uninstall” path yet. Send your computer to Charm School at your own risk.

## Table of contents

* [Quick start](#quick-start)
* [How this repo works (rotz + dots)](#how-this-repo-works-rotz--dots)
* [Repo layout](#repo-layout)
* [Day-to-day commands](#day-to-day-commands)
* [Terminal stack](#terminal-stack)
* [Neovim stack](#neovim-stack)
* [Safety notes](#safety-notes)
* [Contributing](#contributing)

## Quick start

I highly recommend reading the full README before applying these dotfiles, but here’s the basic commands you would run on a fresh macOS machine.

### 1) Bootstrap a fresh machine (recommended)

`bootstrap.sh` is the “new Mac” entrypoint. It installs, in order: **Rust → rotz → Homebrew → Fish**.

```sh
sh bootstrap.sh
```

Notes:

* The script should be **idempotent** (safe to re-run), but still: don’t run it on production machines.
* After bootstrap, this repo expects **Fish** to exist and be usable.

### 2) Apply the dotfiles

We have a custom Fish wrapper command to make Rotz a bit safer and nicer to use:

```fish
dot -a    # run rotz install + link for ALL dots
```

Or use raw rotz if you'd prefer:

```sh
rotz link [args]
rotz install [args]
```

If you’re intentionally overwriting existing symlinks (e.g., if you changed the name of the file in the repo that will get linked out):

```sh
rotz link --force
```

## How this repo works (rotz + dots)

Charm School is managed by **rotz**, a Rust-based dotfiles manager that supports hierarchical configuration.

Core ideas:

* Any directory containing a `dot.yaml` is a **dot** (an installable unit).
* Dots typically define:
  * `links:` symlinks to create
  * `installs:` commands to run
  * `depends:` dependencies
* `defaults.yaml` provides inherited defaults for subdirectories (when a sub-dot sets keys to `null`).

Many items are just a directory containing a single `dot.yaml` file with one `installs: null` line, inheriting a default Homebrew install command, but this lets you see all the tooling at a glance, cleanly and clearly, without opening any files. You also never have to wonder where the configs for a given tool live, the file tree shows you directly.

References:

* rotz docs: <https://volllly.github.io/rotz/docs>

## Repo layout

High-level map (configs live alongside the tool they configure):

```text
bootstrap.sh      # fresh machine bootstrap (Rust → rotz → Homebrew → Fish)
config.yaml       # rotz project config (including Fish shell_command)
AGENTS.md         # agent-facing guidance (also good human guidance)
README.md         # this file

agents/           # coding agent CLIs + their configs (MCP servers, plugins, Skills, etc)
apps/             # GUI apps via Homebrew casks
tools/            # CLI/TUI tools via Homebrew formulae
shell/            # Fish, kitty, starship (everything terminal-related)
editor/           # Neovim (LazyVim), plugins, snippets (if you use Cursor or VSCode, they would go here)
lang/             # language tooling (organized by programming language - WIP as we shift to mise)
git/              # git tooling/config
fonts/            # fonts installed via casks (no licensed fonts committed)
.claude/          # project-scoped Claude Code configs (v useful stuff here if you're a Claude user)
```

If you’re adding something new, put it in the matching top-level category and keep `dot.yaml` concise.

## Day-to-day commands

### Prefer the Fish wrappers

Where available, prefer `dot` over raw rotz:

* `dot` supports safer “all” behavior (explicit `-a/--all`)
* typically includes dry-run and better help text

Common patterns:

```fish
dot -l editor/nvim              # (re)link just neovim config
dot -i tools/ripgrep            # install one tool dot
dot -a                          # link + install everything (explicit)
```

Raw rotz equivalents:

```sh
rotz link [path...]
rotz install [path...]
```

### A note on Fish (important)

rotz install hooks run in **Fish** (configured in `config.yaml`). That means shell commands in Rotz files must use Fish syntax. If you don't want ot use Fish htis is rpobably not the right dotfiles for you. That said, I encourage you to give Fish a try—it's a breath of fresh air compared to bash/zsh, instead of archaic syntax, it feels like writing with an expressive scripting language. This is why you see so many custom Fish functions in the `shell/fish/functions` directory, they are easy and delightful to write, you can essentially make highly customized, lightweight CLI tools for your anything in your workflow with minimal effort.

Quick reminders:

* `test -d ...` (not `[[ -d ... ]]`)
* `type -q cmd` (not `command -v cmd`)
* `set var value` (not `VAR=value` - use `set -gx` for globally available env vars)

Fish docs: <https://fishshell.com/docs/current/index.html>

## Terminal stack

The “current state” terminal setup:

* **Kitty** terminal emulator
* **Fish** as the primary shell
* **Starship** prompt
* **Homebrew** packages manager for both system-wide CLI tools and GUI apps
* A “make it nice everywhere” theme approach (cohesive Catppuccin Frappe where supported) - we find it worth taking time to make the environment where you spend most of your time visually pleasant and satisfying to use

Configs live under `shell/` (and apps/tools installs live under `apps/` and `tools/`).

## Neovim stack

Charm School’s editor setup is:

* **Neovim** configured under `editor/nvim`
* **LazyVim** as the base distribution/framework
* Customizations primarily in:
  * `editor/nvim/lua/plugins/` (plugin specs and tweaks)
  * `editor/nvim/lua/config/keymaps.lua`
  * `editor/nvim/snippets/`

Guideline: before adding config, check whether LazyVim already does it. Redundant config is the easiest way to make Neovim feel haunted. At present, Neovim plugins are organized into functional areas (UX, AI, language support, etc) instead of per-plugin - as lazy.nvim's merge-style config system and LazyVim's excellent defaults make this possible - and given how obscure Neovim plugin names can be, this makes it easier to find and adjust related settings (instead of "Hmm, is this Typescript LSP issue I'm having because of nvim-lspconfig, mason, or conform? Let's open up 3 buffers and find out" You know it's somewhere in lang.lua).

LazyVim docs: <https://www.lazyvim.org/>
lazy.nvim docs (the package manager for LazyVim, useful for understanding the config spec for specifying and customizing plugins): <https://lazy.folke.io/>

### A note on Vim

You don’t need to use Vim to be a “real” anything. Thankfully AI has probably put the "Editor Wars" to rest forever, but I just want to go on record as saying the whole "VSCode isn't a serious editor, vim is the true way" thing was always silly, and Cursor has hopefully shown the truth of that. For the most part you should be able to swap out the `editor/` directory with your preference and use the rest, if you don't want to use vim. All that said though - I learned to code in Vim, it's in my bones, it feels like home. Even in this new AI-assisted world, I find the speed, power, and unlimited customization/extensibility of Neovim to be the best environment for building software. If you're interested in learning Vim, I think it's worth it. My favorite recommendation to build up the initial muscle memory is [Vim Adventures](https://vim-adventures.com/) - it's a game that teaches you Vim commands as you play, and it's a lot more fun than just reading a cheat sheet. Basically, it's SNES Zelda crossed with Vim practice, and once it feels fluid to move through that, you should be good to go!

## Safety notes

Please read `AGENTS.md` if you’re using any coding agent tools with this repo—it’s the canonical “how not to break the house” guide.

Highlights:

* Don’t commit secrets/tokens/keys. Ever.
* Don’t delete `dot.yaml` files casually (it breaks rotz structure).
* Be intentional with `rotz link --force`.
* Don’t edit symlinked targets directly—edit the source in this repo.

## Contributing

Issues and PRs are welcome, especially for:

* Documentation improvements
* More “why” comments near confusing settings
* Making bootstrap/install flows more reliable and testable

You can also free to recommend new tools or a different approach, just know this will always be first and foremost my personal dotfiles repo, so I may not accept everything!

Preferred PR content:

* short summary + rationale
* manual verification steps
* macOS version tested
* screenshots for visual changes (terminal/editor)

---

Whether you choose to fully use these dotfiles or just borrow some ideas, I hope they help you create a cozy and delightful home in your terminal, good luck!
