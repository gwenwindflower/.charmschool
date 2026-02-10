function _wrap_echo -d "Wraps current command line content in an echo statement"
    # TODO: Make a visual selection version of this
    set -l prefix 'echo "'
    set -l suffix '"'
    set -l current (commandline)
    commandline -r "$prefix$current$suffix"
    commandline -C (string length "$prefix$current")
end
