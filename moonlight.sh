#!/bin/bash

echo "Moonlight Scripts"
echo "Created by Marcel Baumgartner"
echo "(c) 2023 moonlightpanel.xyz"

echo ""

echo "> Checking for docker on the system"


# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    # Docker not found, so download Docker installation script and execute it
    echo "No docker found on the system. Installing it"
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
else
    echo "Docker is already installed."
fi

echo "> Checking for existing moonlight container"

# Check if the Moonlight Docker container is already running
if [ ! "$(docker ps -q -f name=moonlight)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=moonlight)" ]; then
        # cleanup
        echo "Removing old container"
        docker rm moonlight > /dev/null
    fi

    echo "Removing old image"
    docker image rm moonlightpanel/moonlight:beta > /dev/null

    echo "Downloading new image"
    docker pull moonlightpanel/moonlight:beta

    # Run the Moonlight Docker container
    echo "Starting moonlight"
    docker run -d -p 80:80 -v moonlight:/app/storage --name moonlight --restart=always moonlightpanel/moonlight:beta
else
    echo "Moonlight Docker container is already running"

    # Stop the running container
    echo "Stopping moonlight container"
    docker stop moonlight > /dev/null
    
    # Remove the old container
    echo "Removing moonlight container"
    docker rm moonlight > /dev/null

    echo "Removing old image"
    docker image rm moonlightpanel/moonlight:beta > /dev/null

    echo "Downloading new image"
    docker pull moonlightpanel/moonlight:beta

    # Run the updated Moonlight Docker container
    echo "Starting moonlight"
    docker run -d -p 80:80 -v moonlight:/app/storage --name moonlight --restart=always moonlightpanel/moonlight:beta
fi

echo ""
echo "==========================================="
echo "Install complete. Look at the documentation"
echo "for guides how to configure moonlight."
echo "https://docs.moonlightpanel.xyz/installing-moonlight"
echo "==========================================="