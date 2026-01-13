function open_mac_library -d "Open the user's Library folder on macOS with Finder"
    set -l library_path "$HOME/Library"
    if test -d "$library_path"
        open -R "$library_path"
    else
        echo "Library folder not found."
    end
end
