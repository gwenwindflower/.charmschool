function fnmup -d "Update Node.js via fnm with major version and LTS support"
    argparse h/help c/clean n/no-alias l/lts m/major -- $argv
    or return

    if set -q _flag_help
        echo "Usage: fnmup [options]"
        echo ""
        echo "Update Node.js to latest patch/minor of current major version via fnm."
        echo "Notifies if a newer major version is available."
        echo ""
        echo "Options:"
        echo "  -h, --help       Show this help message and exit"
        echo "  -c, --clean      Remove the previous version after updating"
        echo "  -n, --no-alias   Don't update aliases after installing"
        echo "  -l, --lts        Update 'lts' alias instead of 'current'"
        echo "  -m, --major      Upgrade to the newest major version"
        return 0
    end

    # Colors
    set -l normal (set_color normal)
    set -l success (set_color -o brgreen)
    set -l special (set_color -io brmagenta)
    set -l old (set_color --dim red)
    set -l info (set_color -o bryellow)

    # Determine which track we're updating
    if set -q _flag_lts
        set -l track lts
        set -l alias_name lts
        # Get current lts version
        set -l current_version (fnm exec --using=lts node --version 2>/dev/null)
        if test -z "$current_version"
            echo $special" fnm"$normal" No 'lts' alias set. Installing latest LTS..."
            set current_version ""
        end
        _fnmup_update_lts $current_version
    else
        set -l track current
        set -l alias_name current
        # Get current version from 'current' alias or fnm current
        set -l current_version (fnm exec --using=current node --version 2>/dev/null)
        if test -z "$current_version"
            set current_version (fnm current)
        end
        _fnmup_update_current $current_version
    end
end

function _fnmup_update_current -a current_version
    # Colors (need to redeclare in helper)
    set -l normal (set_color normal)
    set -l success (set_color -o brgreen)
    set -l special (set_color -io brmagenta)
    set -l old (set_color --dim red)
    set -l info (set_color -o bryellow)

    # Extract major version
    string match -rq 'v(?<current_major>\d+)' -- $current_version
    
    if test -z "$current_major"
        echo $special" fnm"$normal" Could not determine current major version"
        return 1
    end

    # Get latest version of current major
    set -l latest_current_major (fnm list-remote --filter "^$current_major\." | string match -r 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -rV | head -n 1)
    
    # Get absolute latest version available
    set -l latest_absolute (fnm list-remote | string match -r 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -rV | head -n 1)
    string match -rq 'v(?<latest_major>\d+)' -- $latest_absolute

    # Update current major if needed
    if test "$current_version" != "$latest_current_major"
        echo $special" fnm"$normal" Updating Node.js from $success$current_version$normal to $success$latest_current_major"$normal
        fnm install $latest_current_major
        if not set -q _flag_no_alias
            fnm alias $latest_current_major current
            echo $special" fnm"$normal" Set alias: $success$latest_current_major$normal -> "$success"current"$normal
            fnm default current
        end
        if set -q _flag_clean
            echo $special" fnm"$normal" Cleaning up old version: $old$current_version"$normal
            fnm uninstall $current_version
        end
    else
        echo $special" fnm"$normal" Node.js $success$current_version$normal is latest for v$current_major.x"
    end

    # Notify about newer major version
    if test "$latest_major" != "$current_major"
        echo ""
        echo $info" ⚡ Node.js v$latest_major is available!"$normal" (latest: $success$latest_absolute$normal)"
        echo "   Run "$info"fnmup --major"$normal" to upgrade"
        
        # Prompt for upgrade
        read -l -P "   Upgrade to v$latest_major now? [y/N] " confirm
        if string match -qi 'y' -- $confirm
            _fnmup_install_major $latest_absolute current
        end
    end
end

function _fnmup_update_lts -a current_version
    # Colors
    set -l normal (set_color normal)
    set -l success (set_color -o brgreen)
    set -l special (set_color -io brmagenta)
    set -l old (set_color --dim red)
    set -l info (set_color -o bryellow)

    # Get current LTS major if we have one
    if test -n "$current_version"
        string match -rq 'v(?<current_lts_major>\d+)' -- $current_version
    else
        set current_lts_major ""
    end

    # Get all LTS versions and find the latest of the current LTS line
    set -l all_lts (fnm list-remote --lts)
    
    # Get the newest LTS release (absolute latest LTS)
    set -l latest_lts (echo $all_lts | string match -r 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -rV | head -n 1)
    string match -rq 'v(?<latest_lts_major>\d+)' -- $latest_lts

    if test -n "$current_lts_major"
        # Get latest of current LTS major line
        set -l latest_current_lts (echo $all_lts | string match -r "v$current_lts_major\.[0-9]+\.[0-9]+" | sort -rV | head -n 1)

        if test "$current_version" != "$latest_current_lts"
            echo $special" fnm"$normal" Updating LTS from $success$current_version$normal to $success$latest_current_lts"$normal
            fnm install $latest_current_lts
            if not set -q _flag_no_alias
                fnm alias $latest_current_lts lts
                echo $special" fnm"$normal" Set alias: $success$latest_current_lts$normal -> "$success"lts"$normal
            end
            if set -q _flag_clean
                echo $special" fnm"$normal" Cleaning up old version: $old$current_version"$normal
                fnm uninstall $current_version
            end
        else
            echo $special" fnm"$normal" LTS $success$current_version$normal is latest for v$current_lts_major.x"
        end

        # Notify about newer LTS major
        if test "$latest_lts_major" != "$current_lts_major"
            # Get codename of newer LTS
            set -l lts_line (echo $all_lts | string match -r "v$latest_lts_major\.[0-9]+\.[0-9]+ \([A-Za-z]+\)" | tail -n 1)
            string match -rq '\((?<codename>[A-Za-z]+)\)' -- $lts_line
            
            echo ""
            echo $info" ⚡ Newer LTS available: v$latest_lts_major ($codename)!"$normal" (latest: $success$latest_lts$normal)"
            echo "   Run "$info"fnmup --lts --major"$normal" to upgrade"
            
            read -l -P "   Upgrade to LTS v$latest_lts_major now? [y/N] " confirm
            if string match -qi 'y' -- $confirm
                _fnmup_install_major $latest_lts lts
            end
        end
    else
        # No LTS installed, install latest LTS
        echo $special" fnm"$normal" Installing latest LTS: $success$latest_lts"$normal
        _fnmup_install_major $latest_lts lts
    end
end

function _fnmup_install_major -a target_version alias_name
    # Colors
    set -l normal (set_color normal)
    set -l success (set_color -o brgreen)
    set -l special (set_color -io brmagenta)

    fnm install $target_version
    if not set -q _flag_no_alias
        fnm alias $target_version $alias_name
        echo $special" fnm"$normal" Set alias: $success$target_version$normal -> $success$alias_name"$normal
        if test "$alias_name" = current
            fnm default current
        end
    end
end
