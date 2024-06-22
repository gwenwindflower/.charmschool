function mip -d "Use `mods` to offer suggestions for improving the contents of the clipboard with GPT-4o"
    set -l clipboard (pbpaste)

    if not mods -m sonnet "How would you improve this code? $clipboard" | glow
        echo "Error: Failed to run mods."
        return 1
    end
end
