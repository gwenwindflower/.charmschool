function mep -d "Copy the current command to the clipboard and ask GPT-4o to explain it"
    set -l clipboard (pbpaste)
    if not mods -m sonnet "Can you explain this code? $clipboard" | glow
        echo "Error: Failed to run mods"
        return 1
    end
end
