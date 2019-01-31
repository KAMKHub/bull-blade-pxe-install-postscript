#!/bin/bash -       
#title:        bull-blade-pxe-install-postscript.sh
#description:  This script is run after the PXE-install of KAMK Bull blades
#ogranization: Kajaani University of Applied Sciences (KAMK)
#project:      Bull Supercomputer - bullx DLC blade system - B700 Series
#author:       Jukka Jurvansuu <jukka.jurv@nsuu.fi>
#created:      2019-01-24
#modified:     2019-01-31
#version:      1.4
#usage:        bash bull-blade-pxe-install-postscript.sh
#OS:           CentOS 7
#attention:    It is not allowed to run "yum update -y" in order to complete
#              NVIDIA Driver installation successfully. The update will install
#              incompatible kernel-headers and NVIDIA Driver installation
#              fails.
#==============================================================================

#==============================================================================
# Install tools, useful utilities and settings
#==============================================================================

# Set time zone and NTP
## Check settings: timedatectl
yum -y install ntp
chkconfig ntpd on
service ntpd start
timedatectl set-timezone Europe/Helsinki
sed -i 's/SYNC_HWCLOCK=no/SYNC_HWCLOCK=yes/g' /etc/sysconfig/ntpdate /etc/sysconfig/ntpdate

yum install -y epel-release
yum install -y nano
yum install -y telnet

# Disable SELinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

# Disable Firewall
systemctl stop firewalld
systemctl disable firewalld

# Enable root-login
sed -i -r 's/.?PermitRootLogin.+/PermitRootLogin yes/' /etc/ssh/sshd_config

#==============================================================================
# Install NVIDIA Driver
#==============================================================================

# Development tools should be installed at the Kickstart for the NVIDIA script because this install cannot find
## kernel-devel and kernel-headers for the default kernel version
# yum groupinstall -y "Development tools"
# yum install -y kernel-devel-$(uname -r)
# yum install -y kernel-headers-$(uname -r)

# Unload nouveau driver to not conflict with the installation of the NVIDIA driver
# https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-centos-7-linux
rmmod nouveau

# Disable nouveau driver from the grub file and generates a configuration files for GRUB
# https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-centos-7-linux
sed -ri 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nouveau.modeset=0 rd.driver.blacklist=nouveau /g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

# Install NVIDIA driver from the source (required approach for CentOS 7).
cd /root
yum install -y dkms
wget http://fr.download.nvidia.com/tesla/410.79/NVIDIA-Linux-x86_64-410.79.run
sh NVIDIA-Linux-x86_64-410.79.run --dkms -s

# Info: How to test NVIDIA driver
# lshw -numeric -C display
# nvidia-smi

#==============================================================================
# Install CUDA Toolkit using repository and set path
#==============================================================================

cd /root
#wget https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-10.0.130-1.x86_64.rpm
wget https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-9.0.176-1.x86_64.rpm
rpm -i cuda-repo-rhel7-9.0.176-1.x86_64.rpm
yum install -y cuda-9.0.176-1
rm -f /etc/profile.d/cudapath.sh
touch /etc/profile.d/cudapath.sh
echo "PATH=/usr/local/cuda/bin:$PATH" > /etc/profile.d/cudapath.sh
echo "LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH" >> /etc/profile.d/cudapath.sh

# Info: Verify driver version by looking at:
# cat /proc/driver/nvidia/version

# Info: Verify the CUDA Toolkit version
# nvcc -V

# Info: Verify running CUDA GPU jobs by compiling the samples and executing the deviceQuery or bandwidthTest programs
# cd /usr/local/cuda/samples/1_Utilities/deviceQuery
# make
# ./deviceQuery
# cd /usr/local/cuda/samples/1_Utilities/bandwidthTest
# make
# ./bandwidthTest

#==============================================================================
# Install cuDNN Runtime Library for RedHat/Centos 7.3 (RPM)
#==============================================================================

cd /root
wget http://172.28.0.253/centos7_x64_everything_1804/libcudnn7-7.4.2.24-1.cuda9.0.x86_64.rpm
rpm -Uvh libcudnn7-7.4.2.24-1.cuda9.0.x86_64.rpm

#==============================================================================
# Install cuDNN Developer Library for RedHat/Centos 7.3 (RPM)
#==============================================================================

cd /root
wget http://172.28.0.253/centos7_x64_everything_1804/libcudnn7-devel-7.4.2.24-1.cuda9.0.x86_64.rpm
rpm -Uvh libcudnn7-devel-7.4.2.24-1.cuda9.0.x86_64.rpm

#==============================================================================
# Install cuDNN Code Samples and User Guide for RedHat/Centos 7.3 (RPM)
#==============================================================================

cd /root
wget http://172.28.0.253/centos7_x64_everything_1804/libcudnn7-doc-7.4.2.24-1.cuda9.0.x86_64.rpm
rpm -Uvh libcudnn7-doc-7.4.2.24-1.cuda9.0.x86_64.rpm

mkdir /root/cudnn
cd /root/cudnn
wget http://172.28.0.253/centos7_x64_everything_1804/cudnn-9.0-linux-x64-v7.4.2.24.tgz
tar -xzvf cudnn-9.0-linux-x64-v7.4.2.24.tgz
cp cuda/include/cudnn.h /usr/local/cuda/include
cp cuda/lib64/libcudnn* /usr/local/cuda/lib64
chmod a+r /usr/local/cuda/include/cudnn.h /usr/local/cuda/lib64/libcudnn*

#==============================================================================
# Info: Verifying cuDNN Installation
#==============================================================================

# mkdir /root/cudnntest
# cd /root/cudnntest
# cp -r /usr/src/cudnn_samples_v7/ /root/cudnntest
# cd /root/cudnntest/cudnn_samples_v7/mnistCUDNN
# make clean && make
# ./mnistCUDNN

#==============================================================================
# Install Python
#==============================================================================

yum install -y python
yum install -y python-pip
pip install --upgrade pip
pip install ipython

#==============================================================================
# Install Tensorflow Nightly build with GPU support (unstable). Support for
# CUDA 10 and cuDNN 7.
#==============================================================================

pip install tensorflow-gpu

#==============================================================================
# Info: Testing Tensorflow
# ipython
# In [1]: from __future__ import print_function
# In [2]: import tensorflow as tf
# In [3]: hello = tf.constant('Hello, TensorFlow!')
# In [4]: sess = tf.Session()
# In [5]: print(sess.run(hello))
# In [6]: quit
#==============================================================================

#==============================================================================
# Docker installation
#==============================================================================

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
pip install docker-compose

#==============================================================================
# Install NVIDIA Container Runtime for Docker
#==============================================================================

## Add the package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | \
  sudo tee /etc/yum.repos.d/nvidia-docker.repo

# Install nvidia-docker2 and reload the Docker daemon configuration
yum install -y nvidia-docker2
pkill -SIGHUP dockerd

# Info: Test nvidia-smi with the latest official CUDA image
# docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi

# Info: Run a TensorFlow container
# cd /root
# docker pull tensorflow/tensorflow # Download latest image
# docker run -it -p 8888:8888 tensorflow/tensorflow # Start a Jupyter notebook server
