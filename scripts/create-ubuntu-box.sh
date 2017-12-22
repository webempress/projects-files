#!/bin/bash

# Before running this script: check VB & vagrant for updates.
# to check vagrant version: vagrant --version
# test
# make the directory for the new vagrant box
# assumes that the ~/projects directory exists
cd ~/projects
mkdir trusty64_lamp
cd trusty64_lamp

# init vagrant box
vagrant init ubuntu/trusty64

# next step is to manually edit the vagrantfile for
#   private_network
#   provisioner script call
