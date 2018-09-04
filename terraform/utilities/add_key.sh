#!/bin/bash
#
# Set initial SSH key if needed
#

set -u # Variables must be explicit
set -e # If any command fails, fail the whole thing
set -o pipefail

chmod 0400 inventory/ansible-deploy-key.pem
eval `ssh-agent -s`
ssh-add inventory/ansible-deploy-key.pem
