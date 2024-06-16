function ff -d "Launch yazi and exit into the directory you navigated to in yazi"
    set tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi --cwd-file=$tmp
    set cwd (cat $tmp)
    if test -n "$cwd" -a "$cwd" != "$PWD"
        cd $cwd
    end
    rm -f $tmp
end
