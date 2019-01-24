#!/bin/bash -       
#title:        bull-blade-pxe-install-postscript.sh
#description:  This script is run after the PXE-install of KAMK Bull blades
#ogranization: Kajaani University of Applied Sciences (KAMK)
#project:      Bull Supercomputer - bullx DLC blade system - B700 Series
#author:       Jukka Jurvansuu
#created:      2019-01-24
#modified:     2019-01-24
#version:      1.0    
#usage:        bash bull-blade-pxe-install-postscript.sh
#OS:           CentOS 7
#==============================================================================

### Docker installation

# Install required packages for Docker
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

# Set up the stable repository
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Install the latest version of Docker CE
yum install docker-ce  -y

# Enable Docker
systemctl enable docker

# Start Docker
systemctl start docker

# Install Docker Compose
yum install -y epel-release
yum install -y python-pip
pip install docker-compose
pip install --upgrade pip
yum upgrade -y python*
