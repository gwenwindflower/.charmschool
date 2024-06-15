function ff
    set tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi --cwd-file=$tmp
    set cwd (cat $tmp)
    if test -n "$cwd" -a "$cwd" != "$PWD"
        cd $cwd
    end
    rm -f $tmp
end
