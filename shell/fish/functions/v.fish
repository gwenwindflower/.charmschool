function v -d "Navigate with zoxide to common directories and launch nvim"
    if test (count $argv) -eq 0
        opo nvim
    end
    if test (count $argv) -eq 1
        if test -f $argv[1]
            opo nvim $argv[1]
        else
            # z is instantiated by zoxide's shell integration,
            # so fish-lsp can't see it
            # @fish-lsp-disable-next-line
            z $argv[1]; and opo nvim
        end
    end
    if test (count $argv) -gt 1
        logirl error "Too many arguments supplied.$(set_color normal) Please provide only one directory to z into or file name to open directly."
        logirl help_usage "v $(set_color brmagenta)[existing path]$(set_color normal)"
        logirl "Flexible nvim launcher, uses zoxide to quickly navigate to directories, directly opens files, or launches nvim in current working directory if called without arguments."
        return 1
    end
end
