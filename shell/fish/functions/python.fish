function python --description "Lightweight wrapper around uv run"
    # Check if uv is available
    if not command -v uv >/dev/null 2>&1
        set_color red
        echo "Error: uv is not installed or not in PATH" >&2
        set_color normal
        return 1
    end
    if test (count $argv) -eq 1; and test -f $argv[1]
        uv run $argv[1]
    else
        uv run python $argv
    end
end
