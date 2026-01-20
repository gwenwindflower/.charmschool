function mitm_cert_tool -d "Private utility to easily add and remove the mitm SSL certificate to/from the macOS system keychain"
    if test (count $argv) -ne 1
        logirl help_header -n "Usage:"
        logirl help_body " mitm_cert_tool [add|rm]"
        return 1
    end

    set -l action $argv[1]
    set -l cert_path $MITM_CERT

    if not test -f $cert_path
        logirl error "Certificate file not found at $cert_path"
        return 1
    end
    if test $action = add
        logirl info "Adding mitmproxy certificate to system keychain..."
        security add-trusted-cert -p ssl -p basic $cert_path
        if test $status -eq 0
            logirl success "$(c n Certificate) $(c s -b added)."
            return 0
        end
    else if test $action = rm
        logirl info "Removing mitmproxy certificate from system keychain..."
        security remove-trusted-cert $cert_path
        if test $status -eq 0
            logirl success "$(c n Certificate) $(c e -b removed)."
            return 0
        end
    else
        logirl error "Invalid action. Use 'add' or 'rm'."
        return 1
    end
end
