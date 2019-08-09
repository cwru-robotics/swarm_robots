#!/bin/bash

set -e
apt-get update
apt-get upgrade -y
apt-get install -y python-setuptools python-dev build-essential libssl-dev libffi-dev python-pip curl wget git \
  libssl-dev libusb-1.0-0-dev pkg-config libgtk-3-dev libglfw3-dev libgl1-mesa-dev \
  libglu1-mesa-dev rsync
apt-get autoremove -y

pip install docker-compose
tee /etc/docker/daemon.json <<EOF
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
pkill -SIGHUP dockerd
cd ~
[ -d librealsense ] || git clone https://github.com/IntelRealSense/librealsense
[ -d installLibrealsense ] || git clone https://github.com/JetsonHacksNano/installLibrealsense
cd installLibrealsense
./patchUbuntu.sh
