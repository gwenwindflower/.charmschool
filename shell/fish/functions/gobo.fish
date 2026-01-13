function gobo -d "Go build binary with arg name and output to ~/go/bin/" --argument-names package
    go build -o (go env GOPATH)/bin $package
end
