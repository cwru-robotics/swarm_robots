#!/bin/bash

set -e
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python-setuptools python-dev build-essential libssl-dev libffi-dev python-pip curl wget git \
  libssl-dev libusb-1.0-0-dev pkg-config libgtk-3-dev libglfw3-dev libgl1-mesa-dev \
  libglu1-mesa-dev rsync
sudo apt-get autoremove -y

sudo pip install docker-compose
sudo tee /etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
EOF
sudo pkill -SIGHUP dockerd
cd ~
[ -d librealsense ] || git clone https://github.com/IntelRealSense/librealsense
[ -d installLibrealsense ] || git clone https://github.com/JetsonHacksNano/installLibrealsense
cd installLibrealsense
./patchUbuntu.sh
