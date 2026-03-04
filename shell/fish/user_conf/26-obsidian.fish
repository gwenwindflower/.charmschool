# Obsidian now ships with a CLI that works with a running app instance
# the 'obsidian' bin is at the path below
# we use the '-a' flag to append it
# as we don't want it coming before `mise`, our last addition (in 19-mise.fish)
# it's a very unique and low-priority path (the only bin here is 'obsidian')
# so it's easiest to just append it rather than break our file patterns
# by putting it elsewhere
fish_add_path -a /Applications/Obsidian.app/Contents/MacOS
# This is not to be confused with 'obsidian-cli', installed by Homebrew
# which operates on static files and doesn't require a running app instance
