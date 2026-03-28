function prx -d "Manage mitmproxy environment and SSL certificates"
    argparse h/help c/cert -- $argv
    or return

    if set -q _flag_help
        echo "Manage mitmproxy environment and SSL certificates."
        logirl help_usage "prx [COMMAND] [OPTIONS]"
        logirl help_header Commands
        printf "  $(set_color --bold)on$(set_color normal)          Set global proxy and NODE_EXTRA_CA_CERTS\n"
        printf "  $(set_color --bold)off$(set_color normal)         Unset proxy environment variables\n"
        printf "  $(set_color --bold)run$(set_color normal)         Run a command with proxy env + Node CA\n"
        printf "  $(set_color --bold)curl$(set_color normal)        Execute curl with mitmproxy certificate\n"
        printf "  $(set_color --bold)cert$(set_color normal)        Manage mitmproxy SSL certificates\n"
        printf "  $(set_color --bold)status$(set_color normal)      Show proxy and environment status\n"
        logirl help_header Options
        logirl help_flag h/help "Show this help message"
        logirl help_flag c/cert "Manage SSL certificate (behavior depends on command)"
        logirl help_header Examples
        printf "  prx on              # Enable global proxy\n"
        printf "  prx on -c           # Enable proxy and add cert\n"
        printf "  prx off             # Disable proxy and remove cert\n"
        printf "  prx run npm test    # Run command with proxy\n"
        printf "  prx curl example.com # Curl with mitm cert\n"
        printf "  prx cert add        # Add SSL cert to keychain\n"
        printf "  prx status          # Check proxy status\n"
        return 0
    end

    set -l command $argv[1]

    # Default to status if no command given
    if test (count $argv) -eq 0
        set command status
    end

    switch $command
        case on
            _prx_enable $argv[2..]
            if set -q _flag_cert
                if set -q MITM_CERT_TRUSTED
                    logirl warning "mitmproxy certificate is already available, skipping cert add"
                else
                    _prx_cert add
                end
            end
            _prx_status
        case off
            _prx_disable
        case run
            if set -q _flag_cert
                _prx_cert add
            end
            _prx_run $argv[2..]
        case curl
            if set -q _flag_cert
                _prx_cert add
            end
            _prx_curl $argv[2..]
        case cert
            if set -q _flag_cert
                logirl warning "-c/--cert flag is redundant with the cert subcommand"
            end
            _prx_cert $argv[2..]
        case status
            if set -q _flag_cert
                logirl warning "-c/--cert is a no-op with status"
            end
            _prx_status
        case '*'
            logirl error "Unknown command: $command"
            printf "Try: prx --help\n"
            return 1
    end
end

function _prx_check_running -d "Check if mitmproxy is running"
    if not pgrep -q mitm
        logirl warning "mitmproxy is not running"
        logirl info "Start mitmproxy first (e.g., 'mitmproxy' or 'mitmweb')"
        return 1
    end
    return 0
end

function _prx_enable -d "Enable global proxy environment variables"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Enable global proxy environment variables."
        logirl help_usage "prx on [OPTIONS]"
        logirl help_header Options
        logirl help_flag h/help "Show this help"
        return 0
    end

    if not _prx_check_running
        return 1
    end

    if set -q HTTPS_PROXY
        logirl warning "Proxy environment variables already set, skipping re-set"
        return 0

    else
        set -gx HTTP_PROXY http://localhost:8080
        set -gx HTTPS_PROXY http://localhost:8080
        set -gx http_proxy http://localhost:8080
        set -gx https_proxy http://localhost:8080
        set -gx NODE_EXTRA_CA_CERTS $HOME/.mitmproxy/mitmproxy-ca-cert.pem
        logirl success " Global proxy enabled"
        return 0
    end
end

function _prx_disable -d "Disable proxy environment and remove SSL certificate"
    if not set -q HTTPS_PROXY
        logirl warning "Proxy appears to be off already, skipping unset"
    else
        set -e HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NODE_EXTRA_CA_CERTS
        logirl success "󰹏 Proxy environment disabled"
    end
    _prx_cert rm
    _prx_status
    return 0
end

function _prx_run -d "Run command with proxy environment variables"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Run a command with proxy environment variables."
        logirl help_usage "prx run [OPTIONS] <command> [args...]"
        logirl help_header Options
        logirl help_flag h/help "Show this help"
        logirl help_header Examples
        printf "  prx run npm test\n"
        return 0
    end

    if test (count $argv) -lt 1
        logirl error "No command specified"
        printf "Try: prx run --help\n"
        return 1
    end

    if not _prx_check_running
        return 1
    end

    # Run command with proxy env vars in local scope
    env HTTP_PROXY=http://localhost:8080 \
        HTTPS_PROXY=http://localhost:8080 \
        http_proxy=http://localhost:8080 \
        https_proxy=http://localhost:8080 \
        NODE_EXTRA_CA_CERTS=$HOME/.mitmproxy/mitmproxy-ca-cert.pem \
        $argv
end

function _prx_curl -d "Execute curl with mitmproxy certificate"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Execute curl with mitmproxy certificate and proxy."
        logirl help_usage "prx curl [OPTIONS] <url> [curl-args...]"
        logirl help_header Options
        logirl help_flag h/help "Show this help"
        logirl help_header Examples
        printf "  prx curl https://example.com\n"
        printf "  prx curl -I https://api.github.com\n"
        return 0
    end

    if test (count $argv) -lt 1
        logirl error "No URL specified"
        printf "Try: prx curl --help\n"
        return 1
    end

    if not type -q curl
        logirl error "curl not found in PATH"
        return 127
    end

    if not _prx_check_running
        return 1
    end

    set -l cert_path $HOME/.mitmproxy/mitmproxy-ca-cert.pem
    if not test -f $cert_path
        logirl error "Certificate not found at $cert_path"
        logirl info "Start mitmproxy to generate certificate"
        return 1
    end

    curl -x localhost:8080 --cacert $cert_path $argv
