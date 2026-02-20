function ops --description "Search and retrieve 1Password API credentials via fzf"
    argparse r/read f/field= v/vault= h/help -- $argv
    or return

    if set -q _flag_help
        echo "Usage: ops [OPTIONS]"
        echo ""
        echo "Interactively retrieve 1Password item info via fzf"
        echo ""
        echo "Options:"
        echo "  -h, --help         Show this help message"
        echo "  -v, --vault VAULT  Specify vault (default: dev)"
        echo "  -f, --field FIELD  Specify field to retrieve (default: credential)"
        echo ""
        echo "Examples:"
        echo "  opm                    # Search default vault (dev)"
        echo "  opm --vault Personal       # Search vault called 'Personal'"
        return 0
    end

    # Default vault
    set -l vault dev
    if set -q _flag_vault
        set vault $_flag_vault
    end

    # List items from vault and present 'title' field in fzf
    # Filtered to only show the API_CREDENTIAL category, which contains keys, tokens, etc.
    # By default these have a 'credential' field, for non-standard field names in the category use the --field option
    set -l selected_item (op item list --vault "$vault" --format json 2>/dev/null | \
        jq -r '.[] | select(.category == "API_CREDENTIAL") | "\(.id)\t\(.title)"' | \
        fzf --no-multi \
            --no-preview \
            --delimiter '\t' \
            --with-nth 2 \
            --prompt "1Password ($vault) > " \
            --header "Select item (Enter to confirm)")

    if test -z "$selected_item"
        logirl error "User cancelled selection"
        return 1
    end

    # Extract id and name from selection
    set -l item_id (string split \t $selected_item)[1]
    set -l item_name (string split \t $selected_item)[2]

    set -l item_uri "op://$vault/$item_id/credential"
    if set -q _flag_field
        set item_uri "op://$vault/$item_id/$_flag_field"
    end

    if set -q _flag_read
        if set -l credential $(op read $item_uri)
            echo -n $credential | pbcopy
            logirl success "Copied credential for: $item_name"
            return 0
        else
            logirl error "Failed to read credential for: $item_name"
            return 1
        end
    end
    echo -n $item_uri | pbcopy
    logirl success "Copied URI for: $item_name"
end
