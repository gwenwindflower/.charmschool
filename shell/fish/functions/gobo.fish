function gobo -d "Go build binary with arg name and output to ~/go/bin/"
    go build -o $HOME/go/bin/ $1
end
