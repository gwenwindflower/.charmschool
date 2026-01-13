function v -d "If supplied directory search terms, z to it and open nvim, otherwise just open nvim in the current directory"
    if test (count $argv) -eq 0
        nvim
    end
    if test (count $argv) -eq 1
        if test -f $argv[1]
            nvim $argv[1]
        else
            z $argv[1]; and nvim
        end
    end
    if test (count $argv) -gt 1
        echo $(set_color -o red)"[ERROR]$(set_color normal)$(set_color red): Too many arguments supplied.$(set_color normal) Please provide only one directory to z into or file name to open directly."
        echo $(set_color green)"Usage: v [directory or file name]$(set_color normal)"
        echo "Flexible nvim launcher, uses zoxide to quickly navigate to directories, directly opens files, or launches nvim in current working directory if called without arguments."
        return 1
    end
end
