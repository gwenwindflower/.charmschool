function proxy-curl
    curl -x localhost:8080 --cacert ~/.mitmproxy/mitmproxy-ca-cert.pem $argv
end
