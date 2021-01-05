#!/bin/bash

address=$1

echo "sleeping 15min timeout..."
sleep 900

# initial sleep - wait for full nmap scan to finish
#echo "waiting timeout 180s..."
# sleep 15 mins
#sleep 10   

nmap_full_scan_file="$(pwd)/results/${address}/scans/_full_tcp_nmap.txt"

#echo "processing file: '${nmap_full_scan_file}'"
#echo "start waiting..."

ports=""
while true;
do
    #echo "getting ports.."
    #cmd="cat \"${nmap_full_scan_file}\" | grep -v Warning | grep open | awk -F/ '{print \$1}' | tr '\n' ','"
    #echo "cmd: $cmd"

    ports="`cat \"${nmap_full_scan_file}\" | grep -v Warning  | grep 'p open  ' | awk -F/ '{print \$1}' | tr '\n' ','`"
    
    #echo "ports: '${ports}'"

    if [ -z "${ports}" ];
    then
        # sleep 3 minutes, then try again
        #echo "sleep 180...wait for full scan to finish"
        sleep 180
    else
        # here we got the ports from full nmap scan, we can continue
        echo "full scan finished, running nmap...."
        ports="${ports::-1}"        
        break;
    fi    
done

echo "sudo nmap -Pn -n ${address} --script vuln -p${ports}"

sudo nmap -Pn -n ${address} --script vuln -p${ports}