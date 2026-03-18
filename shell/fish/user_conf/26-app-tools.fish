set -gx OBSIDIAN_HOME "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
set -gx OBSIDIAN_DEFAULT_VAULT $OBSIDIAN_HOME/girlOS
# Obsidian now ships with a CLI that works with a running app instance
# the 'obsidian' bin is at the path below
# we use the '-a' flag to append it so mise can stay our last addition (in 19-mise.fish)
# it's a unique and low-priority path (the only bin here is 'obsidian')
# so it's fine to put at the back of the PATH
fish_add_path -a /Applications/Obsidian.app/Contents/MacOS
# Monodraw also has a CLI bundled in its app contents
fish_add_path -a /Applications/Monodraw.app/Contents/Resources/monodraw
