#!/bin/bash

# ----------------------------------------------------
# global variables
# ----------------------------------------------------
export public_ssh_key="${ctf_framework_path}/keys/htb-key.pub"
export private_ssh_key="${ctf_framework_path}/keys/htb-key"

export single_enum_privesc_script_linux="single-enum-privesc.sh"
export single_enum_privesc_script_windows="single-enum-privesc.ps1"
export webserver_port=8000
export local_port=9001
export smb_server_share_name="smb_share"
export space="     "

export -a ctf_framework_third_party_tools=(
    "aquatone"
    "AutoRecon"
    "Bloodhound"
    "chisel"
    "droopescan"
    "evil-winrm"
    "finger-user-enum"
    "gobuster"
    "IIS-ShortName-Scanner"
    "impacket"
    "jaws"
    "john"
    "LinEnum"
    "linux-exploit-suggester"
    "linux-exploit-suggester-2"
    "linux-kernel-exploits"
    "magescan"
    "Priviledge-escalation-awesome-scripts-suite"
    "pwncat"
    "pwntools"
    "reGeorg"
    "windows-kernel-exploits"        
)
