#!/bin/bash

# example
# bash ./bin/gnome_terminal_command.sh "my title" ./bin/python-web-server.sh "$(pwd)" "1320" "640"

if [ $# -ne 5 ];
then
    echo "$0 <title> <script_path> <working_directory> <x> <y>" 

    exit 1
fi

declare title=$1
declare script_path=$2
declare working_directory=$3
declare x_pos=$4
declare y_pos=$5

gnome-terminal --tab --working-directory="${working_directory}" --title="${title}" -- bash "${script_path}"
wmctrl -r "${title}" -b add,above
wmctrl -r "${title}" -e 0,${x_pos},${y_pos},600,300