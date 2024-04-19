# *•.¸♡ *•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡ extra special zsh config ♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*
# The `.zshenv` file is a configuration file for the Z shell (Zsh) that is
# always sourced, regardless of whether the shell is interactive or not. It is
# the first configuration file that Zsh reads when starting up. The `.zshenv`
# file is typically used to set environment variables that should be available
# to all scripts and programs run by the shell, not just interactive sessions.
# This includes setting the `PATH`, `EDITOR`, `PAGER`, and other global
# environment variables. The `.zshenv` file is sourced before any other Zsh
# configuration files, so it can be used to set variables that may be needed by
# those files. It should be kept minimal and only contain essential environment
# setup.
# *•.¸♡ *•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡ extra special zsh config ♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*

# Use extended glob patterning
setopt extendedglob

# Import personal aliases and functions
source "${HOME}/.env"
source "${HOME}/scripts/gh_copilot.sh"
source "${HOME}/scripts/utils.sh"
source "${HOME}/scripts/dbt_scaffolding.sh"
source "${HOME}/scripts/dsl.sh"

# Path to oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
export ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"
export ZSH_COMP="${HOME}/.oh-my-zsh/completions"

# Set $SHELL because it gets overriden with Bash in Codespaces
export SHELL=/bin/zsh

# We got all the colors in kitty bb
export TERM=xterm-256color

# Preferred editor for local and remote sessions
export EDITOR='nvim'
# example of how to set up a conditional EDITOR
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='nvim'
