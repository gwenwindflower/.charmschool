function exe -d "SSH into an exe.dev server"
    if test (count $argv) -ne 1
        echo "Usage: exe <server>"
        return 1
    end
    ssh $argv[1].exe.xyz
end
