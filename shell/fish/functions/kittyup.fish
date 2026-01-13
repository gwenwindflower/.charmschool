function kittyup -d "Update the kitty terminal emulator idempotently"
    argparse f/force c/check-only h/help -- $argv
    or return

    set -l latest_version_url "https://sw.kovidgoyal.net/kitty/current-version.txt"

    # pretty colors
    set -l normal (set_color normal)
    set -l error (set_color -o brred)
    set -l error_text (set_color red)
    set -l success (set_color -o green)
    set -l success_text (set_color brgreen)
    set -l help (set_color green)
    set -l warn (set_color -o yellow)
    set -l info (set_color blue)
    set -l special (set_color -i brmagenta)
    set -l cmd (set_color -o brmagenta)

    if set -q _flag_help
        echo $help"Idempotent kitty updater 󰄛 "
        echo ""
        echo "Usage:$cmd kittyup$normal$special [options]$normal$help"
        echo "Options:"
        echo " $cmd -f, --force$normal      $info Force reinstall even if versions match"
        echo " $cmd -c, --check-only$normal $info Just check for updates, do not install"
        echo " $cmd -h, --help$normal       $info Show this help message"
        return 0
    end

    echo $cmd" Checking local kitty installation...$normal"
    if not type -q kitty
        echo $error"   Command not found:$normal$error_text 'kitty' not found in PATH.$normal"
        echo $info"  Please make sure kitty is installed and accessible."$normal
        echo $special"  https://sw.kovidgoyal.net/kitty/"$normal
        return 1
    end

    set -l current_version (kitty --version | string split ' ' -f 2)
    if test -z "$current_version"
        echo $error"   Unknown version:$normal$error_text Could not determine the current kitty version."
        echo "  The output of '"$cmd"kitty --version"$normal$error_text"' was unexpected."$normal
        return 1
    end
    echo $success"   $normal$info You are currently on version: $success$current_version"$normal

    if set -q _flag_force
        echo -e $warn" --force$normal flag detected.$cmd Proceeding with reinstallation..."$normal
        _do_kitty_install $kitty_app_path
    end
    # Snag the latest version from the installer script
    # We only do this if we aren't forcing an install
    set -l latest_version
    if not set -q _flag_force
        echo $cmd" Checking for the latest version online..."$normal

        set latest_version (curl -sL $latest_version_url | string trim)

        if test -z "$latest_version"
            echo $error"   Unknown version:$normal$error_text Could not determine the latest version from the installer script."
            echo "  It's possible the structure of the installer script has changed."$normal
            return 1
        end
        echo $success"   $normal$info The latest available version is $success$latest_version"$normal
    end

    if set -q _flag_check_only
        if test "$current_version" = "$latest_version"
            echo $success" $normal$success_text You're already on the latest version of kitty! No updates needed.$normal"
            echo $info"You can run '"$cmd"kittyup --force"$info"' to update if needed."$normal
        else
            echo $warn" $info A new version of kitty is available: $special$latest_version"$normal
        end
        return 0
    end

    if test "$current_version" = "$latest_version"
        echo $success" $normal$success_text You're already on the latest version of kitty! No updates needed.$normal"
        echo $info"You can run '"$cmd"kittyup -f/--force"$normal$info"' to update if needed."$normal
        return 0
    else
        echo $warn"   $info A new version of kitty is available: $special$latest_version"$normal
        _do_kitty_install
    end
end

function _do_kitty_install
    set -l installer_url "https://sw.kovidgoyal.net/kitty/installer.sh"

    # pretty colors
    set -l normal (set_color normal)
    set -l error (set_color -o brred)
    set -l error_text (set_color red)
    set -l success (set_color -o green)
    set -l success_text (set_color brgreen)
    # set -l help (set_color green)
    # set -l warn (set_color -o yellow)
    set -l info (set_color blue)
    # set -l special (set_color -i brmagenta)
    set -l cmd (set_color -o brmagenta)

    echo $cmd"󰚰 Starting the kitty update process..."$normal

    if curl -fSL $installer_url | sh /dev/stdin
        echo $success" Success!$normal$success_text Kitty has been updated."$normal
        echo $info"Please restart your kitty terminal completely to use the new version."$normal
        return 0
    else
        echo $error"   $normal$error_text The installation script failed."$normal
        echo $info"  Please check the output above for any errors."$normal
        return 1
    end
end
