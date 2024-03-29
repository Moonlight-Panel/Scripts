#! /bin/bash

echo "Disabling service if existent"
systemctl disable --now moonlight

echo "Donwloading dependencies"
echo "- Ensuring docker"
if ! command -v docker &>/dev/null; then
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
fi

CHANNEL=$1
APP_URL=$2
TOKEN=$3
HTTP_PORT=$4
FQDN=$5
SSL=$6

arch=$(uname -m | grep -q 'x86_64' && echo 'x64' || echo 'arm64')

if [ "$CHANNEL" = "custom" ]; then
    echo "Ensuring build tools"
    mlcli utils install-bh

    echo "Removing build dir"
    rm -r /tmp/mlbuild

    echo "Starting build"
    wget -qO /tmp/daemon.json https://raw.githubusercontent.com/Moonlight-Panel/MoonlightDaemon/main/build.json
    bh --project /tmp/daemon.json --root-path /tmp/mlbuild

    echo "Copying artifacts"
    cp /tmp/mlbuild/artifacts/daemon/MoonlightDaemon_$arch /usr/local/bin/MoonlightDaemon
    chmod +x /usr/local/bin/MoonlightDaemon
fi

echo "Applying configuration"
mkdir -p /etc/moonlight

configFile=/etc/moonlight/config.json

if ! test -f /etc/moonlight/config.json; then
    wget -qO /etc/moonlight/config.json https://get-moonlight.app/daemon/files/config.json

    sed -i "s~APP_URL~$APP_URL~g" $configFile
    sed -i "s~TOKEN~$TOKEN~g" $configFile
    sed -i "s/HTTP_PORT/$HTTP_PORT/g" $configFile
    sed -i "s/SSL/$SSL/g" $configFile
    sed -i "s/FQDN/$FQDN/g" $configFile
fi

if [ "$SSL" = "true" ]; then
    echo "Requesting lets encrypt certificate"
    apt install python3-certbot -y
    certbot certonly --standalone --non-interactive --agree-tos -d $FQDN
fi

echo "Setting up systemd"
wget -qO /etc/systemd/system/moonlight.service https://get-moonlight.app/daemon/files/moonlight.service

systemctl daemon-reload
systemctl enable --now moonlight

echo -e "\n\n"
echo "Done! Moonlight daemon is successfully installed. You should be able to see it online in moonlight now"
echo -e "\n"
echo "If you want to do further configuration, run:"
echo "'mlcli daemon config'"
echo -e "\n"
echo "If you need any help, feel free to reach out over discord"
echo "https://discord.gg/TJaspT7A8p"
echo -e "\n\n"