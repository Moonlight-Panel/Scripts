#! /bin/bash

action_name=$1
shift

if [ "$action_name" = "" ]; then
    echo "Commands:"
    echo -e "- install-bh\t\tInstalls the build helper cli used for compiling various moonlight software"
    exit 0
fi

wget -qO /tmp/moonlight/utils/$action_name.sh https://get-moonlight.app/utils/$action_name.sh
bash /tmp/moonlight/utils/$action_name.sh $@