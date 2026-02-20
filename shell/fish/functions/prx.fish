function prx -d "Manage mitmproxy environment and SSL certificates"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Manage mitmproxy environment and SSL certificates."
        logirl help_usage "prx [COMMAND] [OPTIONS]"
        logirl help_header "Commands"
        printf "  $(set_color --bold)on$(set_color normal)          Set global proxy environment variables\n"
        printf "  $(set_color --bold)off$(set_color normal)         Unset proxy environment variables\n"
        printf "  $(set_color --bold)run$(set_color normal)         Run a command with proxy environment\n"
        printf "  $(set_color --bold)curl$(set_color normal)        Execute curl with mitmproxy certificate\n"
        printf "  $(set_color --bold)cert$(set_color normal)        Manage mitmproxy SSL certificates\n"
        printf "  $(set_color --bold)status$(set_color normal)      Show proxy and environment status\n"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help message"
        logirl help_header "Examples"
        printf "  prx on              # Enable global proxy\n"
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
        case off
            _prx_disable
        case run
            _prx_run $argv[2..]
        case curl
            _prx_curl $argv[2..]
        case cert
            _prx_cert $argv[2..]
        case status
            _prx_status
        case '*'
            logirl error "Unknown command: $command"
            printf "Try: prx --help\n"
            return 1
    end
end

function _prx_check_running -d "Check if mitmproxy is running"
    if not pgrep -q mitmproxy
        logirl warning "mitmproxy is not running"
        logirl info "Start mitmproxy first (e.g., 'mitmproxy' or 'mitmweb')"
        return 1
    end
    return 0
end

function _prx_enable -d "Enable global proxy environment variables"
    argparse h/help c/cert -- $argv
    or return

    if set -q _flag_help
        echo "Enable global proxy environment variables."
        logirl help_usage "prx on [OPTIONS]"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help"
        logirl help_flag "c/cert" "Also add SSL certificate to keychain"
        return 0
    end

    if not _prx_check_running
        return 1
    end

    set -gx HTTP_PROXY http://localhost:8080
    set -gx HTTPS_PROXY http://localhost:8080
    set -gx http_proxy http://localhost:8080
    set -gx https_proxy http://localhost:8080

    logirl success " Global proxy enabled"

    if set -q _flag_cert
        _prx_cert add
    end

    _prx_status
    return 0
end

function _prx_disable -d "Disable proxy environment and remove SSL certificate"
    set -e HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
    logirl success "󰹏 Proxy environment disabled"
    _prx_cert rm
    _prx_status
    return 0
end

function _prx_run -d "Run command with proxy environment variables"
    argparse h/help c/cert -- $argv
    or return

    if set -q _flag_help
        echo "Run a command with proxy environment variables."
        logirl help_usage "prx run [OPTIONS] <command> [args...]"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help"
        logirl help_flag "c/cert" "Add SSL certificate before running"
        logirl help_header "Examples"
        printf "  prx run npm test\n"
        printf "  prx run -c curl https://example.com\n"
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

    if set -q _flag_cert
        _prx_cert add
    end

    # Run command with proxy env vars in local scope
    env HTTP_PROXY=http://localhost:8080 \
        HTTPS_PROXY=http://localhost:8080 \
        http_proxy=http://localhost:8080 \
        https_proxy=http://localhost:8080 \
        $argv
end

function _prx_curl -d "Execute curl with mitmproxy certificate"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Execute curl with mitmproxy certificate and proxy."
        logirl help_usage "prx curl [OPTIONS] <url> [curl-args...]"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help"
        logirl help_header "Examples"
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
        logirl help_header "Commands"
        printf "  $(set_color --bold)add$(set_color normal)  Add certificate to system keychain\n"
        printf "  $(set_color --bold)rm$(set_color normal)   Remove certificate from system keychain\n"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help"
        return 0
    end

    set -l action $argv[1]
    set -l cert_path $HOME/.mitmproxy/mitmproxy-ca-cert.pem

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
            logirl info "Adding mitmproxy certificate to system keychain..."
            security add-trusted-cert -p ssl -p basic $cert_path 2>/dev/null
            if test $status -eq 0
                logirl success "Certificate added"
            else
                logirl warning "Certificate may already be in keychain"
            end
        case rm
            logirl info "Removing mitmproxy certificate from system keychain..."
            security remove-trusted-cert $cert_path 2>/dev/null
            if test $status -eq 0
                logirl success "Certificate removed"
            else
                logirl warning "Certificate may not be in keychain"
            end
    end
end

function _prx_status -d "Show proxy and environment status"
    echo ""

    # Check if proxy is responding
    if curl -s -o /dev/null --connect-timeout 1 -x localhost:8080 http://example.com 2>/dev/null
        set_color --bold magenta
        echo "██╗   ██╗███████╗███████╗"
        echo "╚██╗ ██╔╝██╔════╝██╔════╝"
        echo " ╚████╔╝ █████╗  ███████╗"
        echo "  ╚██╔╝  ██╔══╝  ╚════██║"
        echo "   ██║   ███████╗███████║"
        echo "   ╚═╝   ╚══════╝╚══════╝"
        set_color normal
        echo ""
        printf "Proxy is "
        set_color --bold brgreen
        printf "RUNNING"
        set_color normal
        printf " on localhost:8080\n"
    else
        set_color --bold brblack
        echo "███╗   ██╗ ██████╗ "
        echo "████╗  ██║██╔═══██╗"
        echo "██╔██╗ ██║██║   ██║"
        echo "██║╚██╗██║██║   ██║"
        echo "██║ ╚████║╚██████╔╝"
        echo "╚═╝  ╚═══╝ ╚═════╝ "
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
end
