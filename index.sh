#! /bin/bash

echo "Installing moonlight cli"
curl -o /usr/local/bin/mlcli https://get-moonlight.app/cli.sh
chmod +x /usr/local/bin/mlcli

echo "Running installer"
mlcli install run $*