function v -d "If supplied a directory, z to it and open nvim, otherwise just open nvim in the current directory"
    if test (count $argv) -eq 0
        nvim
    else if test (count $argv) -gt 1
        echo "Too many arguments. Usage: v [directory]"
    else
        z $argv[1]; and nvim
    end
end
