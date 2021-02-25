#!/bin/bash

DIST="melodic"

# Get the folder this script is being run in
# Assuming dependencies are located in same directory
# dependencies: Dockerfile_MoveIt, build_moveit.bash, run.bash
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
build_arg=""

while getopts wh opt;
do
    case "$opt" in
        w) 
			build_arg="-w"
			echo "Building with no Nvidia environment"
			;;
		h)  
			echo -e "Usage: $0 [-h] [-w] \n-h: view this help message \n-w: build without Nvidia support (use on systems with no Nvidia GPU)"
    		exit 1
    		;;
	    \?) 
			echo "Building with Nvidia environment"
			;;
    esac
done

if [[ $build_arg == "" ]]; then
	echo -e "\nWe are building the environment WITH Nvidia support. If your system does NOT have an Nvidia GPU, run the script with the -w flag."
fi

if [[ $build_arg == "-w" ]]; then
	echo -e \n"We are building the environment WITHOUT Nvidia support. If your system has an Nvidia GPU, run the script without the -w flag."
fi

echo -en "\nShould we proceed with the installation? [y] to continue; any other key to cancel:"

read -n1 start

echo -e "\n"

if [[ $start != "y" ]]; then
	exit 1
fi

# Create work directory that will be mounted in Docker Container
mkdir -p ~/uuv_ws/src
cd ~/uuv_ws/src

echo -e "Cloning required repositories...\n"

# Clone Dave Repositories
git clone https://github.com/Field-Robotics-Lab/dave.git
git clone https://github.com/Field-Robotics-Lab/gtri_based_sonar.git
git clone https://github.com/Field-Robotics-Lab/nps_uw_sensors_gazebo.git
git clone https://github.com/Field-Robotics-Lab/frl_msgs.git 

# Clone UUV Repositories
git clone https://github.com/uuvsimulator/uuv_simulator.git
git clone https://github.com/uuvsimulator/rexrov2.git
git clone https://github.com/uuvsimulator/uuv_manipulators.git
git clone https://github.com/uuvsimulator/eca_a9.git

# Clone ds_sim repositories
git clone https://bitbucket.org/whoidsl/ds_sim.git
git clone https://bitbucket.org/whoidsl/ds_msgs.git

# clone ompl repository
git clone https://github.com/ompl/ompl.git

echo -e "\n Done cloning Repositories. Moving files into ~/uuv_ws/src/dave/docker \n"

# move to the docker folder
cd dave/docker

# Copy my custom DockerFile/build files to the docker folder
cp $SCRIPTPATH/Dockerfile_MoveIt .
cp $SCRIPTPATH/build_with_moveit.bash .

# Move the MoveIt! install script to an accessible location
cp $SCRIPTPATH/install_moveit.bash ~/uuv_ws

# make the build_with_moveit.bash script executable
chmod +x build_with_moveit.bash

# Move the custom run file that loads the full folder
cp $SCRIPTPATH/run_custom.bash .

echo -e "\n Done cloning dependencies. \n"
