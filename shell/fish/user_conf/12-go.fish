# Note - GOPATH being in the preferred place
# (~/.go instead of ~/go) depends on the rotz install
# script being the install method. A manual brew install,
# or other method, will default to ~/go
fish_add_path $(go env GOPATH)/bin
