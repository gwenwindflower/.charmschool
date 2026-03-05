function _wrap_op_interactive -d "Prepend 1Password env wrapper to the current command line - for use with keybind"
    argparse a/app -- $argv
    or return
    set -l prefix 'op run --env-file=$OP_ENV_DIR/global.env --no-masking -- '
    # Use opo function which matches command to its matching env file
    if set -q _flag_app
        set prefix "opo "
    end
    set -l current (commandline)
    commandline -r "$prefix$current"
    commandline -C (string length "$prefix$current")
end
