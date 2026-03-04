function exe -d "Use Kitty's SSH kitten + agent forwarding to seamlessly connect to an exe.dev VM."
    argparse h/help -- $argv

    if set -q _flag_help
        echo "Use Kitty's SSH kitten + agent forwarding to seamlessly connect to an exe.dev VM."
        logirl help_usage "exe <server-name>"
        return 1
    end
    if test (count $argv) -ne 1
        echo "Use Kitty's SSH kitten + agent forwarding to seamlessly connect to an exe.dev VM."
        logirl help_usage "exe <server-name>"
        return 1
    end
    kitten ssh -A $argv[1].exe.xyz
end
