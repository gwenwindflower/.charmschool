function vf
    set files (fzf)
    set file_count (count $files)
    if test file_count -eq 1
        nvim $files
        elif test file_count -gt 1
        echo "Multiple files found. Please select one."
    else
        echo "No files found"
    end
end
