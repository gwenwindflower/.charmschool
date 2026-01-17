function prx -d "Run command with proxy environment variables set, or set global proxy"
    argparse h/help c/cert -- $argv
    if set -q _flag_help
        logirl help_header "Usage: $(c m 'prx') [$(c i 'the command to run with proxy')]"
        echo ""
        logirl help_body "Run a command in a proxy environment, or set global proxy environment variables."
        echo ""
        logirl help_header "Options:"
        echo "$(logirl help_cmd -f h/help -n)         Show this help text and exit"
        return 0
    end

    # Check if mitmproxy is running
    if not pgrep -q mitmproxy
        logirl warning "mitmproxy is not running!"
        logirl normal "Start mitmproxy first (e.g., 'mitmproxy' or 'mitmweb')"
        return 1
    end

    if set -q _flag_cert
        mitm_cert_tool add
    end

    if test (count $argv) -gt 1
    end
    if test (count $argv) -eq 1
        set HTTP_PROXY http://localhost:8080
        set HTTPS_PROXY http://localhost:8080
        set http_proxy http://localhost:8080
        set https_proxy http://localhost:8080
        command $argv[1]
        return 0
    end
    set -gx HTTP_PROXY http://localhost:8080
    set -gx HTTPS_PROXY http://localhost:8080
    set -gx http_proxy http://localhost:8080
    set -gx https_proxy http://localhost:8080
    logirl info --tag 󰛨 " Global proxy $(c s -b ON)"
    prxstate
    return 0
end
