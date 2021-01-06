#!/bin/bash

# ----------------------------------------------------
# public aliases
# ----------------------------------------------------


# DNS enum -  nslookup & dig
alias dnse='dns_enum'

# gobuster dir -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -u http://10.10.10.13 
alias g.d.m='gobuster_dir'
alias gdm='g.d.m'

# gobuster subdomains
alias g.s='exec_wrapper gobuster vhost -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u '
alias gs='g.s'

# john wordlist rockyou
alias j.w.r="exec_wrapper john --wordlist=/usr/share/wordlists/rockyou.txt"
alias jwr='j.w.r'
alias jwr.md5="exec_wrapper john --wordlist=/usr/share/wordlists/rockyou.txt --format=Raw-MD5"

# nc -lnvp // default 9001
# pwncat instead of nc/ncat
alias ncl='shell_listen_linux'
alias ncw='shell_listen_windows'

# python http server
#alias p.h.s='exec_wrapper python3 -m http.server'
alias p.h.s='exec_wrapper bash run_python_web_server_gnome_terminal.sh \"$(pwd)\"'
alias phs='p.h.s'
alias pws="phs"

# privilege escalation / suggestions
alias privl="privilege_escalation_linux"
alias privw="privilege_escalation_windows"

# python smtp server
alias pss='exec_wrapper sudo python -m smtpd -n -c DebuggingServer localhost:25'

# powershell encode command
alias pwse='powershell_encoded_command'

# display revshell shortcut
alias rev.s='display_revshell'
alias revs='rev.s'

# stty raw -echo
alias s.r.e='stty raw -echo'
alias sre='s.r.e'

# ssh with htb key
alias sshi="ssh_with_htb_key"

# scp with htb key
alias scpi="scp_with_htb_key"

# SMB share
alias smbs='exec_wrapper bash run_smb_share_gnome_terminal.sh \"$(pwd)\"'

# SNMP enum
alias snmpe="snmp_enum"

# TTY upgrade - get tab/autocomplete
alias ttyu="tty_upgrade"

alias tcpdi="sudo tcpdump -i tun0 icmp"

# update the tools
alias upd='update'

# wordpress manually launch all the scans
alias wpa='wordpress_scan_all'

# wordpress bruteforce
alias wpb='wordpress_bruteforce'

# wordpress manually enum plugins through gobuster
alias wp.p='wordpress_enum_plugins_gobuster'
alias wpp='wp.p'
