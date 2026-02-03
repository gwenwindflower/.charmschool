function opm --description "Search and retrieve 1Password API credentials via fzf"
    argparse h/help e/echo v/vault= -- $argv
    or return

    if set -q _flag_help
        echo "Usage: opm [OPTIONS]"
        echo ""
        echo "Search 1Password items and retrieve credentials"
        echo ""
        echo "Options:"
        echo "  -h, --help         Show this help message"
        echo "  -e, --echo         Echo credential instead of copying to clipboard"
        echo "  -v, --vault VAULT  Specify vault (default: Personal)"
        echo ""
        echo "Examples:"
        echo "  opm                    # Search Personal vault, copy to clipboard"
        echo "  opm --echo             # Search and echo credential"
        echo "  opm --vault Work       # Search Work vault"
        return 0
    end

    # Default vault
    set -l vault $OP_DEFAULT_VAULT
    if set -q _flag_vault
        set vault $_flag_vault
    end

    # List items from vault and present in fzf (showing only title)
    # Filter to only items with a 'credential' field (API keys, tokens, etc)
    set -l selected (op item list --vault "$vault" --format json 2>/dev/null | \
        jq -r '.[] | select(.category == "API_CREDENTIAL") | "\(.id)\t\(.title)"' | \
        fzf --no-multi \
            --no-preview \
            --delimiter '\t' \
            --with-nth 2 \
            --prompt "1Password ($vault) > " \
            --header "Select item (Enter to confirm)")

    # Check if user cancelled
    if test -z "$selected"
        logirl error "User cancelled selection"
        return 1
    end

    # Extract ID from selection (first field)
    set -l item_id (string split \t $selected)[1]

    # Retrieve credential
    set -l credential (op read "op://$vault/$item_id/credential" 2>&1)

    if test $status -ne 0
        echo "Error retrieving credential: $credential" >&2
        return 1
    end

    # Output based on flag
    if set -q _flag_echo
        echo $credential
    else
        echo -n $credential | pbcopy
        echo "✓ Credential copied to clipboard" >&2
    end
end
