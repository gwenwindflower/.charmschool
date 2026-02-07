# 0*-namespace is always loaded core environment configurations
# and system-wide tooling that affects PATH or env vars,
# like AI, containers, package managers, etc.
for file in $__fish_config_dir/user_conf/0*.fish
    source $file
end

# 1*-namespace is language setup, mostlu adding things to PATH
# the few things outside of that are generally wrapped with their
# own internal is-interactive block
for file in $__fish_config_dir/user_conf/1*.fish
    source $file
end

# 2*-namespace is interactive tooling, prompts, abbreviations, 
# bindings, themes, navigation, finders, editors etc.
if status is-interactive
    for file in $__fish_config_dir/user_conf/2*.fish
        source $file
    end
end

# TODO: eliminate 'git' fish plugin in favor of custom functions/abbreviations
# it seems to be no longer developed, and it's really pretty legible stuff
# it's not like any of the git functionality it wraps is changing anytime soon
# so it will be better to just have the most useful aliases and helper functions
# directly in repo (also `fisher` just puts the stuff in .config/fish/functions anyway
# which is a symlink into this repo so truly no different
