#!/bin/bash

# 1st argument should be always host, e.g.:
# scan_ip_addr_wrapper.sh {address} onesixtyone <<IP_ADDR>> -c /usr/share/seclists/Discovery/SNMP/common-snmp-community-strings-onesixtyone.txt 2>&1 | tee "{scandir}/{protocol}_{port}_snmp_onesixtyone.txt"
hostname=$1
shift

other_args="$@"

#echo "---------------" >> /tmp/scan_ip_addr_wrapper-log.txt
#echo "[$(date)]: $hostname ${other_args}" >> /tmp/scan_ip_addr_wrapper-log.txt
#

# get the ip address from /etc/hosts
# if not empty, and not equal to hostname then run gobuster
ip_addr="$(cat /etc/hosts | grep -ie "\s${hostname}\s*" | awk '{print $1}')"

#echo "[$(date)]: ip_addr: '${ip_addr}'" >> /tmp/scan_ip_addr_wrapper-log.txt

if [ ! -z "${ip_addr}" ] && [ "${hostname}" != "${ip_addr}" ];
then
    # replace IP_ADDR
    command=`echo "${other_args}" | sed "s/__IP_ADDR__/${ip_addr}/"`

    #echo "[$(date)]: command: '${command}'" >> /tmp/scan_ip_addr_wrapper-log.txt    

    eval "${command}"
fi

echo "---------------" >> /tmp/scan_ip_addr_wrapper-log.txt
