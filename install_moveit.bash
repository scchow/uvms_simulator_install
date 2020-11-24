DIST="melodic"

# Update packages if necessary
sudo apt-get update
sudo apt-get -y dist-upgrade

# Clone MoveIt! and its dependencies
wstool init src 
wstool merge -t src https://raw.githubusercontent.com/ros-planning/moveit/master/moveit.rosinstall
wstool update -t src
# Only install the dependencies from MoveIt!
# because it seems that gtri_based_sonar package has a malformed rosinstall
rosdep update
rosdep install -y --from-paths src/moveit* src/panda* src/rviz_visual_tools --ignore-src --rosdistro $DIST
sudo rm -rf /var/lib/apt/lists/*

# Build all our packages
catkin config --extend /opt/ros/$DIST --cmake-args -DCMAKE_BUILD_TYPE=Release
catkin build
