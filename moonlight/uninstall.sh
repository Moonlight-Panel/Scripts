#! /bin/bash

echo "Stopping containers"
docker kill moonlight
docker kill moonlight_db

echo "Removing containers"
docker rm moonlight
docker rm moonlight_db

echo "Removing volumes"
docker volume rm moonlight
docker volume rm moonlight_db

echo "Removing images"
docker image rm mysql

# Custom
docker image rm moonlightpanel/moonlight:custom

# Legacy
docker image rm moonlightpanel/moonlight:beta
docker image rm moonlightpanel/moonlight:canary

# Latest, unused at day of writing
docker image rm moonlightpanel/moonlight

echo "Done. Successfully removed moonlight from this system"
echo "Run the following command in order to delete left over tmp files"
echo -e "\n'rm -r /tmp/moonlight'"