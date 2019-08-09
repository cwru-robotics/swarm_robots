# Robot Setup
There are various modifications to the wiring of the Aion Robotics R1
rover from the initial, stock version. Follow the following instructions
to set up the vehicle:
1. [Pre-Operation Inspection]
2. [Autopilot Setup]\: **IMPORTANT**: load the [parameters] from this
   repository instead of step 2! You may need [QGroundControl] instead
   of Mission Planner to upload them. Go to Parameters > Tools > Load
   from file... and select the file.
4. [Motor Controller Setup]\: SKIP connecting encoders to the motor
   driver! Instead, connect them to the PixHawk by connecting the right
   motor encoder's yellow wire to Aux pin 6 and green to Aux pin 5.
   Connect the left motor encoder's green wire to Aux pin 4 and yellow
   to 3. All of these should be on the bottom. Then, connect the black
   wires to the top row and the red wires to the middle row. Reference
   the wiring diagrams. **Make sure you press "Save Settings"**!
   ![Wiring Diagram](https://docs.px4.io/v1.9.0/assets/flight_controller/cube/cube_ports_top_main.jpg)
   ![Encoder Location](http://ardupilot.org/rover/_images/wheel-encoder-pixhawk.png)
5. [Calibration]\: Step 1 is optional. It's OK if these fail.
5. Connect the Jetson: Short the pins on header J48 ("ADD JUMPER TO
   DISABLE μUSB PWR") using a wire or jumper pin. Then, connect 5V and
   ground using jumper wires to any unused pins of the MAIN OUT section
   of the PixHawk. See the wiring diagram of step 4 for more.

# Jetson Setup
First, prepare the SD card. You'll need at least 32GB. Follow
[Nvidia's guide]. Now, put this repository on the board - on the boards
I have set up, I have placed aion_robot in the home directory. Run
[`sudo ./setup_jetson_nano.sh`](setup_jetson_nano.sh) to initialize the
robot. Then, reboot. Now, on your computer, run:
```bash
docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
docker build -t realsense_arm .
docker save -o realsense_arm.tar realsense_arm
rsync -avz -e ssh realsense_arm.tar node1.local:/home/swarm/
```

Then, on the Jetson, run `docker load -i realsense_arm.tar`.

Alternatively, if you'd like to wait a long time for the Jetson to build
the Realsense code itself, you may run `docker-compose build`. You then
don't have to run the above commands. You can also grab the 

# Running code
To run, run `docker-compose up -d` from the `aion_robot` directory. Make
sure that you [build your changes](#development-workflow) before doing
so. Changed nodes will be automatically restarted. To stop, run
`docker-compose down`. To see logs, run `docker-compose logs -f`.

# Development workflow
**You must add yourself to the Docker group or use sudo!**

All code should go in the `aion_control` directory. Add your nodes to
the `aion.launch` file.

First send your changes to the board, `cd` into `aion_robot`, and
`docker build -t aion_control` from there. If you'd like to skip the 
next step, you may instead run `docker-compose build` to build both
images.
## Changing the Realsense code
It's recommended that you only modify the command within
[docker-compose.yml], as it is a slow process to build this.
[Its documentation] describes how to do this. However, if you must, it's
recommended that you build on a computer. Building on a desktop uses an
emulator to build the images. To build it, follow the steps in
[Jetson Setup](#jetson-setup), starting with "Now, on your computer,
run". [Its documentation]:
https://github.com/IntelRealSense/realsense-ros#launch-parameters
# Troubleshooting

## Unable to connect from a computer
The docker setup automatically exposes the ROS nodes to its public
network interface. If you have trouble connecting to it from another
computer, run
```bash
export ROS_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
```
on the Jetson *before* running any Docker commands. However, this should
automatically run when you log in.

# Other things
If you'd like to connect another USB device, look at the `devices`
section within [docker-compose.yml]. Also, look up its reference for
more options.

[Pre-Operation Inspection]: http://docs.aionrobotics.com/en/latest/ardupilot-pre-operation-inspection.html
[Autopilot Setup]: http://docs.aionrobotics.com/en/latest/ardupilot-autopilot-setup.html
[Motor Controller Setup]: http://docs.aionrobotics.com/en/latest/ardupilot-motor-controller-setup.html
[Calibration]: http://docs.aionrobotics.com/en/latest/ardupilot-calibration.html

[parameters]: parameters.params
[Nvidia's guide]: https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit#write
[docker-compose.yml]: docker-compose.yml