#!/bin/bash

# Provisioner script called from vagrant file
# Check for ubuntu and package updates, install
sudo apt-get update
sudo apt-get upgrade

# Install Apache2
sudo apt-get install apache2 apache2-utils
