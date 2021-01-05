#!/bin/bash

# check if already installed
installed=$(grep -i "ctf_framework_path" ~/.bashrc)

if [ -n "${installed}" ];
then
    echo "Seems like the CTF-framework is already installed, exiting"
    exit
fi

export ctf_framework_path="$(pwd)"

# backup existing config files, create symbolic links to the new ones
declare -a autorecon_config_files=(
    "port-scan-profiles.toml"
    "service-scans.toml"
)

for autorecon_file_name in "${autorecon_config_files[@]}"
do
    declare autorecon_config_file="${HOME}/.config/AutoRecon/${autorecon_file_name}"

    declare backup_file="${autorecon_config_file}.$$.bak"
    echo "moving '${autorecon_config_file}' to '${backup_file}'"
    mv "${autorecon_config_file}" "${backup_file}"

    declare local_autorecon_config_file="${ctf_framework_path}/autorecon-config/${autorecon_file_name}"

    echo "creating symbolic links '${autorecon_config_file}' -> '${local_autorecon_config_file}'"
    ln -s "${local_autorecon_config_file}"  "${autorecon_config_file}"     
done

if [ $? -ne 0 ];
then
    echo "An error occurred, exiting..."

    exit
fi

echo "adding current directory: '${ctf_framework_path}' as CTF-framework installation dir to ~/.bashrc"

# add current directory (installation directory) to .bashrc
echo """

# CTF-framework
export ctf_framework_path=\"${ctf_framework_path}\"
export PATH=\$PATH:\"\${ctf_framework_path}/bin\"

source \"${ctf_framework_path}/init.sh\"

""" >> ~/.bashrc

# create SSH keys
echo "This will create new pair of SSH keys"
mkdir keys 2>/dev/null
ssh-keygen -f keys/htb-key


# getting tools to opt
echo "downloading tools to /opt"
git clone https://github.com/BloodHoundAD/BloodHound.git "/opt/Bloodhound"
git clone https://github.com/pentestmonkey/finger-user-enum.git "/opt/finger-user-enum"
git clone https://github.com/michenriksen/aquatone.git "/opt/aquatone"
git clone https://github.com/OJ/gobuster.git "/opt/gobuster"
git clone https://github.com/steverobbins/magescan.git "/opt/magescan"
git clone https://github.com/411Hall/JAWS.git "/opt/jaws"
git clone https://github.com/irsdl/IIS-ShortName-Scanner.git "/opt/IIS-ShortName-Scanner"
git clone https://github.com/rebootuser/LinEnum.git "/opt/LinEnum"
git clone https://github.com/mzet-/linux-exploit-suggester.git "/opt/linux-exploit-suggester"
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git "/opt/Priviledge-escalation-awesome-scripts-suite"
git clone https://github.com/DominicBreuker/pspy.git "/opt/pspy"
git clone https://github.com/sensepost/reGeorg.git "/opt/reGeorg"
git clone https://github.com/rasta-mouse/Watson.git "/opt/Watson"
git clone https://github.com/rasta-mouse/Sherlock.git "/opt/Sherlock/"


# do symbolic links to tools needed
echo "creating symbolic links to tools..."
# linux
ln -s "/opt/Priviledge-escalation-awesome-scripts-suite/linPEAS/linpeas.sh" "${ctf_framework_path}/www/lin/linpeas.sh"
ln -s "/opt/LinEnum/LinEnum.sh" "${ctf_framework_path}/www/lin/LinEnum.sh" 
ln -s "/opt/linux-exploit-suggester/linux-exploit-suggester.sh" "${ctf_framework_path}/www/lin/les.sh"
ln -s "/opt/linux-exploit-suggester-2/linux-exploit-suggester-2.pl" "${ctf_framework_path}/www/lin/les2.pl"


# windows
ln -s "/opt/Priviledge-escalation-awesome-scripts-suite/winPEAS/winPEASbat/winPEAS.bat" "${ctf_framework_path}/www/win/winPEAS.bat" 
ln -s "/opt/Priviledge-escalation-awesome-scripts-suite/winPEAS/winPEASexe/winPEAS/bin/x64/Release/winPEAS.exe" "${ctf_framework_path}/www/win/winPEAS.exe"
ln -s "/opt/Sherlock/Sherlock.ps1" "${ctf_framework_path}/www/win/Sherlock.ps1"
ln -s "/opt/jaws/jaws-enum.ps1" "${ctf_framework_path}/www/win/jaws-enum.ps1"

# reload .bashrc
echo "Loading the CTF-Framework scripts..."
source "${ctf_framework_path}/init.sh"
echo "OK"
# update your config values in ".secrets"

echo_yellow "---------------------------------------------------------------"
echo_yellow "[!!!] update config values in .secrets file manually [!!!]"
echo_yellow "---------------------------------------------------------------"
echo
echo
