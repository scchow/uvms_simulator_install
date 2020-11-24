Summary
---

This repository contains scripts that will:

- Install Docker.
- Create a Docker image with all the dependencies of the [Project Dave underwater vehicle simulator](https://github.com/Field-Robotics-Lab/dave).
- Install and Build [MoveIt!](https://github.com/ros-planning/moveit) motion planner and [OMPL](https://github.com/ompl/ompl) from source.
- Create a new Docker image with dependencies of all three packages.


Installation Instructions
---
1. Clone the repository and navigate into the resulting folder


2. Download and install Docker using our provided script: 
    ```
    chmod +x install_docker.bash
    sudo ./install_docker.bash
    ```
    
Or install manually by following the instructions below:

  - Install [Docker Engine](https://docs.docker.com/engine/install/ubuntu/)
  - Do the [Post-Install Docker instructions](https://docs.docker.com/engine/install/linux-postinstall/)
  - If using an Nvidia card, install the [Nvidia docker container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

3. Restart your computer for the changes to take effect.

4. Download dependencies

	  - Make the script executable:

	      ```chmod +x install_dependencies.bash ```

	  - If you have an Nvidia GPU, run the script as 

	      ```./install_dependencies.bash```

	     If you do NOT have an Nvidia GPU, run the script with the -w flag

	     ```./install_dependencies.bash -w```


5. Build the Docker image

	  - Move to the docker directory inside Project Dave

	       ```cd ~/uuv_ws/src/dave/docker```

	  - Give permissions to execute the bash script

	       ```chmod +x build_with_moveit.bash .```

	  - If you have an Nvidia graphics card, run:

	       ``` ./build_with_moveit.bash .```

	      Otherwise run

	       ```./build_with_moveit.bash -w .```

	       
6. Drop into a Docker container the newly built image:
	- If you have an Nvidia GPU, run:

	``` ./run.bash dave_nvidia:latest```

	- Otherwise, run: 

	```./run.bash dave:latest```

You will be dropped into a shell as `developer@<container name>`

**From now on, the instructions will use dave_nvidia as the image name by default. For those without an Nvidia GPU, replace “dave_nvidia” with “dave”**


7. Keep note of what the name of the container is (should be some hash like 83123446d192), as you will need it later

8. Move into the uuv_ws workspace

```
cd uuv_ws
```

9. Enable ccache:
``` 
echo 'export PATH=/usr/lib/ccache:$PATH' >> ~/.bashrc
source ~/.bashrc
```


10. Run the script to install MoveIt! and OMPL
```
chmod +x install_moveit.bash
./install_moveit.bash
```

11. Add sourcing the setup file to bashrc for convenience.

```
echo ‘source /home/developer/uuv_ws/devel/setup.bash’ >> ~/.bashrc
```


12. In a new terminal window, create an image from the new container (that is now updated with MoveIt!’s dependencies 

```
docker commit -m "Installed MoveIt and OMPL Dependencies" <container_name>  dave_nvidia:v0 
```

13. Create a new container using our new image

```
./run.bash dave_nvidia:v0
```

14. Source the catkin setup files so that roslaunch knows where to find your built packages:

```
source ~/uuv_ws/devel/setup.bash
```

15. To run the demo [MoveIt! Tutorial](http://docs.ros.org/en/melodic/api/moveit_tutorials/html/doc/quickstart_in_rviz/quickstart_in_rviz_tutorial.html):

```
roslaunch panda_moveit_config demo.launch rviz_tutorial:=true
```

Some Notes on Docker
---
To list all containers (Including stopped containers):

``` 
docker container ps -a
```


To delete stopped containers

```
docker rm $(docker ps -a -q)
```


IMPORTANT: The run.bash script mounts the `uuv_ws` folder into the image. Thus any changes you make to files within uuv_ws will be reflected both in the host and the docker container. Any other folders/files made outside the `uuv_ws` folder will be saved to only the docker container. **Docker containers are deleted (along with all files within the container excluding uuv_ws) if you close the container and run the “delete stopped containers” command above OR if you restart your computer.** 

To save the state of a docker container, you must create a new image using the command

``` 
docker commit -m “YOUR MESSAGE HERE” <container name> <Repository Name>:<Tag> 
```

For example:

``` 
docker commit -m “installed vim” 83123446d192 dave_nvidia:v2.0 
```

Note that this applies to editing files outside of the `uuv_ws` folder AND installing any additional programs.

You can create new images while the container is running if you want to be extra safe.

You should not need to create new containers unless you are actively installing new packages (e.g., `apt-get install` or making edits to files outside of `~/uuv_ws` that you want to persist to your next session.



Note on `run.bash`
---
The `run.bash` in this repository mounts the entire `uuv_ws` catkin workspace directory. The `run.bash` in the [main Dave repository](https://github.com/Field-Robotics-Lab/dave/tree/master/docker), only mounts the `uuv_ws/src` directory. Running these scripts will overwrite the original `run.bash` with our `run.bash`.
