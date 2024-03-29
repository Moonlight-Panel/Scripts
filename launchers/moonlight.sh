#! /bin/bash

action_name=$1
shift

if [ "$action_name" = "" ]; then
    echo "Commands:"
    echo -e "- install\t\tInstalls moonlight. Is used by the web configuration tool"
    echo -e "- uninstall\t\tRemoves moonlight from your system"
    echo -e "- logs\t\tShows the moonlight container logs"
    echo -e "- restart\t\tRestart moonlight and the integrated database if existent"
    echo -e "- config\t\tOpen the moonlight core config in a editor"
    echo -e "- login\t\tSearches for the default login in the logs"
    exit 0
fi

wget -qO /tmp/moonlight/moonlight/$action_name.sh https://get-moonlight.app/moonlight/$action_name.sh
bash /tmp/moonlight/moonlight/$action_name.sh $@