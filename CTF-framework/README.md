# CTF framework

To work correctly, it depends on this programs to be installed:

## Dependencies
   $ sudo apt install curl enum4linux gnome-terminal hydra medusa nbtscan nikto nmap onesixtyone oscanner pwncat rlwrap seclists smbclient smbmap smtp-user-enum snmp snmpwalk sslscan sipvicious tnscmd10g whatweb wkhtmltopdf

   $ sudo pip install droopescan

The framework contains multiple parts:

1. autorecon_wrapper.sh - bin/autorecon_wrapper.sh
- this is a wrapper over autorecon (https://github.com/Tib3rius/AutoRecon) which adds some extra features, like: creating temporary directories, generating payloads / revshells for your local interface

run it with e.g.
    autorecon_wrapper.shytarget_hostname lin

2. wrapper scripts - bin/run_*, ...
- simple scripts to run a command, e.g. python web server / SMB server, in a separate gnome terminal

3. templates
- templated revshells are stored here, the local ip is replaced when autorecon_wrapper.sh is executed

4. aliases.sh
- this file contains aliases for frequently used commands with some default arguments, e.g.
ncl     =   nc -lnvp 9001


5. functions.sh
- contain implementation of aliases from ./aliases folder

6. autorecon-config
- custom autorecon config files

## Installation
bash ./install.sh
