function mdp -d "Create a directory for a python module with an __init__.py file"
    if test (count $argv) -ne 1
        echo "Usage: mdp <module_name>"
        return 1
    end
    mkdir $argv[1]; and touch $argv[1]/__init__.py
end
