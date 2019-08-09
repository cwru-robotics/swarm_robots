#!/usr/bin/env bash

#!/bin/bash
# Builds the Intel Realsense library librealsense on a Jetson Nano Development Kit
# Copyright (c) 2016-19 Jetsonhacks
# MIT License

# Jetson Nano; L4T 32.2
set -e

LIBREALSENSE_DIRECTORY=/librealsense
LIBREALSENSE_VERSION=v2.25.0
INSTALL_DIR=/install
NVCC_PATH=/usr/local/cuda/bin/nvcc

# You don't need to build CMake unless you are using CUDA
USE_CUDA=true

function usage
{
    echo "usage: ./installLibrealsense.sh [[-c ] | [-h]]"
    echo "-n | --build_with_cuda  Build no CUDA (Defaults to with CUDA)"
    echo "-h | --help  This message"
}

# Iterate through command line inputs
while [ "$1" != "" ]; do
    case $1 in
        -n | --build_no_cuda )  USE_CUDA=false
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo "Build with CUDA: "$USE_CUDA

green=
reset=

if [ ! -d "$LIBREALSENSE_DIRECTORY" ] ; then
  # clone librealsense
  cd
  echo "${green}Cloning librealsense${reset}"
  git clone https://github.com/IntelRealSense/librealsense.git
fi

# Is the version of librealsense current enough?
cd "$LIBREALSENSE_DIRECTORY"
VERSION_TAG=$(git tag -l $LIBREALSENSE_VERSION)
if [ ! "$VERSION_TAG"  ] ; then
   echo ""
  tput setaf 1
  echo "==== librealsense Version Mismatch! ============="
  tput sgr0
  echo ""
  echo "The installed version of librealsense is not current enough for these scripts."
  echo "This script needs librealsense tag version: "$LIBREALSENSE_VERSION "but it is not available."
  echo "This script patches librealsense, the patches apply on the expected version."
  echo "Please upgrade librealsense before attempting to install again."
  echo ""
  exit 1
fi

# Checkout version the last tested version of librealsense
git checkout $LIBREALSENSE_VERSION

# Install the dependencies
cd "$INSTALL_DIR"
# e.g. echo "${red}red text ${green}green text${reset}"

cd "$LIBREALSENSE_DIRECTORY"
git checkout $LIBREALSENSE_VERSION

echo "${green}Applying Model-Views Patch${reset}"
# The render loop of the post processing does not yield; add a sleep
patch -p1 -i "$INSTALL_DIR"/patches/model-views.patch

# echo "${green}Applying Incomplete Frames Patch${reset}"
# The Jetson tends to return incomplete frames at high frame rates; suppress error logging
# patch -p1 -i $INSTALL_DIR/patches/incomplete-frame.patch

# Now compile librealsense and install
mkdir build
cd build
# Build examples, including graphical ones
echo "${green}Configuring Make system${reset}"
# Use the CMake version that we built, must be > 3.8
# Build with CUDA (default), the CUDA flag is USE_CUDA, ie -DUSE_CUDA=true
export CUDACXX=$NVCC_PATH
export PATH=${PATH}:/usr/local/cuda/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64

/usr/bin/cmake ../ -DBUILD_WITH_CUDA="$USE_CUDA" -DCMAKE_BUILD_TYPE=release -DBUILD_PYTHON_BINDINGS=bool:true -DBUILD_EXAMPLES=OFF -DIMPORT_DEPTH_CAM_FW=OFF -DBUILD_WITH_TM2=OFF

# The library will be installed in /usr/local/lib, header files in /usr/local/include
# The demos, tutorials and tests will located in /usr/local/bin.
echo "${green}Building librealsense, headers, tools and demos${reset}"

NUM_CPU=$(nproc)
if time make -j$((NUM_CPU - 1)); then
  echo "librealsense make successful"
else
  # Try to make again; Sometimes there are issues with the build
  # because of lack of resources or concurrency issues
  echo "librealsense did not build " >&2
  echo "Retrying ... "
  # Single thread this time

  if time make; then
    echo "librealsense make successful"
  else
    # Try to make again
    echo "librealsense did not successfully build" >&2
    echo "Please fix issues and retry build"
    exit 1
  fi
fi
echo "${green}Installing librealsense, headers, tools and demos${reset}"
make install

# shellcheck disable=SC2016
if grep [ -Fxq 'export PYTHONPATH=$PYTHONPATH:/usr/local/lib' ~/.bashrc ] ; then
    echo "PYTHONPATH already exists in .bashrc file"
else
   echo 'export PYTHONPATH=$PYTHONPATH:/usr/local/lib' >> ~/.bashrc
   echo "PYTHONPATH added to ~/.bashrc. Pyhon wrapper is now available using import pyrealsense2"
fi

echo "${green}Library Installed${reset}"
echo " "
echo " -----------------------------------------"
echo "The library is installed in /usr/local/lib"
echo "The header files are in /usr/local/include"
echo "The demos and tools are located in /usr/local/bin"
echo " "
echo " -----------------------------------------"
echo " "