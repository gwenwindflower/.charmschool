function ee -d "Edit or Explore, z to a directory, then open Yazi file explorer or nvim editor"
    argparse h/help e/editor a/action= -- $argv
    or return

    if set -q _flag_help
        echo "Usage: ee [options] fuzzy_search_terms..."
        echo "  All non-flag args are hierarchical z search terms"
        echo ""
        echo "Options:"
        echo "  -h, --help            Show this help"
        echo "  -e, --editor          Open with nvim instead of file explorer"
        echo "  -a, --action=ACTION   Take another action after navigating (overrides explorer/editor option)"
        echo ""
        echo "Examples:"
        echo "  ee config fish auto        # z config fish auto + open explorer"
        echo "  ee -e dev project api      # z dev project api + open editor"
        return 0
    end

    set -l here (pwd)
    set -l z_search $here

    if test (count $argv) -gt 0
        set -l clean_args
        # sanitize args
        for arg in $argv
            set -a clean_args (string replace -r -m 1 '^~' $HOME $arg)
        end
        set z_search $clean_args
    end

    # z doesn't exist on PATH until zoxide's shell setup runs
    # but it's fine, it exists!
    # @fish-lsp-disable-next-line
    if z $z_search
        # Post-navigation actions
        if set -q _flag_action
            command $_flag_action
        else if set -q _flag_editor
            nvim
        else
            if not type -q yazi
                logirl error "Requires Yazi explorer to be installed and on PATH for default action"
                return 127
            end
            # This is the same logic from ff.fish
            # but passing the call to another fish function messes up the directory tracking
            # If updates are made to the logic in either one consider updating the other as well

            # Create a temporary file for yazi to write the final directory path
            set -l tmp (mktemp -t "yazi-cwd.XXXXXX")

            # Launch yazi and capture the exit directory
            yazi $argv --cwd-file="$tmp"

            # If yazi wrote a valid directory different from our current location, navigate to it
            if read -z cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
                # Use Fish's cd (not builtin) to properly update directory history
                cd -- "$cwd"
            end

            # Clean up the temporary file
            rm -f -- "$tmp"
        end
    end
end
