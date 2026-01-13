function wthr -d "Get weather information for a specified location or default to Chicago"
    set location (string join "+" $argv)
    if test -z "$location"
        set location chicago
    end
    curl "wttr.in/$location"
end
