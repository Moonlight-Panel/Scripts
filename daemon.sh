#! /bin/bash

echo "Moonlight Scripts"
echo "Created by Marcel Baumgartner"
echo "(c) 2023 moonlightpanel.xyz"

echo ""

echo "> Checking for a existing daemon instance"

if test -f "/etc/systemd/system/moonlightdaemon.service"; then
    echo "Found existing daemon instance"
    echo "Deleting existing daemon instance"
    systemctl stop moonlightdaemon
    rm /lib/moonlightdaemon/MoonlightDaemon
    rm /etc/systemd/system/moonlightdaemon.service
fi

echo "> Installing moonlight daemon"

mkdir /lib/moonlightdaemon/ > /dev/null

echo "- Downloading daemon binary"

wget -q -O /lib/moonlightdaemon/MoonlightDaemon https://install.moonlightpanel.xyz/daemonFiles/MoonlightDaemon

if test -f "/lib/moonlightdaemon/appsettings.json"; then
    echo "Found existing config file. Skipping download of the default config"
else
    echo "No config file found"
    echo "- Downloading default config"
    wget -q -O /lib/moonlightdaemon/appsettings.json https://install.moonlightpanel.xyz/daemonFiles/appsettings.json
fi

echo "- Downloading systemd service"

wget -q -O /etc/systemd/system/moonlightdaemon.service https://install.moonlightpanel.xyz/daemonFiles/moonlightdaemon.service

echo "- Changing file permissions"

chmod 664 /etc/systemd/system/moonlightdaemon.service
chmod +x /lib/moonlightdaemon/MoonlightDaemon

echo "- Reloading systemd daemon"

systemctl daemon-reload

echo "- Enabling moonlight daemon"

systemctl enable --now moonlightdaemon > /dev/null

echo ""

echo "Done. The moonlight daemon has been installed on this maschine"