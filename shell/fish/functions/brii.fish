function brii -d "Install package with Homebrew, only if command is not found"
    if test (count $argv) -ne 1
        logirl error "Usage: brii <package-name> - only 1 package at a time."
        return 1
    end
    if type -q $argv[1]
        echo "$argv[1] is already installed."
    else
        echo "$argv[1] not found. Installing..."
        brew install $argv[1]
    end
end
