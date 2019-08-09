FROM ros:melodic-robot-bionic

WORKDIR /catkin_ws/src

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    ros-melodic-mavros \
    ros-melodic-mavros-extras \
    ros-melodic-rplidar-ros && \
    rm -rf /var/cache/apt/archives && \
    rm -rf /var/lib/apt/lists/*

RUN /opt/ros/melodic/lib/mavros/install_geographiclib_datasets.sh

RUN git clone https://github.com/GT-RAIL/robot_pose_publisher
RUN git clone https://github.com/aionrobotics/aion_r1_description
RUN git clone https://github.com/aionrobotics/aion_r1_gazebo
# RUN git clone https://github.com/IntelRealSense/realsense-ros && \
#     cd realsense-ros && \
#     git checkout `git tag | sort -V | grep -P "^\d+\.\d+\.\d+" | tail -1`

WORKDIR /catkin_ws

RUN /ros_entrypoint.sh catkin_make

COPY . /catkin_ws/src/aion_control

RUN /ros_entrypoint.sh catkin_make

USER 0:dialout

CMD [ "bash", "-c", "source /catkin_ws/devel/setup.bash && roslaunch --wait aion_control aion.launch" ]