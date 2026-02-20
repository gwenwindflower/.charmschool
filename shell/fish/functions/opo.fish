function opo -d "Run a command via 'op run' with a tool-scoped env file matching the command name"
    if test (count $argv) -eq 0
        logirl error "Requires at least a command name as the first argument"
        echo "Runs <command> via 'op run' using \$OP_ENV_DIR/<command>.env"
        logirl help_usage "opo <command> [args...]"
        return 1
    end

    set -l cmd_name $argv[1]
    if not type -q $cmd_name
        logirl error "The command '$cmd_name' was not found, please check your PATH"
        return 1
    end

    if not set -q OP_ENV_DIR
        logirl error "The OP_ENV_DIR variable is not set"
        return 1
    end

    set -l env_file "$OP_ENV_DIR/$cmd_name.env"
    if not test -f $env_file
        logirl error "Corresponding env file not found: $env_file"
        return 1
    end

    op run --env-file=$env_file --no-masking -- $argv
end
