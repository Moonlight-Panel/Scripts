#! /bin/bash

echo "Installing build helper"

if ! test -f /usr/local/bin/bh; then
    arch=$(uname -m | grep -q 'x86_64' && echo 'x64' || echo 'arm64')
    
    wget -qO /usr/local/bin/bh https://github.com/Marcel-Baumgartner/BuildHelper/releases/latest/download/BuildHelper_$arch
    chmod +x /usr/local/bin/bh
    
    echo "Build helper installed"
else
    echo "Build helper already installed"
fi