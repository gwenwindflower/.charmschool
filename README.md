# ✨💄 Welcome, girly! 💅🏻✨

<img src="https://github.com/gwenwindflower/charm-school/assets/91998347/2fcf9f7b-9f00-43e4-ac94-e8dc8439f896" alt="Charm School banner" width=500px />

You've found yourself at Charm School, an elegant dotfile repo to get your terminal and editor into form for data work. This is an _opinionated_ set of dotfiles that is easy to install, but I will endeavor to explain these opinions and purpose via extensive commenting and documentation. I welcome issues and PRs to add docs and explanation for specific areas.

I see this repository as useful mainly for folks who (sanely) don't enjoy gardening their dotfiles, want a general framework to start from, and are comfortable editing the defaults and ripping out what they don't like. Particularly, if you do data work, are comfortable with the command line, and want to use vim, this could be a good starting point for you.

This is only tested on my personal 2020 MacBook Pro and my work 2022 M2 Macbook Pro, running recent versions of MacOS. Don't install these dotfiles on anything but recent versions of MacOS. There's no easy way to undo the install yet if you don't like the settings. I hope in the future to add more optional paths, CI, uninstall scripts, and customizable install options to share this with a larger audience in a more robust way, but until that day, send your computer to Charm School at your own risk.

## 📚 Table of Contents

