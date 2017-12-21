#!/bin/bash

# Before running this script: Update VB, update vagrant, update vagrant plugins.

# make the directory for the new vagrant box
cd ~/projects
mkdir trusty64_lampv2
cd trusty64_lampv2

# init box
trusty64_lampv2 $ vagrant init ubuntu/trusty64

# next step is to manually edit the vagrantfile for private_network
