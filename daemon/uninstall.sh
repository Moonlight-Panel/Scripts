#! /bin/bash

echo "Stop systemd service"
systemctl disable --now moonlight

echo "Removing binaries"
rm /usr/local/bin/MoonlightDaemon
rm /etc/systemd/system/moonlight.service

echo "Removing config folder, build directories and build tools if existing"
rm -r /etc/moonlight
rm -r /tmp/mlbuild

mlcli utils uninstall-bh

systemctl daemon-reload

echo -e "\n\n"
echo "Successfully removed moonlight daemon"
echo "The data of the moonlight daemon is still in"
echo "'/var/lib/moonlight/'"