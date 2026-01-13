# `vim` remains unmapped, in case I need to use vanilla vim for some reason
function vi -d "Pass-through to nvim" -w nvim
    nvim $argv
end
