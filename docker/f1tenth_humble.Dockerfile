FROM nvidia/cuda:12.3.2-cudnn9-devel-ubuntu22.04

RUN apt-get update && apt-get upgrade -y

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics


RUN apt-get install --no-install-recommends -y \
    software-properties-common \
    vim \
    python3-pip \
    tmux\
    git



RUN apt-get -y dist-upgrade
# Added updated mesa drivers for integration with cpu - https://github.com/ros2/rviz/issues/948#issuecomment-1428979499
RUN add-apt-repository ppa:kisak/kisak-mesa && \
    apt-get update && apt-get upgrade -y

RUN add-apt-repository universe



RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata

RUN apt-get install -y curl && \
     curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
     apt-get update && apt-get install -y ros-humble-ros-base


RUN apt-get install --no-install-recommends -y ros-humble-rviz2  ros-humble-rqt*


ENV ROS_DISTRO=humble

# # Cyclone DDS
# RUN apt-get update --fix-missing 
RUN apt-get install --no-install-recommends -y \
    ros-$ROS_DISTRO-cyclonedds \
    ros-$ROS_DISTRO-rmw-cyclonedds-cpp

# Use cyclone DDS by default
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Source by default
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc

RUN pip3 install -U colcon-common-extensions \
    && apt-get install -y build-essential python3-rosdep

RUN \ 
    pip3 install --no-cache-dir Cython

 RUN pip3 install matplotlib==3.5.3 contourpy==1.0.7 setuptools==58.2.0 dill

RUN git clone https://github.com/f1tenth/range_libc.git
RUN cd ./range_libc/pywrapper && WITH_CUDA=ON python3 setup.py install

#hpipm install
RUN git clone https://github.com/giaf/blasfeo.git && cd blasfeo && make shared_library -j 4 && sudo make install_shared
RUN git clone https://github.com/giaf/hpipm.git && cd hpipm && make shared_library -j 4 && sudo make install_shared && cd  /hpipm/interfaces/python/hpipm_python/ && pip3 install .

RUN echo "source $WORKSPACE_PATH/install/setup.bash" >> /root/.bashrc

RUN echo "alias python='python3'" >> /root/.bashrc
#for hpipm and blasfeo
RUN echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/blasfeo/lib:/opt/hpipm/lib">>/root/.bashrc
RUN echo "source /hpipm/examples/python/env.sh">>/root/.bashrc


RUN git clone https://github.com/f1tenth/f1tenth_gym
RUN cd f1tenth_gym && \
    pip3 install -e .



ENV WORKSPACE_PATH=/root/workspace
RUN rm -rf $WORKSPACE_PATH/
COPY workspace/ $WORKSPACE_PATH/src/

SHELL ["/bin/bash", "-c"]


RUN rosdep init && rosdep update && cd $WORKSPACE_PATH && \
    rosdep install --from-paths src -y --ignore-src



COPY scripts/setup/ /root/scripts/setup
RUN  /root/scripts/setup/workspace.sh