function xcl -d "Clean the cache out of 'x' style commands like npx, uvx, bunx, etc."
    if test (count $argv) -eq 0
        logirl error "Usage: xcl <command>"
        return 1
    end

    set -l cmd $argv[1]

    switch $cmd
        case npx
            set -l cache $(npm config get cache)
            if test -z "$cache"
                logirl error "Could not determine npm cache directory."
                return 1
            end
            set -l npx_cache $cache/_npx
            if test -d $npx_cache -a (count (lsd -A $npx_cache)) -gt 0
                rip $npx_cache/*
            else
                logirl info "npx cache is already clean!"
            end
        case uvx
            uv cache prune
            # TODO: add bun cache, need to figure out the location and available commands
            # case bunx
        case '*'
            logirl error "Unknown command: $cmd[1]"
    end
end
