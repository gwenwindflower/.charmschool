fish_add_path $HOMEBREW_PREFIX/opt/ruby/bin
# NOTE: rv is in early development, and still missing a lot of features
# so we keep Homebrew Ruby cooking above, and setup rv below
# will shift over to rv as it matures
$HOMEBREW_PREFIX/bin/rv shell init fish | source
