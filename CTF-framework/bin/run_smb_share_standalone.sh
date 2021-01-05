#!/bin/bash

source "${ctf_framework_path}/colors.sh"
source "${ctf_framework_path}/functions.sh"

working_directory="$1"
[ -z "${working_directory}" ] && working_directory="$(pwd)"

get_ip_address

export smb_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo_yellow "[*] running SAMBA in:"
echo "${working_directory}"
echo

cmd="sudo smbserver.py -username '${smb_user}' -password '${smb_password}' -smb2support '${smb_server_share_name}' '${working_directory}'"
#cmd="sudo smbserver.py  -smb2support '${smb_server_share_name}' '${working_directory}'"
#cmd="sudo smbserver.py -username '${smb_user}' -password '${smb_password}' '${smb_server_share_name}' '${working_directory}'"

echo "${cmd}"

echo_yellow "[*] connect to SMB with"
echo "net use W: \\\\${ip_addr}\\${smb_server_share_name} /USER:${smb_user} '${smb_password}'; net use" 
#echo "net use W: \\\\${ip_addr}\\${smb_server_share_name}; net use" 

echo
echo

echo_yellow "[*] starting"
eval "${cmd}"

