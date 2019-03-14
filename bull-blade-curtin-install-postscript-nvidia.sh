#!/bin/bash -       
#title:        bull-blade-curtin-install-postscript-nvidia.sh
#description:  This script is run after the Curtin-install of KAMK Bull NVIDIA GPU blades
#organization: Kajaani University of Applied Sciences (KAMK)
#project:      Bull Supercomputer - bullx DLC blade system - B700 Series
#author:       Jukka Jurvansuu <jukka.jurv@nsuu.fi>
#created:      2019-03-09
#modified:     2019-03-15
#version:      1.0
#usage:        bull-blade-pxe-install-postscript-nvidia.sh
#OS:           CentOS 7
#attention:    It is not allowed to run "yum update -y" before NVIDIA Driver
#              installation in order to completethe installation successfully.
#              The update will install incompatible kernel-headers and
#              NVIDIA Driver installation fails.
#==============================================================================

#==============================================================================
# Install tools, useful utilities and settings
#==============================================================================

# Clear the yum Caches
yum clean all

# Set time zone and NTP
## Check settings: timedatectl
yum -y install ntp
systemctl enable ntpd
systemctl start ntpd
timedatectl set-timezone Europe/Helsinki
sed -i 's/SYNC_HWCLOCK=no/SYNC_HWCLOCK=yes/g' /etc/sysconfig/ntpdate /etc/sysconfig/ntpdate

yum install -y epel-release
yum install -y nano
yum install -y telnet
yum install -y rsync

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

# Development tools should be installed at the Curtin for the NVIDIA script because this install cannot find
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
wget http://172.28.0.253/centos7_x64_everything_1804/nvidia/NVIDIA-Linux-x86_64-410.79.run
sh NVIDIA-Linux-x86_64-410.79.run --dkms -s

# Info: How to test NVIDIA driver
# lshw -numeric -C display
# nvidia-smi

# : <<'DO-NOT-INSTALL-CUDA'

#==============================================================================
# Install CUDA Toolkit using repository and set path
#==============================================================================

cd /root
wget https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-10.0.130-1.x86_64.rpm
rpm -i cuda-repo-*.rpm
yum install -y cuda-10-0
rm -f /etc/profile.d/cudapath.sh
touch /etc/profile.d/cudapath.sh
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
echo "export PATH=/usr/local/cuda/bin:$PATH" > /etc/profile.d/cudapath.sh
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH" >> /etc/profile.d/cudapath.sh

# Remove NVIDIA Driver 418.39 which is not working with CUDA 10.0. The driver was installed automatically when installing CUDA Tookit
yum remove -y nvidia-driver-418.39

# Remove NDIVIA-repository for not installing any updates for NVIDIA
rm -f /etc/yum.repos.d/cuda.repo

# Reinstall NVIDIA Driver 410.79
cd /root
sh NVIDIA-Linux-x86_64-410.79.run --dkms -s

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
wget http://172.28.0.253/centos7_x64_everything_1804/libcudnn7-7.4.2.24-1.cuda10.0.x86_64.rpm
rpm -Uvh libcudnn7-7.4.2.24-1.cuda10.0.x86_64.rpm

#==============================================================================
# Install cuDNN Developer Library for RedHat/Centos 7.3 (RPM)
#==============================================================================

cd /root
wget http://172.28.0.253/centos7_x64_everything_1804/libcudnn7-devel-7.4.2.24-1.cuda10.0.x86_64.rpm
rpm -Uvh libcudnn7-devel-7.4.2.24-1.cuda10.0.x86_64.rpm

#==============================================================================
# Install cuDNN Code Samples and User Guide for RedHat/Centos 7.3 (RPM)
#==============================================================================

cd /root
wget http://172.28.0.253/centos7_x64_everything_1804/libcudnn7-doc-7.4.2.24-1.cuda10.0.x86_64.rpm
rpm -Uvh libcudnn7-doc-7.4.2.24-1.cuda10.0.x86_64.rpm

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
# Install Tensorflow with GPU support (unstable).
# Support for CUDA 10 and cuDNN 7.
#==============================================================================

pip install --ignore-installed tensorflow-gpu

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

# Install Docker Compose (docker-compose pip install fails with pip 10.0.0 or later; need to downgrade)
pip install --upgrade --force-reinstall pip==9.0.3
pip install docker-compose
pip install --upgrade pip

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
# nvidia-docker run --rm nvidia/cuda:10.0-base nvidia-smi

# Info: Run a TensorFlow container
# cd /root
# nvidia-docker run -d --name tensorflow-gpu-py3-jupyter -p 8888:8888 tensorflow/tensorflow:latest-gpu-py3-jupyter
## nvidia-docker exec -it tensorflow-gpu-py3-jupyter bash
## jupyter notebook list
## http://127.0.0.1:8888/?token=[token]

yum update -y

# DO-NOT-INSTALL-CUDA
