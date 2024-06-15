function v -d "If supplied a directory, z to it and open nvim, otherwise just open nvim in the current directory"
    if test (count $argv) -eq 0
        nvim
    else
        z $argv[1]; and nvim
    end
end
