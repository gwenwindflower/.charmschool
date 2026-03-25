function gpgrl -d "Restart gpg-agent, useful after config or key changes"
    if not type -q gpgconf
        logirl error "gpgconf not found in PATH"
        logirl info "Install with: $(set_color brmagenta)brew install gnupg$(set_color normal)"
        return 127
    end

    # gpgconf returns 0 even if it the agent isnt' running or it fails
    # so we can't error handle /shrug
    gpgconf --kill gpg-agent
    gpgconf --launch gpg-agent
    logirl success "gpg-agent restarted successfully."
end
