#!/bin/bash

declare python_webserver_window_name="Python Web Server"
declare python_webserver_path="${ctf_framework_path}/bin/run_python_web_server_standalone.sh"

working_directory="$1"
[ -z "${working_directory}" ] && working_directory="$(pwd)"

bash "${ctf_framework_path}/bin/gnome_terminal_command.sh" "${python_webserver_window_name}" "${python_webserver_path}" "${working_directory}" 1320 320
