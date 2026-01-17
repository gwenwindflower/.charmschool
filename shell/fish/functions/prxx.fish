function prxx
    set -e HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
    logirl info --tag 󰹏 " Proxy environment $(c e -b OFF)"
    mitm_cert_tool rm
    prxstate
end
