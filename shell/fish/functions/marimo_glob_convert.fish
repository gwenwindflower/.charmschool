function marimo_glob_convert -d "Batch convert ipynbs into marimo notebooks with glob patterns"
    set -l target_files $argv[1].ipynb
    for target_file in $target_files
        if not test -f $target_file
            echo "No files found matching pattern: $target_file"
            return 1
        end
        set -l output_file_name (string replace -r '\.ipynb$' '.py' "$target_file")
        if test -f $output_file_name
            echo "Skipping conversion for $target_file, output file already exists: $output_file_name"
            continue
        end
        marimo convert $target_file -o $output_file_name
    end
end
