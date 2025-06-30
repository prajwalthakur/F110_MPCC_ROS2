#!/bin/bash
PROJECT_ROOT="$PWD"
# {PROJECT_ROOT}=/home/prajwal/projects/github-projects/ros_projects/F110_MPCC_ROS
# run_docker() {
#     # -it is for interactive, tty
#     # --privileged for accessing /dev contents
#     # --net=host to share the same network as host machine. TL;DR same IP.
#     docker run -it --privileged --net=host \
#     --name f1tenth_humble \
#     --env="DISPLAY" \
#     --env="QT_X11_NO_MITSHM=1" \
#     -v ${PROJECT_ROOT}/scripts/deploy/app.sh:/root/app.sh \
#     -v ${PROJECT_ROOT}/scripts/deploy/cyclonedds.xml:/root/cyclonedds.xml \
#     -v /etc/udev/rules.d:/etc/udev/rules.d \
#     -v /dev:/dev \
#     --env="CYCLONEDDS_URI=file:///root/cyclonedds.xml" \
#     $@
# }
run_docker() {
    # -it is for interactive, tty
    # --privileged for accessing /dev contents
    # --net=host to share the same network as host machine. TL;DR same IP.
    xhost +local:root # giving display privilages
    docker run -it --privileged --net=host \
    --name f1tenthgpu \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    -v ${PROJECT_ROOT}/scripts/deploy/app.sh:/root/app.sh \
    $@
}



stop_docker() {
    docker stop f1tenthgpu && docker rm f1tenthgpu
}
