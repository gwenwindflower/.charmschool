function prxc
    curl -x localhost:8080 --cacert $MITM_CERT $argv
end
