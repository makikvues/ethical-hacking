#!/bin/bash

# call the dns_enum() function defined in aliases
# workaround for allowing to be called by other programs
source "${ctf_framework_path}/functions.sh"

dns_enum "$@"