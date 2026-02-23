# Navigate+Open launcher function, a helper for other functions, aliases, bindings, and abbreviations
# basically a streamlined call to zoxide + yazi/nvim/whatever you want for edge cases
function zex -d "Fuzzy navigate to a directory then take an action (file explorer or editor by default)"
    argparse h/help e/editor a/action= -- $argv
    or return

    if set -q _flag_help
        echo "Usage: zex [options] fuzzy_search_terms..."
        echo "  All non-flag args are hierarchical z search terms"
        echo ""
        echo "Options:"
        echo "  -h, --help            Show this help"
        echo "  -e, --editor          Open with nvim instead of file explorer"
        echo "  -a, --action=ACTION   Take another action after navigating (overrides explorer/editor)"
        echo ""
        echo "Examples:"
        echo "  zex config fish auto        # z config fish auto + open explorer"
        echo "  zex -e dev project api      # z dev project api + open editor"
        return 0
    end

    set -l here (pwd)
    set -l z_search $here

    if test (count $argv) -eq 0
        echo "Error: No search terms provided"
        return 1
    else
        set -l clean_args
        # sanitize args
        for arg in $argv
            set -a clean_args (string replace -r -m 1 '^~' $HOME $arg)
        end
        set z_search $clean_args
    end

    # z_search is initilized as pwd, if it's not updated by the args, we exit
    if test $z_search = $here
        echo "Error: search was set to current directory, you're already here!"
        return 1
    end

    # z doesn't exist on PATH until zoxide's shell setup runs
    # but it's fine, it exists!
    # @fish-lsp-disable-next-line
    if z $z_search
        # Post-navigation actions
        if set -q _flag_action
            command $_flag_action
        else if set -q _flag_editor
            opo nvim
        else
            # Otherwise, open file explorer
            if not test (type -q yazi) -a (type -q ff)
                logirl error "No file explorer found (requires yazi and the ff wrapper function)"
                return 127
            end
            ff
        end
    end
end
