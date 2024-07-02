function fm -d "Search dbt models from manifest with fzf"
    set manifest_path "./target/manifest.json"
    set selected (jq -r '.nodes[] | select(.resource_type == "model") | [.name, .path] | @tsv' $manifest_path | fzf --delimiter '\t' \
        --with-nth 1 \
        --preview 'bat ./models/{2}' \
        --bind "ctrl-b:execute(dbt build --select {1})" \
        --bind "ctrl-t:execute(dbt test --select {1})" \
        --bind "ctrl-o:execute($EDITOR ./models/{2})" \
        --expect=enter | string collect)

    set key (echo $selected | head -n1)
    set value (echo $selected | tail -n1 | cut -f1)

    if test "$key" = enter
        commandline -r "dbt build --select $value"
    end
end
