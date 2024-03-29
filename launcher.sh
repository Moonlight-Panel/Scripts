#! /bin/bash

launch_name=$1
shift

mkdir -p /tmp/moonlight
mkdir -p /tmp/moonlight/$launch_name
wget -qO /tmp/moonlight/$launch_name.sh https://get-moonlight.app/launchers/$launch_name.sh
sudo bash /tmp/moonlight/$launch_name.sh $@