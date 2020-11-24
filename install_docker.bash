#!/bin/bash

build_arg=""

while getopts wh opt;
do
    case "$opt" in
        w) 
			build_arg="-w"
			echo "Installing without Nvidia environment"
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


# ref: https://askubuntu.com/a/30157/8698
if ! [ $(id -u) = 0 ]; then
   echo -e "The script need to be run as root.\nRun `sudo ./install_docker.bash`" >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

# Commands that you don't want running as root would be invoked
# with: sudo -u $real_user
# So they will be run as the user who invoked the sudo command
# Keep in mind if the user is using a root shell (they're logged in as root),
# then $real_user is actually root
# sudo -u $real_user non-root-command

# Commands that need to be ran with root would be invoked without sudo
# root-command

# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
apt-get update
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker's GPG key
sudo -u $real_user curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo -e "Make sure we are downloading from Docker by checking the pub fingerprint for: \n 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88 \n"

# Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.
apt-key fingerprint 0EBFCD88

echo -n1 "Did the correct fingerprint appear? [y/n]: "

read response

case $response in
    y) ;; # continue if verified
    *)
        echo "Stopping execution"
        exit 1
        ;;
esac

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get -y install docker-ce docker-ce-cli containerd.io

groupadd docker
usermod -aG docker $real_user

# Start up Docker on boot
systemctl enable docker

echo -e "Testing Installation by running hello world!\n"
docker run hello-world


# install nvidia docker if necessary
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker
if [[ $build_arg == "" ]]; then
    echo "Installing Nvidia Docker"
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    apt-get update
    apt-get install -y nvidia-docker2
    systemctl restart docker
    echo "Testing Nvidia Docker:"
    docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
fi

echo "Please restart your computer for changes to take effect."
echo "After restarting, use `docker run hello-world` to make sure everything has installed correctly."
