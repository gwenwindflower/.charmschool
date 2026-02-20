function envy -d "Interactively select op env vars to load into current shell session"
    argparse a/all dangerously-load-secrets h/help -- $argv
    or return

    if set -q _flag_help
        echo "Load env vars mapped to op URIs from an env file into the current session."
        logirl help_usage "envy [options] [ENV_FILE]"
        logirl help_header Options
        logirl help_flag h/help "Show this help message"
        logirl help_flag a/all "Skip selection and load the entire file"
        logirl help_flag dangerously-load-secret "Validate and load the actual secret value (Not recommended)"
        logirl help_header Details
        printf "  * Default env file is 'global', env file must exist in OP_ENV_DIR\n"
        printf "  * Do not include .env if passing an env file argument\n"
        logirl help_header Examples
        printf "  * Select env vars from default global.env file to load:\n    %s\n" "$(set_color brmagenta)envy$(set_color normal)"
        printf "  * Load all env vars from default global.env file:\n    %s\n" "$(set_color brmagenta)envy --all$(set_color normal)"
        printf "  * Load all env vars from an env file called cool_api.env:\n    %s\n" "$(set_color brmagenta)envy --all cool_api$(set_color normal)"
        printf "  * Selected env vars from default global.env file to load raw values into:\n    %s\n" "$(set_color brmagenta)envy --dangerously-load-secrets$(set_color normal)"
        return 0
    end

    if not set -q OP_ENV_DIR
        logirl error "OP_ENV_DIR is not set, is your environment configured properly?"
        return 1
    end

    set -l env_file "$OP_ENV_DIR/global.env"

    if test (count $argv) -gt 1
        logirl error "Too many arguments. Provide only one env file name (without .env) or none to use global.env, see 'envy --help' for usage details."
        return 1
    else if test (count $argv) -eq 1
        set -l env_file_name $argv[1]
        if string match -rq '\.env$' $env_file_name
            logirl error "Please provide the env file name without the .env extension, see 'envy --help' for usage details."
            return 1
        end
        set -l env_file_path "$OP_ENV_DIR/$env_file_name.env"
        if not test -f "$env_file_path"
            logirl error "Provided env file not found: $env_file_path"
            return 1
        end
        set env_file $env_file_path
    else
        # If still set to default global.env, check that it exists before proceeding
        if not test -f "$env_file"
            logirl error "Global env file not found: $env_file, check that OP_ENV_DIR is set correclty, and environment files are in the right place on your machine."
            return 1
        end
    end

    set -l cat_tool bat
    if not type -q $cat_tool
        set cat_tool cat
    end

    set -l valid_env_vars

    $cat_tool $env_file --color=never --style=plain | while read -l item
        # skip empty lines
        if test -z "$item"
            continue
        end

        # skip comments
        if string match -rq '^\s*#' $item
            continue
        end

        # split line into name and value on first '='
        set -l item_name (string split -m 1 = $item)[1]
        set -l uri (string split -m 1 = $item)[2]

        # validate env var name format (all caps, underscores)
        if not string match -rq '^[A-Z_][A-Z0-9_]*$' $item_name
            logirl warning "Skipping invalid env var name: $item_name"
            continue
        end

        # validate 1Password URI format (op://vault/item/field OR setting to another env var)
        if not test (string match -rq '^op://.+/.+/.+$' $uri) -o (string match -rq '^\$[A-Z_][A-Z0-9_]*$' $uri)
            logirl warning "Skipping invalid op URI: $uri"
            continue
        end
        set -a valid_env_vars $item_name
    end

    set -l env_var_selection $valid_env_vars
    # If called without --all, re-set to a selection via gum choose prompt
    # Otherwise continue with the full list assigned above
    if not set -q _flag_all
        set env_var_selection (gum choose --no-limit $valid_env_vars)
    end

    for var in $env_var_selection
        set -l uri (string split -m 1 = (grep "^$var=" $env_file))[2]
        if test -n "$uri"
            if set -q _flag_dangerously_load_secrets
                set -gx "$var" (op read $uri)
                logirl success "Loaded $var from env file with raw value ($(set_color --bold red)be careful$(set_color normal))"
                return 0
            else
                set -gx "$var" "$uri"
                logirl success "Loaded $var from env file as 1Password URI"
            end
        end
    end
end
