#!/bin/bash

set -e

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit
fi

adduser "$USER" docker
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
pkill -SIGHUP dockerd || true
cd
[ -d librealsense ] || git clone https://github.com/IntelRealSense/librealsense
[ -d installLibrealsense ] || git clone https://github.com/JetsonHacksNano/installLibrealsense
cd installLibrealsense
./patchUbuntu.sh
cd
[ -d backport-iwlwifi ] || git clone https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/backport-iwlwifi.git
cd backport-iwlwifi
git checkout release/core46
make defconfig-iwlwifi-public
make -j4
make install
cd
git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp linux-firmware/iwlwifi-9260* /lib/firmware/
tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf <<EOF
[connection]
wifi.powersave = 2
EOF
