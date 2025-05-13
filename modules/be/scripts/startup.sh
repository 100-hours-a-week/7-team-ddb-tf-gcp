#!/bin/bash
set -eux

# This startup script is intended for Ubuntu 22.04 LTS

echo ">>> Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo ">>> Installing JDK 17..."
sudo apt install -y openjdk-17-jdk
