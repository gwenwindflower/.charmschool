function brief -d "Filter and select brew packages, then selection a bulk action to perform on them"
    # TODO: this is a fun pattern I wanted to capture, but I should do something actually useful with it
    logirl info " Readying brew list..."
    brew list | sort | fzf --multi --prompt="Select brew packages: " --header="Use TAB to select multiple packages" --preview="brew info {1}" --preview-window=right:60%:wrap | read -l selected_packages
    printf "info\nuninstall\n" | gum choose --limit 1 --header "Select an action to perform on the selected packages:" | read -l action
    for package in $selected_packages
        switch $action
            case info
                logirl info " Showing info for package: $package"
                brew info $package | less
            case uninstall
                gum confirm "Are you sure you want to uninstall package: $package?" && brew uninstall $package
            case '*'
                logirl error " Unknown action: $action"
        end
    end
end
