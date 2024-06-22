function pdir -d "Create a directory for a python module with an __init__.py file"
    mkdir $argv[1]; and touch $argv[1]/__init__.py
end
