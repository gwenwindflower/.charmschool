function ftka -d "Set Kitty as the default app for one or more file types, specified by extension."
    argparse d/dry-run r/role= h/help -- $argv

    set -l role all

    if set -q _flag_help
        echo "Set Kitty as the default app for one or more file types, specified by extension."
        logirl help_usage "ftka <extension1> [extension2...]"
        logirl help_flag d/dry-run "Show the duti commands that would be executed without making any changes."
        logirl help_flag r/role=ROLE "Specify a role for the duti command. Accepted values: $(set_color green)'viewer'$(set_color normal), $(set_color green)'editor'$(set_color normal), $(set_color green)'all'$(set_color normal) (default is 'all')."
        logirl help_flag h/help "Show this help message."
        return 0
    end

    if test (count $argv) -eq 0
        logirl error "No extensions provided, requires as least one."
        logirl help_usage "ftka <extension1> [extension2...]"
        return 1
    end

    if set -q _flag_role
        switch $_flag_role
            case viewer editor all
                set role $_flag_role
            case '*'
                logirl error "Invalid role: $_flag_role. Accepted values: $(set_color green)'viewer'$(set_color normal), $(set_color green)'editor'$(set_color normal), $(set_color green)'all'$(set_color normal) (default is 'all')."
                return 1
        end
    end

    for ext in $argv
        if string match -r --quiet '^\.' $ext
            logirl error "Invalid syntax: $ext. Do not include the dot with the file type extension (e.g., json not .json)"
            return 1
        end
        if not string match -r --quiet '^[a-zA-Z0-9]+$' $ext
            logirl error "Invalid extension: $ext. Extension should contain only letters and numbers."
            return 1
        end
        if set -q _flag_dry_run
            echo "duti -s net.kovidgoyal.Kitty $ext $role"
        else
            duti -s net.kovidgoyal.Kitty $ext $role
        end
    end
end
