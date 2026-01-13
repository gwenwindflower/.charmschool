function dedupe_path -d "Filter out duplicates directories that may have creeped into PATH"
    set -l new_path
    for p in $PATH
        if not contains $p $new_path
            set new_path $new_path $p
        end
    end
    set PATH $new_path
end
