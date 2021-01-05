#!/bin/bash

source "${ctf_framework_path}/colors.sh"
source "${ctf_framework_path}/functions.sh"

echo_yellow "[*] current directory:"
pwd
echo

echo_yellow "[*] starting"

python3 -m http.server