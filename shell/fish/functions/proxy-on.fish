function proxy-on
    set -gx HTTP_PROXY http://localhost:8080
    set -gx HTTPS_PROXY http://localhost:8080
    set -gx http_proxy http://localhost:8080
    set -gx https_proxy http://localhost:8080
    echo "🔍 Proxy environment ON"
    proxy-state
end
