function ff -d "Launch yazi and exit into the directory you navigated to in yazi"
    # This logic is replicated in ee.fish - if updates are made here,
    # consider making them there as well

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