end

function _prx_cert -d "Manage mitmproxy SSL certificates"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Manage mitmproxy SSL certificates in macOS keychain."
        logirl help_usage "prx cert <add|rm>"
        logirl help_header Commands
        printf "  $(set_color --bold)add$(set_color normal)  Add certificate to system keychain\n"
        printf "  $(set_color --bold)rm$(set_color normal)   Remove certificate from system keychain\n"
        logirl help_header Options
        logirl help_flag h/help "Show this help"
        return 0
    end

    set -l action $argv[1]
    set -l cert_path $HOME/.mitmproxy/mitmproxy-ca-cert.pem
    set -l keychain ~/Library/Keychains/login.keychain-db

    if test (count $argv) -ne 1
        logirl error "Specify one action: add or rm"
        printf "Try: prx cert --help\n"
        return 1
    end

    if not test $action = add; and not test $action = rm
        logirl error "Invalid action: $action"
        printf "Use: add or rm\n"
        return 1
    end

    if not test -f $cert_path
        logirl error "Certificate not found at $cert_path"
        logirl info "Start mitmproxy to generate certificate"
        return 1
    end

    switch $action
        case add
            logirl info "Adding mitmproxy certificate to user keychain..."
            security add-trusted-cert -d -k $keychain -p ssl -p basic $cert_path 2>/dev/null
            if test $status -eq 0
                set -gx MITM_CERT_TRUSTED 1
                logirl success "Certificate added"
            else
                logirl warning "Failed to add certificate (may already be trusted)"
            end
        case rm
            if test -n "$(security find-certificate -a -c mitmproxy ~/Library/Keychains/login.keychain-db)"
                logirl info "Removing mitmproxy certificate from user keychain..."
                security remove-trusted-cert -d $cert_path
                security delete-certificate -c mitmproxy ~/Library/Keychains/login.keychain-db
                if test $status -eq 0
                    set -e MITM_CERT_TRUSTED
                    logirl success "Certificate removed"
                else
                    logirl warning "Failed to remove certificate (may not be in keychain)"
                end
            else
                logirl warning "Certificate already untrusted and/or removed, or it was never added, skipping removal"
            end
    end
end

function _prx_status -d "Show proxy and environment status"
    echo ""

    # Check if proxy is responding
    if curl -s -o /dev/null --connect-timeout 1 -x localhost:8080 http://example.com 2>/dev/null
        set_color --bold magenta
        echo "    ▘▗         "
        echo " ▛▛▌▌▜▘▛▛▌ ▛▌▛▌"
        echo " ▌▌▌▌▐▖▌▌▌ ▙▌▌▌"
        set_color normal
        echo ""
        printf "Proxy is "
        set_color --bold brgreen
        printf RUNNING
        set_color normal
        printf " on localhost:8080\n"
    else
        set_color --bold brblack
        echo "    ▘▗       ▐▘▐▘"
        echo " ▛▛▌▌▜▘▛▛▌ ▛▌▜▘▜▘"
        echo " ▌▌▌▌▐▖▌▌▌ ▙▌▐ ▐ "
        set_color normal
        echo ""
        printf "Proxy is "
        set_color --bold red
        printf "NOT RUNNING"
        set_color normal
        printf " on localhost:8080\n"
    end

    echo ""
    set_color --bold
    printf "Environment variables:\n"
    set_color normal

    if set -q HTTP_PROXY
        printf "  HTTP_PROXY  = "
        set_color cyan
        printf "%s\n" $HTTP_PROXY
        set_color normal
    else
        printf "  HTTP_PROXY  = "
        set_color brblack
        printf "(not set)\n"
        set_color normal
    end

    if set -q HTTPS_PROXY
        printf "  HTTPS_PROXY = "
        set_color cyan
        printf "%s\n" $HTTPS_PROXY
        set_color normal
    else
        printf "  HTTPS_PROXY = "
        set_color brblack
        printf "(not set)\n"
        set_color normal
    end

    if set -q http_proxy
        printf "  http_proxy  = "
        set_color cyan
        printf "%s\n" $http_proxy
        set_color normal
    else
        printf "  http_proxy  = "
        set_color brblack
        printf "(not set)\n"
        set_color normal
    end

    if set -q https_proxy
        printf "  https_proxy = "
        set_color cyan
        printf "%s\n" $https_proxy
        set_color normal
    else
        printf "  https_proxy = "
        set_color brblack
        printf "(not set)\n"
        set_color normal
    end

    echo ""
    set_color --bold
    printf "Keychain certificate:\n"
    set_color normal

    if security find-certificate -c mitmproxy ~/Library/Keychains/login.keychain-db 2>/dev/null | string match -q '*mitm*'
        printf "  mitmproxy CA        "
        set_color brgreen
        printf "added\n"
        set_color normal
    else
        printf "  mitmproxy CA        "
        set_color brblack
        printf "not found\n"
        set_color normal
    end

    echo ""
    set_color --bold
    printf "Node.js SSL:\n"
    set_color normal

    if set -q NODE_EXTRA_CA_CERTS
        printf "  NODE_EXTRA_CA_CERTS = "
        set_color cyan
        printf "%s\n" $NODE_EXTRA_CA_CERTS
        set_color normal
    else
        printf "  NODE_EXTRA_CA_CERTS = "
        set_color brblack
        printf "(not set)\n"
        set_color normal
    end

    echo ""
end
