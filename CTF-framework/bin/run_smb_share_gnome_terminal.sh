#!/bin/bash

working_directory="$1"
[ -z "${working_directory}" ] && working_directory="$(pwd)"

declare samba_server_window_name="SAMBA server"
declare samba_server_path="${ctf_framework_path}/bin/run_smb_share_standalone.sh"

bash "${ctf_framework_path}/bin/gnome_terminal_command.sh" "${samba_server_window_name}" "${samba_server_path}" "${working_directory}" 1320 640
