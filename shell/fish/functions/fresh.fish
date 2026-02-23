function fresh -d "Shell clearing and reloading for keybinding convenience"
    argparse c/clear-only r/reload-only g/go-home h/help -- $argv
    or return

    if set -q _flag_help
        echo "$(set_color green)Clear the screen and reload a fresh shell session, or just one of those."
        echo ""
        echo "$(set_color --bold)Options:$(set_color normal)"
        echo "$(set_color brmagenta)-c, --clear-only  $(set_color normal)$(set_color blue)Clear the shell visually, but don't reload$(set_color normal)"
        echo "$(set_color brmagenta)-r, --reload-only $(set_color normal)$(set_color blue)Just start a fresh shell session, leaving previous output in-place$(set_color normal)"
        echo "$(set_color brmagenta)-g, --go-home $(set_color normal)$(set_color blue)Go home before freshening up$(set_color normal)"
        echo "$(set_color brmagenta)-h, --help   $(set_color normal)$(set_color blue)Show this help message and exit$(set_color normal)"
        return 0
    end

    if set -q _flag_clear_only; and set -q _flag_reload_only
        echo "$(set_color --bold red) [ERROR] Conflicting options:$(set_color normal) $(set_color brred)--clear-only and --reload-only cannot be used together.$(set_color normal)"
        echo "$(set_color magenta)Just use $(set_color --bold)'fresh' with no args $(set_color normal)$(set_color magenta)if you would like to do both.$(set_color normal)"
        echo "$(set_color green)Use 'fresh --help' to learn more.$(set_color normal)"
        return 1
    else if set -q _flag_clear_only
        if set -q _flag_go_home
            cd ~
        end
        clear
        return 0
    else if set -q _flag_reload_only
        if set -q _flag_go_home
            cd ~
        end
        echo "$(set_color --bold magenta)󱎝 Reloading shell...$(set_color normal)"
        _relaunch_shell
        return 0
    else
        if set -q _flag_go_home
            cd ~
        end
        clear
        _relaunch_shell
        return 0
    end
end

function _relaunch_shell
    if test -n "$SHELL"
        exec $SHELL
    else if type -q fish
        exec fish
    else
        echo "$(set_color --bold red) [ERROR] Command not found:$(set_color normal) $(set_color brred)No SHELL set, and the fallback (fish) is not in PATH.$(set_color normal)"
        return 127
    end
end
