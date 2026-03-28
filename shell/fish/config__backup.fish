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
