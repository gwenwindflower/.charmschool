function prxstate
    echo ""

    # Check if something is listening on 8080
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
        logirl normal "Proxy is $(c s -b RUNNING)"(set_color normal)" on localhost:8080"
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
        logirl normal "Proxy is $(c e -b RUNNING)"(set_color normal)" on localhost:8080"
    end

    echo ""
    echo (set_color --bold)"Environment variables:"(set_color normal)

    if set -q HTTP_PROXY
        echo "  HTTP_PROXY  = "(set_color cyan)$HTTP_PROXY(set_color normal)
    else
        echo "  HTTP_PROXY  = "(set_color brblack)"(not set)"(set_color normal)
    end

    if set -q HTTPS_PROXY
        echo "  HTTPS_PROXY = "(set_color cyan)$HTTPS_PROXY(set_color normal)
    else
        echo "  HTTPS_PROXY = "(set_color brblack)"(not set)"(set_color normal)
    end

    if set -q http_proxy
        echo "  http_proxy  = "(set_color cyan)$http_proxy(set_color normal)
    else
        echo "  http_proxy  = "(set_color brblack)"(not set)"(set_color normal)
    end

    if set -q https_proxy
        echo "  https_proxy = "(set_color cyan)$https_proxy(set_color normal)
    else
        echo "  https_proxy = "(set_color brblack)"(not set)"(set_color normal)
    end

    echo ""
end