1. [How to work with this repo](#how-to-work-with-this-repo)
2. [Terminal configs](#terminal)
3. [Neovim configs](#neovim)

## How to work with this repo

These dotfiles are managed and executed by a Rust tool called `rotz`. It's a nice middle ground between the somewhat janky all-in-one-file config of `dotbot` and the over-engineered complexity of `chezmoi`. I like it because it's super simple and easy to understand, but also allows you to break your dotfiles into multiple files and directories, which is good for organization and readability.

### Do the thing

You'll need to install `rotz` to use this repo. You can do that with `cargo` if you have a Rust setup (if you do, I recommend using `cargo`) or Homebrew if you don't (it will install Rust via Homebrew, just be aware of that. I don't really like Homebrew installing my language compilers, but if setting up Rust directly feels intimidating it's totally fine!):

```bash
cargo install rotz
# or
brew install rotz
```

Then you can clone this repo and run `rotz` to install the dotfiles:

```bash
rotz link && rotz install
```

`rotz` won't overwrite existing symlinks by default (which are likely in place from elsewhere if you manage your dotfiles via symlinks already), so if you do want it to do that, use the `--force` flag:

```bash
rotz link --force && rotz install
```

### ✌🏻 A note on vim

I learned to code in vim. It's what the senior engineers at the company I first worked at did, and they made me work in it to get their help. I'm deeply grateful they did this (thanks [@ebenoist](https://github.com/ebenoist) 💗). Vim as a philosophy is initially intimidating, but elegant and fast when you get used to it. That said, I'm not a vim evangelist. I use it because I enjoy it, and you _definitely_ don't have to use vim to be a 'real coder' (🤢 at this concept). Many, many engineers and data scientists much better than me use VSCode or other editors, and those tools are amazing too.

That said, you should be excited to walk the path of vim to use these dotfiles or you will be fighting against the flow of all the configurations.

### Other recommend tools not configured here

I use VSCode sometimes and I like it a lot, but it feels like Microsoft really wants you to use their cloud settings sync, and it's easier to just go with that flow for me, so I don't manage those settings in this repo anymore.

I also heavily, heavily recommend [Raycast](https://www.raycast.com/) but they also maintain a great cloud settings sync system, and many of its plugins have access to sensitive data and workflows, so it's easier to keep it out of this repo. You should really use it though!

## Terminal

I love the terminal a weird amount. It really does something for my neurodivergent brain. It feels fast, clean, colorful, creative, powerful, expressive, and uniform all at the same time, in a very special way that really gets my serotonin flowing. I use [kitty](https://sw.kovidgoyal.net/kitty/) as my terminal emulator, [oh-my-zsh](https://ohmyz.sh/) as my zsh framework, [Starship](https://starship.rs/) as my prompt, and [Homebrew](https://docs.brew.sh/Installation) as my package manager.

One of the reasons I like a terminal-focused approach is an ability to stay "Hands on Keyboard" (HOK) as much as possible, which is categorically faster. I also find that the more I can do in the terminal, the more I can automate, script, and keymap, which gets me into flow state faster and keeps me there longer. This is not only good for productivity, but more importantly mental health and feeling fulfilled by that productivity. Lastly, the terminal, and tools based in the terminal like vim, tend to be highly customizable, so I can form my work environment around my ever-changing needs and tastes rather than molding myself to the work.

### Kitty

Look, it's called 'kitty' and it has a cute cat icon. That should be enough. On top of that though, it actually happens to be one of the fatest terminal emulators available, has outstanding font support including ligatures, is highly extensible and customizable, image support, and tons of other cool features. [The creator and maintainer](https://github.com/kovidgoyal) is also extremely passionate and responsive, you can tell he really loves this project. This is always a really good sign for the long term health of an open source project.

My kitty configuration is found in the `kitty` directory of this repo. It's one file called `kitty.conf`. I don't have a ton of customizations, my main ones of note are designating the [Ellograph CF](https://connary.com/ellograph.html) font (using Thin as my standard font and Light as my bold font — I prefer my text very light) from the excellent independent fontsmith Connary Fagen (you need to purchase this font if you want to use it, it's not included in this repo, support independent font makers!), which I've patched with [Nerd Fonts](https://www.nerdfonts.com/) (I'll add more on how to do this soon) and setting the color scheme to [Catppucin Frappe](https://github.com/catppuccin/catppuccin) (this is my vim colorscheme as well and set everywhere possible). I also have a few aesthetic settings to get rid of the MacOS menu bar and make the tab bar look a little more stylish. Lastly, I have a few keybindings to make it easier to switch tabs, windows, and panes and resize panes in a coherent way. My kitty.conf includes all of the default boilerplate which shows you all available settings and values commented out, so if you look at that file you can see all the settings that _aren't_ commented, that's what I've changed and set.

### Oh My Zsh

Oh My Zsh! or `oh-my-zsh` is a framework for zsh. What this means essentially is it provides some extra functionality out-of-the-box and an easier means of adding plugins and customizing your shell. Some engineers complain that it's a little 'heavy', particularly those that obsess over shell performance, but that's not really my bag, and I find it easy to use. I don't do a ton with it, the biggest thing is the list of plugins you'll find in my [`zshrc` file](https://github.com/gwenwindflower/charm-school/blob/58d7d692c7a8440984e65f239668c139365bf284/zshrc#L98C1-L99C1).

These add some extra commands and functionality for tools I use a lot like python, brew, and git. I also use the `alias-finder` plugin to help me remember all of the stuff it adds, a lot of which are aliases to save you some typing.

### Starship prompt

A prompt is the thing you type commands into in your terminal emulator. By default they're usually very basic, maybe just a symbol indicating where you are in the terminal. You can really kit these out though with lots of useful information and metadata. I think Starship is the best one currently available. It's super easy to configure with a simple `starship.toml` file, and it's written in Rust, so it's very fast and efficient. It comes with a lot of built-in support for popular tools and languages and good defaults, so my `starship.toml` is fairly short.

I've disabled some of the big cloud provider integrations, as they're ever-present even though I'm typically working locally. I've also configured it to use emojis in a few places for some extra vibes. Lastly, I've extended the command timeout to allow for some longer running commands.

### Homebrew

Homebrew is a package manager originally for MacOS, but now also for Linux. It lets you install system wide packages and tools easily and robustly. Think things like a CLI tool for listening to Spotify that aren't scoped to a specific project. Or compilers like golang's `go`. Or system utilities like `htop` and `neofetch`. It even, through its `cask` functionality lets you install GUI apps like `raycast`. It's a great way to version control, manage, and keep up to date a lot of the 'global' tools you use in your workflow. So it's super useful for a lot of things, but one of its benefits is also that it makes setting up a fresh computer a breeze. You can just run `brew bundle` and it will install everything you need from a `Brewfile` that you can keep in your dotfiles repo.

You'll see two Brewfiles in this repo. One for a 'fresh-mac' and one for a 'dev-container'. `Brewfile-fresh-mac` contains everything I want and use on my computer. I use it to keep my machines consistent and up-to-date. `Brewfile-dev-container` is for things like GitHub Codespaces or Gitpod, where I just want some key terminal-based tools that I rely on like [difftastic](https://github.com/Wilfred/difftastic).

### zsh config files

There's quite a bit of config in my zsh files: `.zshrc`, `.zshenv`, and `.zshprofile`, as well as the `shell/scripts` folder that contains a lot of the aliases and functions I've customized. These files are where I set up my PATH, environment variables, and initialize shell plugins. It's heavily commented for readability.

## Neovim

[Neovim](https://neovim.io/) (often called by its terminal command `nvim`) is a fork of [Vim](<https://en.wikipedia.org/wiki/Vim_(text_editor)>) that's been modernized and has a lot of cool features and improvements. It's backwards compatible with (the somewhat esoteric) Vimscript, but importantly, new plugins and configuration can be directly written using [Lua](https://www.lua.org/), which is much, much easier (imo) to read and write. My setup uses lua plugins and config whenever possible, and I generally try to avoid plugins that haven't been written in Lua specifically for nvim for the sake of future maintainability. At this point in the nvim ecosystem, most important and popular plugins have improved Lua-based options that target nvim specificaly, so I have yet to find any issues with this approach.

I use Neovim for all my coding and writing, and I've set it up to be a very comfortable and productive environment for me. The vast majority of my nvim setup is handled by the [LazyVim](https://www.lazyvim.org/) framework, which aims to provide an advanced IDE-like experience out-of-the-box while still being completely customizable.

### LazyVim

[LazyVim](https://www.lazyvim.org/) — created by nvim plugin builder [folke](https://github.com/folke) — is a framework for Neovim that provides a wealth of useful features and plugins out-of-the-box. It's designed to be a complete, cohesive IDE-like experience, but still be completely customizable. It's a great way to get started with Neovim, and is a great way to learn how to configure and extend Neovim. Among the many things it provides is an excellent implementation of the complex knot of plugins and config required to create an [Intellisense](https://learn.microsoft.com/en-us/visualstudio/ide/using-intellisense?view=vs-2022)-like experience for snippets, LSP navigation, LSP completions, and AI Copilot completions. You don't have to really think about to get all these things working together, which is very welcome. At the same time, you can also easily extend and customize these features to your heart's content. I highly recommend it, and it's the base config for my Neovim setup. Most of the customization in these dotfiles is to extend and tweak LazyVim to support data work, coding in various languages, and Markdown authoring, as well as to fit some of my personal preferences around keybindings.

> [!TIP]
> MacOS set a lot of global shortcuts for things like Mission Control by default, if a LazyVim keybinding isn't working it's worth checking your MacOS settings to see if it's being eaten by the OS. For example, MacOS defaults to using `Ctrl+up` and `Ctrl+down`, which conflicts with LazyVim's window size keybindings. You can remap these, but I prefer to just disable them in MacOS settings. In general I've found any time a keybinding isn't working in my terminal it's usually because of a conflict with something.
