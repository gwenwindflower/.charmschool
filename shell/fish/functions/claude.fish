# opo wrapper
# we wrap the most common `op run`ified commands
# so that we get completions and normal behavior
# but the actual execution goes through op
function claude
    opo claude $argv
end
