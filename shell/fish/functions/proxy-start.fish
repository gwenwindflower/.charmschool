function proxy-start -d "Start mitmproxy or mitmweb on localhost:8080/8081"
    argparse w/web h/help -- $argv

    if set -q _flag_help
        echo "Usage: proxy [--web] [mitmproxy options]"
        echo ""
        echo "Start mitmproxy or mitmweb on localhost:8080/8081"
        echo ""
        echo "Options:"
        echo "  --web       Start mitmweb (web UI) instead of mitmproxy (terminal UI)"
        echo "  -h, --help  Show this help message"
        exit 0
    end

    if set -q _flag_web
        echo "🌐 Starting mitmweb on :8080 (web UI on :8081)..."
        mitmweb $argv
    end

    echo "🚀 Starting mitmproxy on :8080..."
    mitmproxy $argv
end
