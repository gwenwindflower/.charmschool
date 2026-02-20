function _wrap_op_interactive -d "Prepend 1Password env wrapper to the current command line - for use with keybind"
    # TODO: Make a visual selection version of this
    set -l prefix 'op run --env-file=$OP_ENV_DIR/global.env --no-masking -- '
    set -l current (commandline)
    commandline -r "$prefix$current"
    commandline -C (string length "$prefix$current")
end
