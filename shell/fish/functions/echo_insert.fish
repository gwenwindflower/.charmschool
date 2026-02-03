function echo_insert -d "Designed for keybind, to instantly set up an echo command with cursor inside quotes"
    commandline -i 'echo ""'
    commandline -f backward-char
end
