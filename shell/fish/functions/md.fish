function md --argument-names dir_name -d "Create a new directory or subdirectory path and cd into it"
    if test (count $argv) -ne 1
        set_color -o brred
        echo "Error: Please provide exactly one directory name or path to create"
        set_color normal
        set_color green
        echo "Usage: md <directory_name_or_path>"
        set_color normal
        return 1
    end
    mkdir -p $dir_name
    # We could just cd but we use zoxide
    # to seed it into the database for easier access later
    z $dir_name
end
