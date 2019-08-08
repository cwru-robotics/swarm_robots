#!/bin/bash

set -e
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python-setuptools python-dev build-essential libssl-dev libffi-dev python-pip curl wget git \
                        libssl-dev libusb-1.0-0-dev pkg-config libgtk-3-dev libglfw3-dev libgl1-mesa-dev \
                        libglu1-mesa-dev rsync
sudo apt-get autoremove -y

sudo pip install docker-compose

git clone https://github.com/IntelRealSense/librealsense
./scripts/setup_udev_rules.sh