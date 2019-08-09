FROM nvcr.io/nvidia/l4t-base:r32.2

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "America/New_York" > /etc/timezone

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    cmake-curses-gui \
    git \
    libglfw3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libgtk-3-dev \
    libssl-dev \
    libusb-1.0-0-dev \
    pkg-config \
    python3 \
    python3-dev \
    ros-melodic-cv-bridge \
    ros-melodic-ddynamic-reconfigure \
    ros-melodic-diagnostic-updater \
    ros-melodic-eigenpy \
    ros-melodic-image-transport \
    ros-melodic-nav-msgs \
    ros-melodic-nodelet \
    ros-melodic-sensor-msgs \
    ros-melodic-tf && \
    rm -rf /var/cache/apt/archives && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/IntelRealSense/librealsense.git

COPY install install

RUN install/install-librealsense.sh

WORKDIR /catkin_ws/src

RUN git clone https://github.com/IntelRealSense/realsense-ros

WORKDIR /catkin_ws

RUN bash -c "source /opt/ros/melodic/setup.bash && catkin_make"
