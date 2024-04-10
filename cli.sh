#! /bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 2 ]; then
    echo "Usage: mlci <command> <argument>"
    echo "See https://help.moonlightpanel.xyz/cli for all commands"
    exit 1
fi

# Assign the first argument to a variable
command=$1

# Assign the second argument to a variable
argument=$2

# Define commands

## Moonlight
moonlightConfig () {
    nano /var/lib/docker/volumes/moonlight/_data/configs/core.json

    echo -e "\n"
    echo "Done? If you are finished with your adjustment, run the following command to apply changes"
    echo "'mlcli moonlight restart'"
}

moonlightLogin () {
    echo "Searching for default login in moonlight logs"
    docker logs moonlight | grep "Default login: Email: "
}

moonlightRestart () {
    docker restart moonlight_db
    docker restart moonlight
}

moonlightLogs () {
    docker logs moonlight
}

## Daemon

daemonConfig () {
    nano /etc/moonlight/config.json
    
    echo -e "\n"
    echo "Done? If you are finished with your adjustment, run the following command to apply changes"
    echo "'mlcli daemon restart'"
}

daemonLogs () {
    cat /var/log/moonlight.log
}

daemonRestart () {
    systemctl restart mldaemon
}

daemonStatus () {
    systemctl status mldaemon
}

## Install

installUpdate() {
    echo "Updating installer"
    rm /tmp/Installer
    arch=$(uname -m | grep -q 'x86_64' && echo 'x64' || echo 'arm64')
    curl -o /tmp/Installer https://get-moonlight.app/Installer_$arch
}

installRun () {
    if ! test -f /tmp/Installer; then
        installUpdate
    fi

    chmod +x /tmp/Installer
    sudo /tmp/Installer $*
}


case $command in
    moonlight)
        
        if [ "$argument" == "config" ]; then
            moonlightConfig
        elif [ "$argument" == "login" ]; then
            moonlightLogin
        elif [ "$argument" == "logs" ]; then
            moonlightLogs
        elif [ "$argument" == "restart" ]; then
            moonlightRestart
        fi

        ;;
    daemon)
        
        if [ "$argument" == "config" ]; then
            daemonConfig
        elif [ "$argument" == "status" ]; then
            daemonStatus
        elif [ "$argument" == "logs" ]; then
            daemonLogs
        elif [ "$argument" == "restart" ]; then
            daemonRestart
        fi
        
        ;;
    install)

        if [ "$argument" == "run" ]; then
            installRun $*
        elif [ "$argument" == "update" ]; then
            installUpdate
        fi

        ;;
    *)
        echo "Unknown command: $command"
        exit 1
        ;;
esac