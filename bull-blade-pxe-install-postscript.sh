#!/bin/bash -       
#title:        bull-blade-pxe-install-postscript.sh
#description:  This script is run after the PXE-install of KAMK Bull blades
#ogranization: Kajaani University of Applied Sciences (KAMK)
#project:      Bull Supercomputer - bullx DLC blade system - B700 Series
#author:       Jukka Jurvansuu <jukka.jurv@nsuu.fi>
#created:      2019-01-24
#modified:     2019-01-27
#version:      1.2
#usage:        bash bull-blade-pxe-install-postscript.sh
#OS:           CentOS 7
#==============================================================================

### Install tools and useful utilities
yum install -y epel-release
yum update -y

### Install NVIDIA Driver

# Development tools should be installed at the Kickstart for the NVIDIA script
# yum groupinstall -y "Development Tools"
# yum install -y kernel-devel
# yum install -y kernel-headers

# Unload nouveau driver to not conflict with the installation of the NVIDIA driver
# https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-centos-7-linux
rmmod nouveau

# Disable nouveau driver at grub file 
# https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-centos-7-linux
# grub2-mkconfig -o /boot/grub2/grub.cfg
# grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

# Install NVIDIA driver
cd /root
yum install -y dkms
wget http://fr.download.nvidia.com/tesla/410.79/NVIDIA-Linux-x86_64-410.79.run
sh NVIDIA-Linux-x86_64-410.79.run -s

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
