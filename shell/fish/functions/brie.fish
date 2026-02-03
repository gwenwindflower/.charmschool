function brie -d "Search brew packages and select ones to get info on"
    # TODO: make this work, and fold into more cohesive brew toolset based on fzf
    brew search $argv[1] | sort | fzf --multi | read -l selected_packages
    for package in $selected_packages
        brew info $package
    end
end
