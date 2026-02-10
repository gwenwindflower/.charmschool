function _wrap_op -d "Prepend 1Password env wrapper to the current command line"
    # TODO: Make a visual selection version of this
    set -l prefix 'op run --env-file=$OP_GLOBAL_ENV --no-masking -- '
    set -l current (commandline)
    commandline -r "$prefix$current"
    commandline -C (string length "$prefix$current")
end
