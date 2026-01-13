function proxy-off
    set -e HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
    echo "🙈 Proxy environment OFF"
    proxy-state
end
