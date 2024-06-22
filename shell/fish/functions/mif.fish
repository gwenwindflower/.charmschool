function mif -d "Use `mods` to offer suggestions for improving a file with GPT-4o"
    if test (count $argv) -ne 1
        echo "Usage: mif <file_name>"
        return 1
    end

    set file_name $argv[1]

    if not test -f $file_name
        echo "Error: File '$file_name' not found."
        return 1
    end

    if not test -s $file_name
        echo "Error: File '$file_name' is empty."
        return 1
    end
    if not mods -m sonnet "How would you improve the code in this file?" <$file_name | glow
        echo "Error: Failed to run mods."
        return 1
    end
end
