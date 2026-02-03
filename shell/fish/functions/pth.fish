function pth -d "Pretty prints current PATH with one entry per line"
    argparse u/user -- $argv
    set -l path_var $PATH
    if set -q _flag_user
        set path_var $fish_user_paths
    end
    string split ' ' $path_var | bat
end
